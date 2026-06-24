import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/milestone_card.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../projects/providers/project_providers.dart';
import '../../payments/providers/wallet_providers.dart';
import '../../payments/providers/invoice_providers.dart';
import '../../../core/utils/seed_service.dart';
import '../../../core/widgets/app_snackbar.dart';


final _dashboardProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(milliseconds: 900));
  return true;
});

class FreelancerDashboardScreen extends ConsumerWidget {
  const FreelancerDashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final projectsAsync = ref.watch(dashboardProjectsProvider);
    final milestonesAsync = ref.watch(dashboardMilestonesProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error loading user: $e'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }
        return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/invoices/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.receipt_outlined, color: Colors.white),
        label: Text('New Invoice',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_dashboardProvider.future),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => context.push('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  tooltip: 'Seed Firebase Database',
                  onPressed: () async {
                    AppSnackBar.success(context, 'Seeding database...');
                    await SeedService.seedDatabase();
                    AppSnackBar.success(context, 'Database seeded successfully!');
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
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
                              '${_greeting()}, ${user.name.split(' ').first} 👋',
                              style: AppTextStyles.headlineMedium
                                  .copyWith(color: Colors.white),
                            ),
                            Text(
                              DateFormatter.format(DateTime.now()),
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8)),
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
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          // Stat cards
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: 'Earned',
                                  value: CurrencyFormatter.formatCompact(
                                      user.totalEarned),
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  label: 'Active',
                                  value: projects
                                      .where((p) => p.status.name == 'active')
                                      .length
                                      .toString(),
                                  icon: Icons.folder_open_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  label: 'Reviews',
                                  value: milestones
                                      .where((m) => m.status.name == 'review')
                                      .length
                                      .toString(),
                                  icon: Icons.rate_review_rounded,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Upcoming deadlines
                          _SectionHeader(
                            title: 'Upcoming Deadlines',
                            onSeeAll: () => context.push('/projects'),
                          ),
                          const SizedBox(height: 12),
                          if (milestones.isEmpty)
                            const Center(child: Text('No upcoming deadlines.'))
                          else
                            ...milestones
                                .where((m) => m.status.name != 'approved')
                                .take(3)
                                .map((m) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: MilestoneCard(
                                        milestone: m,
                                        onTap: () =>
                                            context.push('/milestones/${m.id}'),
                                      ),
                                    )),
                    const SizedBox(height: 24),
                    // Recent activity
                    _SectionHeader(title: 'Recent Activity', onSeeAll: null),
                    const SizedBox(height: 12),
                    _ActivityFeed(),
                    const SizedBox(height: 24),
                    // Quick actions
                    _SectionHeader(title: 'Quick Actions', onSeeAll: null),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.work_outline_rounded,
                            label: 'Work',
                            onTap: () => context.push('/find-work'),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'Wallet',
                            onTap: () => context.push('/wallet'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
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
    );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
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
            Text(value,
                style: AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _ActivityFeed extends ConsumerWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: transactionsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading activity: $e'),
        ),
        data: (transactions) {
          final deposits = transactions.where((t) => t.amount > 0).toList();
          
          if (deposits.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No recent activity.'),
            );
          }

          final items = deposits.take(5).map((p) {
            return _ActivityItem(
              icon: Icons.payments_rounded,
              color: AppColors.success,
              text: 'Deposit of \$${p.amount} received for ${p.invoiceNumber ?? 'Invoice'}',
              time: _relativeTime(p.createdAt),
            );
          }).toList();

          return Column(
            children: items.map((item) => _ActivityTile(item: item)).toList(),
          );
        },
      ),
    );
  }


  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ActivityItem {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: item.color, size: 18),
      ),
      title: Text(item.text, style: AppTextStyles.bodySmall, maxLines: 2),
      subtitle: Text(item.time,
          style: AppTextStyles.labelSmall
              .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      dense: true,
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
