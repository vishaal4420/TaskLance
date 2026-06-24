import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/validators.dart';
import 'package:uuid/uuid.dart';
import '../../../models/project.dart';
import '../../../data/repositories/project_repository.dart';
import '../../auth/providers/auth_providers.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _step = 1;
  bool _loading = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  
  PricingType _pricingType = PricingType.fixedPrice;
  DateTime? _deadline;

  @override
  void dispose() {
    _pageController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    _skillsCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _nextStep() {
    if (_step == 1) {
      if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty || _categoryCtrl.text.trim().isEmpty) {
        AppSnackBar.error(context, 'Please fill in title, description, and category.');
        return;
      }
    } else if (_step == 2) {
      final budget = double.tryParse(_budgetCtrl.text);
      if (budget == null || budget <= 0) {
        AppSnackBar.error(context, 'Please provide a valid estimated budget.');
        return;
      }
    }
    
    if (_step < 3) {
      setState(() => _step++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_step > 1) {
      setState(() => _step--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('Not logged in');

      final projectId = const Uuid().v4();
      final parsedSkills = _skillsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

      final project = ProjectModel(
        id: projectId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        skills: parsedSkills,
        freelancerUid: null,
        clientUid: user.uid,
        clientName: user.name,
        clientAvatarUrl: user.avatarUrl,
        status: ProjectStatus.open,
        pricingType: _pricingType,
        budget: double.tryParse(_budgetCtrl.text) ?? 0.0,
        startDate: DateTime.now(),
        endDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      await ref.read(projectRepositoryProvider).createProject(project);
      
      if (!mounted) return;
      AppSnackBar.success(context, 'Project posted successfully!');
      context.pop();
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to create project: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [1, 2, 3].map((num) {
          final isActive = _step >= num;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                  shape: BoxShape.circle,
                  border: Border.all(color: isActive ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight)),
                ),
                child: Center(
                  child: _step > num 
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          num.toString(),
                          style: AppTextStyles.titleMedium.copyWith(color: isActive ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                num == 1 ? 'Details' : (num == 2 ? 'Budget' : 'Review'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Project Details', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Project Title',
          hint: 'e.g. Build a responsive React dashboard',
          controller: _titleCtrl,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Description',
          hint: 'Describe your project in detail...',
          controller: _descCtrl,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: 'Category',
                hint: 'e.g. Web Dev',
                controller: _categoryCtrl,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                label: 'Skills',
                hint: 'React, Tailwind',
                controller: _skillsCtrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Budget & Timeline', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _pricingType = PricingType.fixedPrice),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _pricingType == PricingType.fixedPrice ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _pricingType == PricingType.fixedPrice ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: _pricingType == PricingType.fixedPrice ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fixed Price', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text('Pay a set amount', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _pricingType = PricingType.hourly),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _pricingType == PricingType.hourly ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _pricingType == PricingType.hourly ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: _pricingType == PricingType.hourly ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hourly Rate', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text('Pay for hours', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Estimated Budget (\$)',
          hint: '1500',
          controller: _budgetCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _DatePickerField(
          label: 'Deadline',
          date: _deadline,
          onTap: _pickDeadline,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Attachments & Review', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.upload_file, color: AppColors.textSecondaryLight, size: 24),
              ),
              const SizedBox(height: 16),
              Text('Tap to upload files', style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text('(Max 50MB)', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildReviewRow('Title', _titleCtrl.text.isEmpty ? 'Untitled' : _titleCtrl.text),
              const SizedBox(height: 12),
              _buildReviewRow('Budget', '\$${_budgetCtrl.text.isEmpty ? "0" : _budgetCtrl.text}'),
              const SizedBox(height: 12),
              _buildReviewRow('Timeline', _deadline != null ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}' : 'TBD'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Project'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  if (_step > 1)
                    Expanded(
                      child: AppButton(
                        label: 'Back',
                        onPressed: _prevStep,
                        variant: AppButtonVariant.ghost,
                      ),
                    ),
                  if (_step > 1) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _step < 3 ? 'Next' : 'Post Project',
                      onPressed: _step < 3 ? _nextStep : _create,
                      isLoading: _loading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
              const SizedBox(width: 12),
              Text(
                date == null
                    ? 'Select Date'
                    : '${date!.day}/${date!.month}/${date!.year}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: date == null
                      ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
