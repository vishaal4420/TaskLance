import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/project_card.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../models/project.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/project_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  ProjectStatus? _filter;

  List<ProjectModel> _filtered(List<ProjectModel> all) {
    if (_filter == null) return all;
    return all.where((p) => p.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(dashboardProjectsProvider);

    return Scaffold(
      floatingActionButton: ref.watch(currentUserRoleProvider) == UserRole.client
          ? FloatingActionButton(
              onPressed: () => context.push('/projects/create'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardProjectsProvider),
        child: Column(
          children: [
            // Filter chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  _FilterChip(
                    label: 'Active',
                    selected: _filter == ProjectStatus.active,
                    onSelected: (_) =>
                        setState(() => _filter = ProjectStatus.active),
                  ),
                  _FilterChip(
                    label: 'Completed',
                    selected: _filter == ProjectStatus.completed,
                    onSelected: (_) =>
                        setState(() => _filter = ProjectStatus.completed),
                  ),
                  _FilterChip(
                    label: 'On Hold',
                    selected: _filter == ProjectStatus.onHold,
                    onSelected: (_) =>
                        setState(() => _filter = ProjectStatus.onHold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: projectsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: ShimmerList(count: 3, itemHeight: 130),
                ),
                error: (e, _) => ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.refresh(dashboardProjectsProvider),
                ),
                data: (projects) {
                  final filtered = _filtered(projects);
                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: 'No Projects',
                      subtitle: 'No projects match this filter',
                      lottieAsset: 'assets/lottie/no_projects.json',
                      actionLabel: 'Create Project',
                      onAction: () => context.push('/projects/create'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => ProjectCard(
                      project: filtered[i],
                      onTap: () =>
                          context.push('/projects/${filtered[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected
                ? AppColors.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
          ),
        ),
        selected: selected,
        onSelected: onSelected,
        selectedColor: AppColors.primary.withOpacity(0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: selected ? AppColors.primary : AppColors.textSecondaryLight,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.borderLight,
        ),
      ),
    );
  }
}
