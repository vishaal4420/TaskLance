import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../models/contract.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';
import 'package:intl/intl.dart';

final myContractsProvider = StreamProvider.autoDispose<List<ContractModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);

  final field = user.role == UserRole.client ? 'clientUid' : 'freelancerUid';
  
  return FirebaseFirestore.instance.collection('contracts')
      .where(field, isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => ContractModel.fromJson(doc.data())).toList());
});

class ContractsListScreen extends ConsumerWidget {
  const ContractsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(myContractsProvider);
    final role = ref.watch(currentUserRoleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contracts & NDAs')),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (contracts) {
          if (contracts.isEmpty) {
            return const EmptyState(
              title: 'No Contracts', 
              subtitle: 'You haven\'t signed any contracts yet.', 
              icon: Icons.history_edu,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final c = contracts[i];
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final partnerName = role == UserRole.client ? c.freelancerName : c.clientName;
              final formattedDate = DateFormat.yMMMd().format(c.signedAt);

              return ListTile(
                onTap: () => context.push('/contracts/${c.id}'),
                tileColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.assignment_turned_in, color: Colors.white, size: 20)),
                title: Text(c.title, style: AppTextStyles.titleMedium),
                subtitle: Text('${role == UserRole.client ? "Freelancer" : "Client"}: $partnerName', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                trailing: Text(formattedDate, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              );
            },
          );
        },
      ),
    );
  }
}
