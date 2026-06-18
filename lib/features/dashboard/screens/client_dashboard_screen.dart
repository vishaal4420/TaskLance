import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/shimmer_widgets.dart';

import '../../../core/widgets/project_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../models/milestone.dart';
import '../../../core/utils/seed_service.dart';

final _clientDashProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(milliseconds: 900));
  return true;
});

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const Center(child: CircularProgressIndicator());
    final projectsAsync = ref.watch(dashboardProjectsProvider);
    final milestonesAsync = ref.watch(dashboardMilestonesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_clientDashProvider.future),
        child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.dataset, color: Colors.white),
                    tooltip: 'Seed Firebase Database',
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding database...')));
                        await SeedService.seedDatabase();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database seeded successfully!')));
                        ref.invalidate(dashboardProjectsProvider);
                        ref.invalidate(dashboardMilestonesProvider);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => context.push('/search'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () => context.push('/notifications'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Client Portal 🏢',
                                style: AppTextStyles.headlineMedium
                                    .copyWith(color: Colors.white),
                              ),
                              Text(
                                user.companyName ?? '',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: Colors.white.withOpacity(0.85)),
                              ),
                            ],
                          ),
                        ),
                        AvatarWidget(
                          url: user.avatarUrl,
                          name: user.name,
                          size: 44,
                          onTap: () => context.push('/profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: projectsAsync.when(
                  loading: () => SliverList(
                    delegate: SliverChildListDelegate([
                      const ShimmerCard(height: 80),
                      const SizedBox(height: 12),
                      const ShimmerCard(height: 200),
                    ]),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e')),
                  ),
                  data: (projects) {
                    return milestonesAsync.when(
                      loading: () => SliverList(
                        delegate: SliverChildListDelegate([
                          const ShimmerCard(height: 80),
                          const SizedBox(height: 12),
                          const ShimmerCard(height: 200),
                        ]),
                      ),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Center(child: Text('Error: $e')),
                      ),
                      data: (milestones) {
                        final pendingMilestones = milestones
                            .where((m) => m.status == MilestoneStatus.review)
                            .toList();
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            // Stat cards row
                            Row(
                              children: [
                                Expanded(
                                  child: _ClientStatCard(
                                    label: 'Spent',
                                    value: CurrencyFormatter.formatCompact(0.0), // Need a payments provider later
                                    icon: Icons.account_balance_wallet_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ClientStatCard(
                                    label: 'Active',
                                    value: projects
                                        .where((p) => p.status.name == 'active')
                                        .length
                                        .toString(),
                                    icon: Icons.folder_open_rounded,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      _ClientStatCard(
                                        label: 'Pending',
                                        value: pendingMilestones.length.toString(),
                                        icon: Icons.rate_review_rounded,
                                        color: AppColors.warning,
                                      ),
                                      if (pendingMilestones.isNotEmpty)
                                        Positioned(
                                          top: -4,
                                          right: -4,
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                pendingMilestones.length.toString(),
                                                style: AppTextStyles.labelSmall.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Awaiting review
                            if (pendingMilestones.isNotEmpty) ...[
                              _SectionHeader(
                                title: 'Awaiting Your Review',
                                actionLabel: 'See all',
                                onAction: () => context.push('/projects'),
                              ),
                              const SizedBox(height: 12),
                              ...pendingMilestones.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _ApprovalCard(
                                      milestone: m,
                                      onReview: () =>
                                          context.push('/milestones/${m.id}/approve'),
                                    ),
                                  )),
                              const SizedBox(height: 24),
                            ],
                            // Project progress
                            _SectionHeader(
                              title: 'Project Progress',
                              actionLabel: 'All projects',
                              onAction: () => context.push('/projects'),
                            ),
                            const SizedBox(height: 12),
                            if (projects.isEmpty)
                              const Center(child: Text('No projects yet.'))
                            else
                              ...projects.map((p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: ProjectCard(
                                      project: p,
                                      onTap: () => context.push('/projects/${p.id}'),
                                    ),
                                  )),
                            const SizedBox(height: 32),
                            // Quick actions
                            _SectionHeader(title: 'Quick Actions'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.receipt_outlined,
                                    label: 'Invoices',
                                    onTap: () => context.push('/invoices'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.calendar_month_outlined,
                                    label: 'Calendar',
                                    onTap: () => context.push('/calendar'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.people_outline_rounded,
                                    label: 'Team',
                                    onTap: () => context.push('/profile/team'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _QuickActionButton(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Reports',
                                    onTap: () => context.push('/analytics'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Project', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ClientStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _ClientStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(
              label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final MilestoneModel milestone;
  final VoidCallback onReview;

  const _ApprovalCard({required this.milestone, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.rate_review_rounded,
                color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Ready for review • Due ${DateFormatter.format(milestone.dueDate)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.warning),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: AppTextStyles.labelMedium,
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}
