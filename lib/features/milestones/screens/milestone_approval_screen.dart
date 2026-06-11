import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/milestone.dart';
import '../providers/milestone_providers.dart';

class MilestoneApprovalScreen extends ConsumerStatefulWidget {
  final String milestoneId;

  const MilestoneApprovalScreen({super.key, required this.milestoneId});

  @override
  ConsumerState<MilestoneApprovalScreen> createState() =>
      _MilestoneApprovalScreenState();
}

class _MilestoneApprovalScreenState
    extends ConsumerState<MilestoneApprovalScreen> {
  bool _showRevisionInput = false;
  bool _approving = false;
  final _revisionCtrl = TextEditingController();

  void _updateStatus(String status, String successMessage) async {
    setState(() => _approving = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final msRef = FirebaseFirestore.instance.collection('milestones').doc(widget.milestoneId);
      batch.update(msRef, {'status': status});
      
      // Also update related deliverables if approving
      if (status == MilestoneStatus.approved.name) {
        final delivs = await FirebaseFirestore.instance
            .collection('deliverables')
            .where('milestoneId', isEqualTo: widget.milestoneId)
            .get();
        for (var doc in delivs.docs) {
          batch.update(doc.reference, {'status': 'approved'});
        }
      }
      
      await batch.commit();
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(status == MilestoneStatus.approved.name ? 'Milestone Approved! 🎉' : 'Revision Requested'),
          content: Text(successMessage),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                context.pop(); // close screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == MilestoneStatus.approved.name ? AppColors.secondary : AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to update milestone: $e');
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  Future<void> _approve() async {
    _updateStatus(MilestoneStatus.approved.name, 'The freelancer will be notified of your approval.');
  }
  
  Future<void> _requestRevision() async {
    final notes = _revisionCtrl.text.trim();
    if (notes.isEmpty) {
      AppSnackBar.error(context, 'Please provide revision notes');
      return;
    }
    // Ideally save revision notes to a subcollection or notifications
    _updateStatus(MilestoneStatus.revision.name, 'The freelancer has been notified of your revision request.');
  }

  @override
  void dispose() {
    _revisionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milestoneAsync = ref.watch(singleMilestoneProvider(widget.milestoneId));
    final deliverablesAsync = ref.watch(milestoneDeliverablesProvider(widget.milestoneId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return milestoneAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Review Milestone')),
        body: const ShimmerList(count: 3, itemHeight: 120),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Review Milestone')),
        body: ErrorState(message: e.toString()),
      ),
      data: (milestone) {
        if (milestone == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Review Milestone')),
            body: const ErrorState(message: 'Milestone not found'),
          );
        }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Milestone')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Milestone info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Ready for Review',
                              style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        Text(milestone.title,
                            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                        if (milestone.description != null) ...[
                          const SizedBox(height: 6),
                          Text(milestone.description!,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.85)),
                              maxLines: 3),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Deliverables', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  deliverablesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading deliverables: $e'),
                    data: (deliverables) {
                      if (deliverables.isEmpty) {
                        return Text('No deliverables uploaded yet.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight));
                      }
                      return Column(
                        children: deliverables.map((d) {
                          final name = d['fileName'] as String? ?? 'Unnamed file';
                          String type = 'doc';
                          if (name.toLowerCase().endsWith('.pdf')) type = 'pdf';
                          else if (name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpg')) type = 'image';
                          else if (name.toLowerCase().endsWith('.fig')) type = 'fig';
                          else if (name.toLowerCase().endsWith('.mp4')) type = 'video';
                          
                          return _DeliverableItem(
                            name: name,
                            type: type,
                            onTap: () => AppSnackBar.info(context, 'Opening preview...'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // Revision notes (animated)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showRevisionInput
                        ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Revision Notes', style: AppTextStyles.titleMedium),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _revisionCtrl,
                                  maxLines: 4,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Describe what needs to be revised...',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    filled: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _approving ? null : _requestRevision,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.warning,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  child: Text(_approving ? 'Sending...' : 'Send Revision Request'),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          // Bottom action bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _showRevisionInput = !_showRevisionInput),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Request Revision'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _approving ? null : _approve,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _approving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded),
                      label: Text(_approving ? 'Approving...' : 'Approve'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
);
  }
}

class _DeliverableItem extends StatelessWidget {
  final String name;
  final String type;
  final VoidCallback onTap;

  const _DeliverableItem({required this.name, required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = type == 'pdf' ? Colors.red : type == 'fig' ? AppColors.primary : Colors.orange;
    final icon = type == 'pdf'
        ? Icons.picture_as_pdf_rounded
        : type == 'video'
            ? Icons.play_circle_rounded
            : Icons.design_services_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: AppTextStyles.bodySmall)),
            Icon(Icons.open_in_new_rounded, size: 16, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}
