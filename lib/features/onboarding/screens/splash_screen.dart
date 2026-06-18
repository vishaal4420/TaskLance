import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../models/user.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _introCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    
    // Intro animations (logo popping in, text sliding up)
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Sped up from 1200ms
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack),
    );
    
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _introCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );

    _introCtrl.forward();

    // Progress bar animation
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Sped up from 2500ms
    )..forward();

    // Reduce artificial delay from 2.8s to 1.1s
    Future.delayed(const Duration(milliseconds: 1100), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      final role = ref.read(currentUserRoleProvider);
      if (role == UserRole.client) {
        context.go('/client-dashboard');
      } else {
        context.go('/dashboard');
      }
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.secondary,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/lottie/logo_anim.json',
                      width: 140,
                      height: 140,
                      repeat: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        'TaskLance',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          fontSize: 42,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Freelance, simplified.',
                        style: AppTextStyles.tagline.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnim,
                child: AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (_, __) => Column(
                    children: [
                      Container(
                        width: 160,
                        height: 4,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: _progressCtrl.value,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryLight.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 54),
                    ],
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
