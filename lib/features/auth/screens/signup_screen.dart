import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../../../models/user.dart';
import '../providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  UserRole _role = UserRole.freelancer;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  double _passwordStrength(String p) {
    if (p.isEmpty) return 0;
    double score = 0;
    if (p.length >= 8) score += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) score += 0.25;
    return score;
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return AppColors.error;
    if (s <= 0.5) return AppColors.warning;
    if (s <= 0.75) return Colors.amber;
    return AppColors.secondary;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    
    
    await ref
        .read(authNotifierProvider.notifier)
        .signUp(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text, _role);
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      AppSnackBar.error(context, 'Failed to create account. Please try again.');
    }
    // Navigation is handled automatically by GoRouter's redirect
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final strength = _passwordStrength(_passwordCtrl.text);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text('Create account', style: AppTextStyles.displayMedium),
                const SizedBox(height: 6),
                Text(
                  'Join thousands of freelancers and clients',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 28),
                // Role selector
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                      value: UserRole.freelancer,
                      label: Text('Freelancer'),
                      icon: Icon(Icons.work_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: UserRole.client,
                      label: Text('Client'),
                      icon: Icon(Icons.business_rounded, size: 18),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) =>
                      setState(() => _role = s.first),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full Name',
                  hint: 'Alex Rivera',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, label: 'Name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  prefixIcon: Icons.lock_rounded,
                  obscureText: true,
                  showPasswordToggle: true,
                  validator: Validators.password,
                  onChanged: (_) => setState(() {}),
                ),
                if (_passwordCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: strength,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strength <= 0.25
                        ? 'Weak'
                        : strength <= 0.5
                            ? 'Fair'
                            : strength <= 0.75
                                ? 'Good'
                                : 'Strong',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _strengthColor(strength),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmCtrl,
                  prefixIcon: Icons.lock_rounded,
                  obscureText: true,
                  showPasswordToggle: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Create Account',
                  onPressed: _createAccount,
                  isLoading: authState.isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
