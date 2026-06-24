import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';

final teamMembersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) async* {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.teamMemberUids.isEmpty) {
    yield [];
    return;
  }
  
  // Firestore limit is 10 for 'whereIn'. We can batch or just stream if small. 
  // For MVP, assuming team < 10.
  final chunk = user.teamMemberUids.take(10).toList();
  if (chunk.isEmpty) {
    yield [];
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('users')
      .where('uid', whereIn: chunk)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList());
});

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  Future<void> _showInviteDialog() async {
    final emailController = TextEditingController();
    bool isInviting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Invite Team Member'),
            content: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'colleague@example.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: isInviting ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isInviting
                    ? null
                    : () async {
                        final email = emailController.text.trim();
                        if (email.isEmpty) return;

                        setState(() => isInviting = true);
                        try {
                          final query = await FirebaseFirestore.instance
                              .collection('users')
                              .where('email', isEqualTo: email)
                              .limit(1)
                              .get();

                          if (query.docs.isEmpty) {
                            if (mounted) {
                              AppSnackBar.error(context, 'User not found with this email.');
                            }
                            setState(() => isInviting = false);
                            return;
                          }

                          final newMember = UserModel.fromJson(query.docs.first.data(), query.docs.first.id);
                          final currentUser = ref.read(currentUserProvider).valueOrNull;
                          if (currentUser == null) throw Exception('Not logged in');

                          if (currentUser.teamMemberUids.contains(newMember.uid)) {
                            if (mounted) {
                              AppSnackBar.info(context, 'User is already in your team.');
                            }
                            setState(() => isInviting = false);
                            return;
                          }

                          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                            'teamMemberUids': FieldValue.arrayUnion([newMember.uid])
                          });

                          if (!mounted) return;
                          Navigator.pop(context);
                          AppSnackBar.success(context, '${newMember.name} added to your team!');
                        } catch (e) {
                          if (mounted) {
                            AppSnackBar.error(context, 'Failed to invite: $e');
                          }
                          setState(() => isInviting = false);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: isInviting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send Invite'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showManageRoleSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage ${user.name}', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
              title: const Text('Change Role'),
              onTap: () {
                Navigator.pop(context);
                AppSnackBar.info(context, 'Role management coming in v2');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: AppColors.error),
              title: const Text('Remove from Team', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                final currentUser = ref.read(currentUserProvider).valueOrNull;
                if (currentUser != null) {
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                      'teamMemberUids': FieldValue.arrayRemove([user.uid])
                    });
                    if (mounted) AppSnackBar.success(context, '${user.name} removed from team');
                  } catch (e) {
                    if (mounted) AppSnackBar.error(context, 'Failed to remove user: $e');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final teamAsync = ref.watch(teamMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showInviteDialog,
          ),
        ],
      ),
      body: teamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (team) {
          if (team.isEmpty) {
            return const EmptyState(
              title: 'No Team Members',
              subtitle: 'Invite people to collaborate on projects.',
              icon: Icons.people_outline,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: team.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final user = team[i];
              return ListTile(
                leading: AvatarWidget(name: user.name, url: user.avatarUrl, size: 48),
                title: Text(user.name, style: AppTextStyles.titleSmall),
                subtitle: Text(user.role.name.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showManageRoleSheet(user)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
