import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/date_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../projects/providers/project_providers.dart';
import '../../../models/milestone.dart';
import '../../../models/task.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class MilestoneDetailScreen extends ConsumerStatefulWidget {
  final String milestoneId;

  const MilestoneDetailScreen({super.key, required this.milestoneId});

  @override
  ConsumerState<MilestoneDetailScreen> createState() =>
      _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState
    extends ConsumerState<MilestoneDetailScreen> {
  bool _expanded = false;
  final List<String> _checkedTaskIds = [];
  final _commentCtrl = TextEditingController();
  final List<Map<String, String>> _comments = [
    {'name': 'Sarah Chen', 'text': 'Looking great! Please make sure to add the error states too.', 'time': '3 hours ago'},
    {'name': 'Alex Rivera', 'text': 'Yes, the error states are included in the Figma file.', 'time': '2 hours ago'},
    {'name': 'Sarah Chen', 'text': 'Perfect. Approving soon!', 'time': '1 hour ago'},
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milestoneAsync = ref.watch(milestoneDetailProvider(widget.milestoneId));
    final tasksAsync = ref.watch(milestoneTasksProvider(widget.milestoneId));

    return milestoneAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 4, itemHeight: 80),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: e.toString()),
      ),
      data: (milestone) {
        if (milestone == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(message: 'Milestone not found'),
          );
        }

        return tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading tasks: $e')),
          data: (tasks) {
        final role = ref.read(currentUserRoleProvider);
        final canApprove = role == UserRole.client && milestone.status == MilestoneStatus.review;
        final canSubmit = role == UserRole.freelancer && (milestone.status == MilestoneStatus.inProgress || milestone.status == MilestoneStatus.upcoming || milestone.status == MilestoneStatus.revision);
        
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              milestone.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              StatusChip.fromMilestoneStatus(milestone.status),
              const SizedBox(width: 12),
            ],
          ),
          bottomNavigationBar: (canApprove || canSubmit) ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: canApprove ? 'Review & Approve' : 'Approve / Submit for Review',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Request Revision'),
                    ),
                  ),
                ],
              ),
            ),
          ) : null,
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Deadline row
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: milestone.isOverdue
                              ? AppColors.error.withOpacity(0.3)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: milestone.isOverdue
                                ? AppColors.error
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Due ${DateFormatter.format(milestone.dueDate)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: milestone.isOverdue
                                  ? AppColors.error
                                  : null,
                              fontWeight: milestone.isOverdue
                                  ? FontWeight.w600
                                  : null,
                            ),
                          ),
                          if (milestone.isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('OVERDUE',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (milestone.description != null) ...[
                      _SectionCard(
                        title: 'Description',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                milestone.description!,
                                maxLines: _expanded ? null : 3,
                                overflow: _expanded ? null : TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _expanded = !_expanded),
                              child: Text(_expanded ? 'Show less' : 'See more'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Deliverables
                    _SectionCard(
                      title: 'Deliverables',
                      child: Column(
                        children: [
                          _DeliverableTile(name: 'design_system.pdf', type: 'pdf'),
                          _DeliverableTile(name: 'wireframes.fig', type: 'fig'),
                          _DeliverableTile(name: 'component_kit.sketch', type: 'sketch'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Linked tasks
                    _SectionCard(
                      title: 'Linked Tasks (${tasks.length})',
                      child: tasks.isEmpty
                          ? Text('No tasks linked',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))
                          : Column(
                              children: tasks.map((t) => CheckboxListTile(
                                value: _checkedTaskIds.contains(t.id) ||
                                    t.status == TaskStatus.done,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _checkedTaskIds.add(t.id);
                                    } else {
                                      _checkedTaskIds.remove(t.id);
                                    }
                                  });
                                },
                                title: Text(t.title, style: AppTextStyles.bodySmall),
                                dense: true,
                                activeColor: AppColors.primary,
                              )).toList(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Comments
                    _SectionCard(
                      title: 'Comments (${_comments.length})',
                      child: Column(
                        children: _comments.map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AvatarWidget(name: c['name']!, size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(c['name']!, style: AppTextStyles.labelMedium),
                                      const SizedBox(width: 6),
                                      Text(c['time']!,
                                          style: AppTextStyles.labelSmall.copyWith(
                                              color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                                    ]),
                                    const SizedBox(height: 3),
                                    Text(c['text']!, style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Submit for review
                    ElevatedButton.icon(
                      onPressed: () => AppSnackBar.success(
                          context, 'Milestone submitted for review!'),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit for Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              // Comment input bar
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: Border(
                        top: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: () {
                          if (_commentCtrl.text.isNotEmpty) {
                            setState(() {
                              _comments.add({'name': 'Alex Rivera', 'text': _commentCtrl.text, 'time': 'Just now'});
                              _commentCtrl.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      ); // tasksAsync.when
      }, // milestoneAsync.when
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DeliverableTile extends StatelessWidget {
  final String name;
  final String type;

  const _DeliverableTile({required this.name, required this.type});

  Future<void> _launchDownload(BuildContext context) async {
    final url = Uri.parse('https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          AppSnackBar.error(context, 'Could not launch download URL.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Error launching download: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = type == 'pdf'
        ? Icons.picture_as_pdf_rounded
        : type == 'fig' || type == 'sketch'
            ? Icons.design_services_rounded
            : Icons.insert_drive_file_rounded;
    final color = type == 'pdf'
        ? Colors.red
        : type == 'fig' || type == 'sketch'
            ? AppColors.primary
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: AppTextStyles.bodySmall)),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
            onPressed: () => _launchDownload(context),
          ),
        ],
      ),
    );
  }
}
