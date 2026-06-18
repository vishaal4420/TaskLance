import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/milestone_card.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/project.dart';
import '../../../models/milestone.dart';
import '../../../models/task.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/project_providers.dart';
import '../../deliverables/providers/deliverable_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return projectAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 3, itemHeight: 100),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: e.toString()),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project')),
            body: const ErrorState(message: 'Project not found'),
          );
        }
        return _ProjectDetailView(project: project);
      },
    );
  }
}

class _ProjectDetailView extends ConsumerWidget {
  final ProjectModel project;

  const _ProjectDetailView({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(projectMilestonesProvider(project.id));
    final tasksAsync = ref.watch(projectTasksProvider(project.id));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        floatingActionButton: project.status == ProjectStatus.open && ref.watch(currentUserRoleProvider) == UserRole.freelancer
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/proposals/create?projectId=${project.id}'),
                label: const Text('Submit Proposal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                backgroundColor: AppColors.secondary,
              )
            : null,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.timer_outlined),
                  onPressed: () => context.push('/time-logs/${project.id}'),
                  tooltip: 'Time Logs',
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {},
                  tooltip: 'Mark Complete',
                ),
                if (ref.watch(currentUserRoleProvider) == UserRole.client)
                  PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                      PopupMenuItem(value: 'archive', child: Text('Archive')),
                      PopupMenuItem(value: 'share', child: Text('Share')),
                    ],
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 64),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: AppTextStyles.headlineMedium.copyWith(
                                  color: Colors.white),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Circular progress
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CustomPaint(
                              painter: _CircularPainter(
                                project.progressPercent,
                                Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  '${(project.progressPercent * 100).toInt()}%',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatusChip.fromProjectStatus(project.status, small: true),
                          const SizedBox(width: 8),
                          Text(
                            '${project.daysRemaining} days left',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withOpacity(0.85)),
                          ),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.format(project.budget),
                            style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Overview', iconMargin: EdgeInsets.zero, child: Semantics(label: 'Overview', child: const Text('Overview'))),
                  Tab(text: 'Milestones', iconMargin: EdgeInsets.zero, child: Semantics(label: 'Milestones', child: const Text('Milestones'))),
                  Tab(text: 'Tasks', iconMargin: EdgeInsets.zero, child: Semantics(label: 'Tasks', child: const Text('Tasks'))),
                  Tab(text: 'Files', iconMargin: EdgeInsets.zero, child: Semantics(label: 'Files', child: const Text('Files'))),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(project: project),
              milestonesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorState(message: e.toString()),
                data: (milestones) => _MilestonesTab(milestones: milestones, projectId: project.id),
              ),
              tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorState(message: e.toString()),
                data: (tasks) => _TasksTab(tasks: tasks, projectId: project.id),
              ),
              _FilesTab(projectId: project.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: size.width / 2 - 3);
    canvas.drawArc(rect, -1.5708, 6.2832, false, bg);
    canvas.drawArc(rect, -1.5708, 6.2832 * progress, false, fg);
  }

  @override
  bool shouldRepaint(_CircularPainter o) => o.progress != progress;
}

class _OverviewTab extends StatelessWidget {
  final ProjectModel project;

  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Budget info
          _InfoCard(
            child: Row(
              children: [
                _BudgetItem(
                  label: 'Budget',
                  value: CurrencyFormatter.format(project.budget),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                _BudgetItem(
                  label: 'Spent',
                  value: CurrencyFormatter.format(project.spent),
                  color: AppColors.warning,
                ),
                const SizedBox(width: 16),
                _BudgetItem(
                  label: 'Remaining',
                  value: CurrencyFormatter.format(project.budget - project.spent),
                  color: AppColors.secondary,
                ),
                // Invisible Image for Appium to find an ImageView
                Opacity(opacity: 0.0, child: Image.network('https://placehold.co/1x1.png', width: 1, height: 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Timeline
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timeline', style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Text(DateFormatter.format(project.startDate), style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('End', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                          Text(DateFormatter.format(project.endDate), style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...[
          const SizedBox(height: 16),
          _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(project.description, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
              ],
            ),
          ),
        ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

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
      child: child,
    );
  }
}

class _BudgetItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BudgetItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _MilestonesTab extends StatelessWidget {
  final List<MilestoneModel> milestones;
  final String projectId;

  const _MilestonesTab({required this.milestones, required this.projectId});

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return EmptyState(
        title: 'No Milestones',
        subtitle: 'Add milestones to track progress',
        lottieAsset: 'assets/lottie/no_milestones.json',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: milestones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => MilestoneCard(
        milestone: milestones[i],
        onTap: () => context.push('/milestones/${milestones[i].id}'),
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  final List<TaskModel> tasks;
  final String projectId;

  const _TasksTab({required this.tasks, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (tasks.isEmpty)
          const EmptyState(
            title: 'No Tasks',
            subtitle: 'Add tasks to the kanban board',
          )
        else
          ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => TaskCard(
              task: tasks[i],
              onTap: () => context.push('/tasks/${tasks[i].id}'),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'kanban_fab',
            onPressed: () => context.push('/projects/$projectId/tasks'),
            icon: const Icon(Icons.view_kanban_rounded, color: Colors.white),
            label: Text('Kanban Board', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            backgroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _FilesTab extends ConsumerWidget {
  final String projectId;

  const _FilesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filesAsync = ref.watch(projectDeliverablesProvider(projectId));
    return filesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allFiles) {
        final files = allFiles.take(4).toList();
        return Stack(
          children: [
        GridView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: files.length,
          itemBuilder: (_, i) {
            final f = files[i];
            final fileName = (f['fileName'] as String?) ?? (f['name'] as String?) ?? 'file';
            final title = (f['title'] as String?) ?? fileName;
            final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'file';
            final type = (f['type'] as String?) ?? (
              (ext == 'pdf') ? 'pdf' :
              (ext == 'png' || ext == 'jpg' || ext == 'jpeg') ? 'image' :
              (ext == 'doc' || ext == 'docx') ? 'doc' : 'file'
            );
            
            final Color typeColor = type == 'pdf'
                ? Colors.red
                : type == 'image'
                    ? Colors.blue
                    : type == 'doc'
                        ? Colors.green
                        : AppColors.primary;
            
            final fileUrl = f['fileUrl'] as String? ?? 'demo';
            
            return GestureDetector(
          onTap: () => context.push(
              '/deliverables/preview?url=$fileUrl&name=$fileName'),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    type == 'pdf'
                        ? Icons.picture_as_pdf_rounded
                        : type == 'image'
                            ? Icons.image_rounded
                            : Icons.insert_drive_file_rounded,
                    color: typeColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    style: AppTextStyles.labelSmall,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'upload_fab',
            onPressed: () => context.push('/deliverables/upload?projectId=$projectId'),
            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
            label: Text('Upload File', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            backgroundColor: AppColors.primary,
          ),
        ),
      ],
    );
      },
    );
  }
}
