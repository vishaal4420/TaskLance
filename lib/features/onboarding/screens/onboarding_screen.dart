import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      lottie: 'assets/lottie/onboard_1.json',
      title: 'Manage projects\neffortlessly',
      subtitle: 'One place for all your freelance work.\nOrganize, track, and deliver.',
    ),
    _OnboardingPage(
      lottie: 'assets/lottie/onboard_2.json',
      title: 'Track every\nmilestone',
      subtitle: 'Never miss a deadline again.\nStay on top of every deliverable.',
    ),
    _OnboardingPage(
      lottie: 'assets/lottie/onboard_3.json',
      title: 'Get paid\nfaster',
      subtitle: 'Automated invoices and payments.\nFocus on work, not admin.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background color based on page
    final List<Color> bgColors = [
      AppColors.primaryDark.withValues(alpha: 0.8),
      AppColors.secondary.withValues(alpha: 0.6),
      AppColors.primary.withValues(alpha: 0.8),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background Gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  bgColors[_currentPage].withValues(alpha: isDark ? 0.2 : 0.05),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      child: Text('Skip', style: AppTextStyles.labelLarge),
                    ),
                  ),
                ),
                
                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnboardingPageWidget(page: _pages[i]),
                  ),
                ),
                
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: _currentPage == i
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLast
                        ? Column(
                            key: const ValueKey('auth_buttons'),
                            children: [
                              AppButton(
                                label: 'Get Started',
                                onPressed: () => context.go('/signup'),
                                width: double.infinity,
                              ),
                              const SizedBox(height: 16),
                              AppButton(
                                label: 'Log in',
                                onPressed: () => context.go('/login'),
                                variant: AppButtonVariant.secondary,
                                width: double.infinity,
                              ),
                            ],
                          )
                        : AppButton(
                            key: const ValueKey('next_button'),
                            label: 'Next',
                            onPressed: _nextPage,
                            width: double.infinity,
                            icon: Icons.arrow_forward_rounded,
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String lottie;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.lottie,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Lottie with glowing background
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.05) 
                    : AppColors.primary.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Lottie.asset(page.lottie, width: 260, height: 260, repeat: true),
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: AppTextStyles.displayMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
