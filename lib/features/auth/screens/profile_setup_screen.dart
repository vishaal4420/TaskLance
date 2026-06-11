import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../../../core/firebase/firebase_service.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  final List<String> _skills = ['Flutter', 'Dart'];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text =
        ref.read(firebaseServiceProvider).currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _rateCtrl.dispose();
    _companyCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  void _addSkill(String s) {
    if (s.trim().isNotEmpty && !_skills.contains(s.trim())) {
      setState(() => _skills.add(s.trim()));
    }
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final uid = ref.read(firebaseServiceProvider).currentUser?.uid;
      if (uid != null) {
        await ref.read(firebaseServiceProvider).updateUserDocument(uid, {
          'name': _nameCtrl.text.trim(),
          'bio': _bioCtrl.text.trim(),
          'skills': _skills,
          if (_rateCtrl.text.isNotEmpty)
            'hourlyRate': double.tryParse(_rateCtrl.text),
          if (_companyCtrl.text.isNotEmpty)
            'companyName': _companyCtrl.text.trim(),
        });
      }
      if (mounted) context.go('/dashboard');
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'Failed to save profile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Skip for now'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar picker
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 44),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform.pickFiles(type: FileType.image);
                              if (result != null && context.mounted) {
                                AppSnackBar.success(context, 'Avatar selected: ${result.files.single.name}');
                              }
                            },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text('Tell us about yourself',
                    style: AppTextStyles.headlineMedium),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Display Name',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, label: 'Name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Bio',
                  controller: _bioCtrl,
                  maxLines: 3,
                  hint: 'Tell clients about your expertise...',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Hourly Rate (\$)',
                  controller: _rateCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money_rounded,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Company Name (optional)',
                  controller: _companyCtrl,
                  prefixIcon: Icons.business_rounded,
                ),
                const SizedBox(height: 20),
                // Skills
                Text('Skills', style: AppTextStyles.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._skills.map((s) => Chip(
                          label: Text(s),
                          onDeleted: () => setState(() => _skills.remove(s)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        )),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('Add skill'),
                      onPressed: () => _showAddSkill(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Finish Setup',
                  onPressed: _finish,
                  isLoading: _loading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSkill() {
    _skillCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Skill'),
        content: TextField(
          controller: _skillCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'e.g. Flutter, React...'),
          onSubmitted: (s) {
            _addSkill(s);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              _addSkill(_skillCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
