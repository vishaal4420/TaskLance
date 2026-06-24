import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/project.dart';
import '../../../models/user.dart';
import '../../../models/invoice.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/project_providers.dart';
import '../../deliverables/providers/deliverable_providers.dart';
import '../../payments/providers/invoice_providers.dart';
import '../../proposals/providers/proposal_providers.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final role = ref.watch(currentUserRoleProvider);

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
        return _ProjectDetailView(project: project, role: role);
      },
    );
  }
}

class _ProjectDetailView extends ConsumerWidget {
  final ProjectModel project;
  final UserRole role;

  const _ProjectDetailView({required this.project, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isClient = role == UserRole.client;
    final tabs = isClient
        ? ['Overview', 'Proposals', 'Invoices', 'Files', 'Team', 'Activity']
        : ['Overview', 'Invoices', 'Files', 'Team', 'Activity'];

    return DefaultTabController(
      key: ValueKey(isClient),
      length: tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              actions: [
                if (isClient)
                  PopupMenuButton(
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit Project')),
                      PopupMenuItem(value: 'complete', child: Text('Complete Project')),
                    ],
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
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
                              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                            project.category,
                            style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabs.map((t) => Tab(text: t, iconMargin: EdgeInsets.zero)).toList(),
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OverviewTab(project: project),
              if (isClient) _ProposalsTab(projectId: project.id),
              _InvoicesTab(projectId: project.id),
              _FilesTab(projectId: project.id),
              const _PlaceholderTab(title: 'Team', icon: Icons.group_outlined),
              const _PlaceholderTab(title: 'Activity', icon: Icons.local_activity_outlined),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomActions(context, ref),
      ),
    );
  }

  Widget? _buildBottomActions(BuildContext context, WidgetRef ref) {
    final isClient = role == UserRole.client;
    final currentUser = ref.watch(currentUserProvider).value;
    final isAssignedToMe = project.freelancerUid == currentUser?.uid;
    
    if (project.status == ProjectStatus.open && !isClient && !isAssignedToMe) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => context.push('/proposals/create?projectId=${project.id}'),
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: const Text('Send Proposal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }
    
    if (project.status == ProjectStatus.active && !isClient && isAssignedToMe) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => context.push('/deliverables/upload?projectId=${project.id}'),
            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
            label: const Text('Submit Deliverable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }

    if (project.status == ProjectStatus.active && isClient) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text('Complete Project', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusActive,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      );
    }
    
    return null;
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No $title',
      subtitle: 'No content available for $title yet.',
      icon: icon,
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final ProjectModel project;

  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(project.description, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skills Required', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.skills.map((s) => Chip(
                    label: Text(s, style: AppTextStyles.labelSmall),
                    backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget (${project.pricingType.name})', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(project.budget), style: AppTextStyles.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deadline', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 4),
                      Text(DateFormatter.format(project.endDate), style: AppTextStyles.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // padding for bottom nav
        ],
      ),
    );
  }
}

class _ProposalsTab extends ConsumerWidget {
  final String projectId;

  const _ProposalsTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(projectProposalsProvider(projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return proposalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (proposals) {
        if (proposals.isEmpty) {
          return const EmptyState(title: 'No proposals', subtitle: 'No proposals received yet.', icon: Icons.inbox_outlined);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: proposals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final prop = proposals[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                            child: Text(
                              (prop['freelancerId'] as String? ?? 'F')[0].toUpperCase(),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Freelancer', style: AppTextStyles.titleSmall),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: prop['status'] == 'accepted' ? AppColors.statusActive.withValues(alpha: 0.1) : AppColors.borderLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  prop['status'] ?? 'pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: prop['status'] == 'accepted' ? AppColors.statusActive : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Bid Amount', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                          Text('\$${prop['bidAmount']}', style: AppTextStyles.titleMedium.copyWith(fontFamily: 'monospace')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Cover Letter', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 4),
                  Text(prop['coverLetter'] ?? '', style: AppTextStyles.bodySmall),
                  if (prop['status'] == 'pending') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        child: const Text('Accept Proposal'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  final String projectId;

  const _InvoicesTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(projectInvoicesProvider(projectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = ref.watch(currentUserRoleProvider);

    return invoicesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (invoices) {
        return Stack(
          children: [
            if (invoices.isEmpty)
              const EmptyState(title: 'No Invoices', subtitle: 'No invoices have been generated yet.', icon: Icons.receipt_long_outlined)
            else
              ListView.separated(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                itemCount: invoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final inv = invoices[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv.invoiceNumber, style: AppTextStyles.titleSmall),
                              const SizedBox(height: 4),
                              Text('Date: ${DateFormatter.format(inv.createdAt)}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: inv.status == InvoiceStatus.paid ? AppColors.statusActive.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  inv.status.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: inv.status == InvoiceStatus.paid ? AppColors.statusActive : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${inv.total.toStringAsFixed(2)}', style: AppTextStyles.titleLarge.copyWith(fontFamily: 'monospace')),
                            if (inv.status == InvoiceStatus.sent && role == UserRole.client) ...[
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Pay Now'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (role == UserRole.freelancer)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'invoice_fab',
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Generate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.primary,
                ),
              ),
          ],
        );
      },
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
      data: (deliverables) {
        if (deliverables.isEmpty) {
          return const EmptyState(title: 'No Deliverables', subtitle: 'No deliverables have been submitted yet.', icon: Icons.folder_open_outlined);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: deliverables.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final deliv = deliverables[i];
            final statusText = deliv['status'] == 'pending_review' ? 'Pending Review' : deliv['status'] ?? 'pending';
            final statusColor = deliv['status'] == 'approved' ? AppColors.statusActive : AppColors.warning;
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Deliverable', style: AppTextStyles.titleMedium),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          statusText,
                          style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (deliv['createdAt'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.format(DateTime.fromMillisecondsSinceEpoch(deliv['createdAt'] is int ? deliv['createdAt'] : 0)),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(deliv['description'] ?? '', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  Text('ATTACHED FILES', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (deliv['files'] as List<dynamic>? ?? []).map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.insert_drive_file_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(f.toString().split('/').last.split('?').first.substring(0, 15) + '...', style: AppTextStyles.labelSmall),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
