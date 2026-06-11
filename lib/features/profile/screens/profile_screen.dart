import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../models/user.dart';

final profileUserProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((doc) {
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  });
});

class ProfileScreen extends ConsumerWidget {
  final String uid;

  const ProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicUser = ref.watch(currentUserProvider).valueOrNull;
    final isLookingForSelf = uid == 'seed_freelancer_001' || uid == 'seed_client_001' || uid == 'dynamic_user_001' || uid == dynamicUser?.uid;
    
    // Determine the actual UID to query
    final queryUid = isLookingForSelf ? (dynamicUser?.uid ?? uid) : uid;
    final userAsync = ref.watch(profileUserProvider(queryUid));
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (user) {
          if (user == null) return const ErrorState(message: 'User not found');
          
          final isOwner = dynamicUser?.uid == user.uid;

          return ResponsiveWrapper(
            child: CustomScrollView(
              slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                actions: [
                  if (isOwner) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => context.push('/profile/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Beautiful gradient background
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Abstract decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -100,
                        left: -50,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Profile info
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              ),
                              child: AvatarWidget(name: user.name, url: user.avatarUrl, size: 100),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                            ),
                            if (user.tagline != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.tagline!,
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.rating.toStringAsFixed(1),
                                    style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    ' (${user.reviewCount})',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Row
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  title: 'Projects',
                                  value: user.projectsCompleted.toString(),
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.primary,
                                ),
                                Container(width: 1, height: 40, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                _StatItem(
                                  title: 'On-Time',
                                  value: '${(user.onTimePercent * 100).toInt()}%',
                                  icon: Icons.timer_outlined,
                                  color: AppColors.secondary,
                                ),
                                Container(width: 1, height: 40, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                _StatItem(
                                  title: 'Rate',
                                  value: '\$${user.hourlyRate?.toInt() ?? 0}/h',
                                  icon: Icons.payments_outlined,
                                  color: AppColors.warning,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // About
                          if (user.bio != null) ...[
                            Text('About', style: AppTextStyles.headlineSmall),
                            const SizedBox(height: 12),
                            Text(
                              user.bio!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Skills
                          if (user.skills.isNotEmpty) ...[
                            Text('Skills', style: AppTextStyles.headlineSmall),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: user.skills.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Text(
                                  s,
                                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                                ),
                              )).toList(),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Settings list
                          if (isOwner) ...[
                            Text('Settings', style: AppTextStyles.headlineSmall),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                              child: Column(
                                children: [
                                  _MenuTile(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Edit Profile',
                                    subtitle: 'Update your personal details',
                                    onTap: () => context.push('/profile/edit'),
                                  ),
                                  _Divider(),
                                  _MenuTile(
                                    icon: Icons.description_outlined,
                                    title: 'My Proposals',
                                    subtitle: 'Manage your submitted proposals',
                                    onTap: () => context.push('/proposals'),
                                  ),
                                  _Divider(),
                                  _MenuTile(
                                    icon: Icons.payment_rounded,
                                    title: 'Billing & Plans',
                                    subtitle: 'Manage subscriptions and payment methods',
                                    onTap: () => context.push('/profile/billing'),
                                  ),
                                  _Divider(),
                                  _MenuTile(
                                    icon: Icons.group_outlined,
                                    title: 'Team Management',
                                    subtitle: 'Add or remove team members',
                                    onTap: () => context.push('/profile/team'),
                                  ),
                                  _Divider(),
                                  _MenuTile(
                                    icon: Icons.support_agent_rounded,
                                    title: 'Help & Support',
                                    subtitle: 'Get assistance or report an issue',
                                    onTap: () => context.push('/profile/support'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Sign out button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                                label: Text(
                                  'Sign Out',
                                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  foregroundColor: AppColors.error,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(value, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(title, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}
