import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/firebase/firebase_service.dart';
import '../../auth/providers/auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _checking = false;
  int _countdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        if (mounted) setState(() => _countdown = 0);
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    await ref.read(firebaseServiceProvider).reloadUser();
    if (!mounted) return;
    setState(() => _checking = false);
    if (ref.read(firebaseServiceProvider).isEmailVerified) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'emailVerified': true});
        if (mounted) {
          if (user.role == UserRole.client) {
            context.go('/client-dashboard');
          } else {
            context.go('/profile-setup');
          }
        }
      } else {
        if (mounted) context.go('/');
      }
    } else {
      AppSnackBar.info(
          context, 'Email not verified yet. Please check your inbox.');
    }
  }

  Future<void> _resend() async {
    await ref.read(firebaseServiceProvider).sendEmailVerification();
    if (mounted) {
      AppSnackBar.success(context, 'Verification email resent!');
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(firebaseServiceProvider).currentUser;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.email_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Verify your email',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification email to\n${user?.email ?? ''}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'I\'ve verified my email',
                onPressed: _checkVerification,
                isLoading: _checking,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Center(
                child: _countdown > 0
                    ? Text(
                        'Resend in ${_countdown}s',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend verification email'),
                      ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Use a different account',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
