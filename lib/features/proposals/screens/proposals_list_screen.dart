import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final clientProposalsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  
  if (user.role == UserRole.client) {
    return FirebaseFirestore.instance.collection('proposals')
        .where('clientUid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  } else {
    // Freelancer sees their own proposals
    return FirebaseFirestore.instance.collection('proposals')
        .where('freelancerUid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
});

class ProposalsListScreen extends ConsumerWidget {
  const ProposalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final proposalsAsync = ref.watch(clientProposalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proposals')),
      floatingActionButton: role == UserRole.freelancer
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/proposals/create'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Proposal', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: proposalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (proposals) {
          if (proposals.isEmpty) {
            return EmptyState(
              title: 'No Proposals',
              subtitle: role == UserRole.client
                  ? 'You have not received any proposals yet'
                  : 'Create a proposal to win a new project',
              icon: Icons.description_outlined,
              lottieAsset: 'assets/lottie/no_projects.json',
              actionLabel: role == UserRole.freelancer ? 'Create Proposal' : null,
              onAction: role == UserRole.freelancer ? () => context.push('/proposals/create') : null,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: proposals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = proposals[i];
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final partnerName = role == UserRole.client ? p['freelancerName'] : 'Client';
              
              return ListTile(
                onTap: () => context.push('/proposals/${p['id']}'),
                tileColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                title: Text('Proposal for Project', style: AppTextStyles.titleMedium),
                subtitle: Text(
                  role == UserRole.client ? 'Freelancer: $partnerName' : 'Client: $partnerName',
                  style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${p['bidAmount']}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    StatusChip.fromString(p['status'] ?? 'pending', small: true),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
