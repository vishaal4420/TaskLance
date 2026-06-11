import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/utils/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/user.dart';
import '../../../models/project.dart';
import '../../../models/notification_model.dart';
import '../../../data/repositories/project_repository.dart';
import '../../auth/providers/auth_providers.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  PricingType _pricingType = PricingType.fixedPrice;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) throw Exception('Not logged in');

      final projectId = const Uuid().v4();
      final project = ProjectModel(
        id: projectId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        freelancerUid: null, // No freelancer assigned initially
        clientUid: user.uid,
        clientName: user.name,
        clientAvatarUrl: user.avatarUrl,
        status: ProjectStatus.open, // Starts as open
        pricingType: _pricingType,
        budget: double.tryParse(_budgetCtrl.text) ?? 0.0,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              label: 'Project Title',
              hint: 'e.g. Mobile App Redesign',
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.required(v, label: 'Title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              hint: 'Describe the project scope and goals...',
              controller: _descCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Date pickers
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Budget',
              hint: '0.00',
              controller: _budgetCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money_rounded,
            ),
            const SizedBox(height: 16),
            // Pricing type
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pricing Type',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                const SizedBox(height: 8),
                SegmentedButton<PricingType>(
                  segments: const [
                    ButtonSegment(
                        value: PricingType.fixedPrice,
                        label: Text('Fixed Price')),
                    ButtonSegment(
                        value: PricingType.hourly,
                        label: Text('Hourly')),
                  ],
                  selected: {_pricingType},
                  onSelectionChanged: (s) =>
                      setState(() => _pricingType = s.first),
                ),
              ],
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Create Project',
              onPressed: _create,
              isLoading: _loading,
              width: double.infinity,
            ),
            const SizedBox(height: 40),
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
                  .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Text(
                date == null
                    ? 'Select'
                    : '${date!.day}/${date!.month}/${date!.year}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: date == null
                      ? AppColors.textSecondaryLight
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
