import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../../models/user.dart';
import '../../features/auth/providers/auth_providers.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard') ||
        location.startsWith('/client-dashboard')) {
      return 0;
    }
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/proposals')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/settings')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _selectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          // Web/Desktop layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: idx,
                  onDestinationSelected: (int index) {
                    _onNavigate(context, ref, index);
                  },
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  selectedIconTheme: const IconThemeData(color: AppColors.primary),
                  unselectedIconTheme: const IconThemeData(color: AppColors.textSecondaryLight),
                  selectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                  unselectedLabelTextStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_rounded),
                      label: Text('Projects'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_rounded),
                      label: Text('Messages'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.description_outlined),
                      label: Text('Proposals'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_rounded),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }

        // Mobile layout
        return Scaffold(
          body: child,
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark.withOpacity(0.9) : AppColors.surfaceLight.withOpacity(0.9),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.2) : AppColors.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      selected: idx == 0,
                      onTap: () => _onNavigate(context, ref, 0),
                    ),
                    _NavItem(
                      icon: Icons.folder_rounded,
                      label: 'Projects',
                      selected: idx == 1,
                      onTap: () => _onNavigate(context, ref, 1),
                    ),
                    _NavItem(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Messages',
                      selected: idx == 2,
                      onTap: () => _onNavigate(context, ref, 2),
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      label: 'Proposals',
                      selected: idx == 3,
                      onTap: () => _onNavigate(context, ref, 3),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      selected: idx == 4,
                      onTap: () => _onNavigate(context, ref, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  void _onNavigate(BuildContext context, WidgetRef ref, int index) {
    switch (index) {
      case 0:
        final role = ref.read(currentUserRoleProvider);
        if (role == UserRole.client) {
          context.go('/client-dashboard');
        } else {
          context.go('/dashboard');
        }
        break;
      case 1:
        context.go('/projects');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/proposals');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondaryLight,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
