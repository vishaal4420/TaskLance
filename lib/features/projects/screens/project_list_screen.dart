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
import '../../dashboard/providers/dashboard_providers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  String _searchQuery = '';
  String _activeTab = 'All';
  String _budgetType = 'All'; // All, Fixed Price, Hourly Rate
  double? _minBudget;
  double? _maxBudget;

  final _searchCtrl = TextEditingController();
  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();

  final List<String> _tabs = ['All', 'In Progress', 'Open', 'Completed'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    super.dispose();
  }

  List<ProjectModel> _filtered(List<ProjectModel> all) {
    return all.where((project) {
      final matchesSearch = _searchQuery.isEmpty ||
          project.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.skills.any(
              (s) => s.toLowerCase().contains(_searchQuery.toLowerCase()));

      bool matchesTab = true;
      if (_activeTab == 'In Progress') {
        matchesTab = project.status == ProjectStatus.active;
      } else if (_activeTab == 'Open') {
        matchesTab = project.status == ProjectStatus.open;
      } else if (_activeTab == 'Completed') {
        matchesTab = project.status == ProjectStatus.completed;
      }

      bool matchesBudgetType = true;
      if (_budgetType == 'Fixed Price') {
        matchesBudgetType = project.pricingType == PricingType.fixedPrice;
      } else if (_budgetType == 'Hourly Rate') {
        matchesBudgetType = project.pricingType == PricingType.hourly;
      }

      final matchesMin = _minBudget == null || project.budget >= _minBudget!;
      final matchesMax = _maxBudget == null || project.budget <= _maxBudget!;

      return matchesSearch &&
          matchesTab &&
          matchesBudgetType &&
          matchesMin &&
          matchesMax;
    }).toList();
  }

  void _showFilterModal() {
    // Populate controllers with current state
    _minBudgetCtrl.text = _minBudget != null ? _minBudget.toString() : '';
    _maxBudgetCtrl.text = _maxBudget != null ? _maxBudget.toString() : '';
    
    // Local state for the modal
    String tempBudgetType = _budgetType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final border = isDark ? AppColors.borderDark : AppColors.borderLight;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Advanced Filters',
                              style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Budget Type', style: AppTextStyles.titleMedium.copyWith(color: textPrimary)),
                    const SizedBox(height: 12),
                    Column(
                      children: ['All', 'Fixed Price', 'Hourly Rate'].map((type) {
                        final isSelected = tempBudgetType == type;
                        return InkWell(
                          onTap: () => setModalState(() => tempBudgetType = type),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : border,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: type,
                                  groupValue: tempBudgetType,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => tempBudgetType = val);
                                    }
                                  },
                                ),
                                Text(type, style: AppTextStyles.bodyMedium.copyWith(color: textPrimary)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Budget Range (\$)', style: AppTextStyles.titleMedium.copyWith(color: textPrimary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: '',
                            controller: _minBudgetCtrl,
                            hint: 'Min',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('-'),
                        ),
                        Expanded(
                          child: AppTextField(
                            label: '',
                            controller: _maxBudgetCtrl,
                            hint: 'Max',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _budgetType = 'All';
                                _minBudget = null;
                                _maxBudget = null;
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Apply Filters',
                            onPressed: () {
                              setState(() {
                                _budgetType = tempBudgetType;
                                _minBudget = double.tryParse(_minBudgetCtrl.text);
                                _maxBudget = double.tryParse(_maxBudgetCtrl.text);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(dashboardProjectsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    
    final bool hasActiveFilters = _budgetType != 'All' || _minBudget != null || _maxBudget != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardProjectsProvider),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Projects', style: AppTextStyles.displayLarge.copyWith(color: textPrimary, fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your projects and discover new opportunities.',
                          style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Search bar
                    AppTextField(
                      label: '',
                      controller: _searchCtrl,
                      hint: 'Search projects by title or skills...',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 16),
                    // Tabs and Filter button
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _tabs.map((tab) {
                                final isSelected = _activeTab == tab;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(tab),
                                    selected: isSelected,
                                    onSelected: (_) => setState(() => _activeTab = tab),
                                    selectedColor: AppColors.primary.withOpacity(0.1),
                                    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    labelStyle: AppTextStyles.labelMedium.copyWith(
                                      color: isSelected ? AppColors.primary : textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                      ),
                                    ),
                                    showCheckmark: false,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _showFilterModal,
                              icon: const Icon(Icons.tune_rounded, size: 18),
                              label: const Text('Filters'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                            ),
                            if (hasActiveFilters)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            projectsAsync.when(
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const ShimmerList(count: 3, itemHeight: 180),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.refresh(dashboardProjectsProvider),
                ),
              ),
              data: (projects) {
                final filtered = _filtered(projects);
                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No projects found matching your criteria.',
                            style: AppTextStyles.titleMedium.copyWith(color: textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProjectCard(
                            project: filtered[i],
                            onTap: () => context.push('/projects/${filtered[i].id}'),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
