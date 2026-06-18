import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/success_dialog.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../models/user.dart';
import '../providers/proposal_providers.dart';
import '../../projects/providers/project_providers.dart';

class ProposalDetailScreen extends ConsumerStatefulWidget {
  final String proposalId;
  const ProposalDetailScreen({super.key, required this.proposalId});

  @override
  ConsumerState<ProposalDetailScreen> createState() => _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends ConsumerState<ProposalDetailScreen> {
  bool _accepting = false;

  Future<void> _acceptProposal(Map<String, dynamic> proposal, String projectName) async {
    setState(() => _accepting = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // Update Proposal
      final propRef = FirebaseFirestore.instance.collection('proposals').doc(proposal['id']);
      batch.update(propRef, {'status': 'accepted'});
      
      // Update Project
      final projRef = FirebaseFirestore.instance.collection('projects').doc(proposal['projectId']);
      batch.update(projRef, {
        'status': 'active',
        'freelancerUid': proposal['freelancerUid'],
      });
      
      // Create initial milestone
      final milestoneId = FirebaseFirestore.instance.collection('milestones').doc().id;
      final msRef = FirebaseFirestore.instance.collection('milestones').doc(milestoneId);
      final bidAmount = double.tryParse(proposal['bidAmount']?.toString() ?? '0') ?? 0.0;
      batch.set(msRef, {
        'id': milestoneId,
        'projectId': proposal['projectId'],
        'title': 'Project Deliverables',
        'description': 'Main milestone created automatically upon proposal acceptance.',
        'status': 'inProgress',
        'value': bidAmount,
        'dueDate': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'assigneeUid': proposal['freelancerUid'],
        'taskIds': [],
        'completedTasks': 0,
        'totalTasks': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create Contract
      final contractId = FirebaseFirestore.instance.collection('contracts').doc().id;
      final contractRef = FirebaseFirestore.instance.collection('contracts').doc(contractId);
      final terms = 'This Master Service Agreement ("Agreement") is made effective as of ${DateTime.now().toIso8601String().substring(0, 10)}, by and between ${proposal['freelancerName']} and ${proposal['clientName'] ?? 'Client'}.\n\n'
                    '1. SERVICES PROVIDED. Freelancer agrees to provide services as described in the proposal.\n\n'
                    '2. PAYMENT. Client agrees to pay Freelancer the total amount of \$$bidAmount.\n\n'
                    '3. SCOPE OF WORK. ${proposal['coverLetter'] ?? 'As discussed.'}\n\n'
                    '4. CONFIDENTIALITY. Freelancer agrees to keep all proprietary client information confidential.\n';
      
      batch.set(contractRef, {
        'id': contractId,
        'projectId': proposal['projectId'],
        'title': 'Service Agreement - $projectName',
        'clientUid': proposal['clientUid'] ?? '',
        'clientName': proposal['clientName'] ?? 'Client',
        'freelancerUid': proposal['freelancerUid'],
        'freelancerName': proposal['freelancerName'] ?? 'Freelancer',
        'terms': terms,
        'amount': bidAmount,
        'signedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for freelancer
      final notifId = FirebaseFirestore.instance.collection('notifications').doc().id;
      final notifRef = FirebaseFirestore.instance.collection('notifications').doc(notifId);
      batch.set(notifRef, {
        'id': notifId,
        'userId': proposal['freelancerUid'],
        'title': 'Proposal Accepted! 🎉',
        'body': 'Your proposal for "$projectName" was accepted. The project is now active.',
        'type': 'newAssignment',
        'deepLink': '/projects/${proposal['projectId']}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      SuccessDialog.show(
        context,
        title: 'Proposal Accepted',
        message: 'A new contract has been created and the project is active.',
        onOk: () {
          context.pop(); // close dialog
          context.pop(); // go back
        },
      );
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to accept proposal: $e');
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserRoleProvider);
    final isClient = role == UserRole.client;
    final proposalAsync = ref.watch(proposalDetailProvider(widget.proposalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Proposal Details')),
      body: proposalAsync.when(
        loading: () => const ShimmerList(count: 2, itemHeight: 150),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (proposal) {
          if (proposal == null) {
            return const ErrorState(message: 'Proposal not found');
          }

          final projectId = proposal['projectId'] as String;
          final projectAsync = ref.watch(projectDetailProvider(projectId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                projectAsync.when(
                  loading: () => const Text('Loading project...'),
                  error: (e, _) => Text('Error: $e'),
                  data: (project) => Text(project?.title ?? 'Unknown Project', style: AppTextStyles.headlineLarge),
                ),
                const SizedBox(height: 8),
                Text('Freelancer: ${proposal['freelancerName'] ?? 'Unknown'}', style: AppTextStyles.titleMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const Divider(height: 32),
                Text('Budget', style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                Text('\$${proposal['bidAmount']}', style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary)),
                const SizedBox(height: 24),
                Text('Scope of Work', style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 8),
                Text(
                  proposal['coverLetter'] ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                ),
                const SizedBox(height: 48),
                if (proposal['status'] == 'pending')
                  Row(
                    children: isClient
                        ? [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.push('/chat/new-freelancer'); // mock chat route
                                },
                                child: const Text('Message'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _accepting ? null : () {
                                  final project = projectAsync.valueOrNull;
                                  _acceptProposal(proposal, project?.title ?? 'Project');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                child: Text(_accepting ? 'Accepting...' : 'Accept Proposal'),
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () { 
                                  AppSnackBar.success(context, 'Proposal withdrawn successfully');
                                  context.pop();
                                },
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                                child: const Text('Withdraw'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () { 
                                  AppSnackBar.info(context, 'Editing proposal...');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                child: const Text('Edit Proposal'),
                              ),
                            ),
                          ],
                  )
                else
                  Center(
                    child: Chip(
                      label: Text('Status: ${proposal['status']}'.toUpperCase()),
                      backgroundColor: proposal['status'] == 'accepted' ? AppColors.secondary.withOpacity(0.2) : null,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
