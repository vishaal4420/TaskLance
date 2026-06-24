import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
import '../../../models/user.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      AppSnackBar.error(context, 'Invalid email or password. Please try again.');
    }
    // Navigation is handled automatically by GoRouter's redirect
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo mark
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text('Welcome back 👋', style: AppTextStyles.displayMedium),
                const SizedBox(height: 6),
                Text(
                  'Sign in to your TaskLance account',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 36),
                AppTextField(
                  key: const Key('email_field'),
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  key: const Key('password_field'),
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: true,
                  showPasswordToggle: true,
                  prefixIcon: Icons.lock_rounded,
                  validator: Validators.password,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  key: const Key('login_button'),
                  label: 'Log In',
                  onPressed: _signIn,
                  isLoading: authState.isLoading,
                  width: double.infinity,
                ),
                
                // Testing bypass buttons
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _emailCtrl.text = 'freelancer123@gmail.com';
                        _passwordCtrl.text = '12345678';
                      },
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('Fill Freelancer'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _emailCtrl.text = 'murali123@gmail.com';
                        _passwordCtrl.text = '12345678';
                      },
                      icon: const Icon(Icons.business, size: 16),
                      label: const Text('Fill Client'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    TextButton(
                      onPressed: () => context.go('/role-select'),
                      child: const Text('Sign up'),
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
