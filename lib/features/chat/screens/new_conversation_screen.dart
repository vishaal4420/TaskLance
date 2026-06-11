import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../providers/chat_providers.dart';

class NewConversationScreen extends ConsumerStatefulWidget {
  const NewConversationScreen({super.key});

  @override
  ConsumerState<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends ConsumerState<NewConversationScreen> {
  String _query = '';
  String? _projectId;
  String? _selectedUid;
  bool _isGroup = false;
  bool _isLoading = false;

  Future<void> _startConversation(UserModel otherUser, String myUid, String myName) async {
    setState(() => _isLoading = true);
    try {
      // Create new conversation
      final convId = const Uuid().v4();
      final conv = ConversationModel(
        id: convId,
        participantUids: [myUid, otherUser.uid],
        participantNames: [myName, otherUser.name],
        projectId: _projectId,
        projectName: _projectId != null ? "Project attached" : null, // ideally fetch real title
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        isGroup: _isGroup,
        groupName: _isGroup ? 'Group with ${otherUser.name}' : null,
      );

      await FirebaseFirestore.instance.collection('conversations').doc(convId).set(conv.toJson());
      if (mounted) context.pushReplacement('/chat/$convId');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final projectsAsync = ref.watch(dashboardProjectsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('New Conversation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchBar(
                  hintText: 'Search contacts...',
                  leading: const Icon(Icons.search),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _projectId,
                  decoration: InputDecoration(
                    labelText: 'Attach to project (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                  ),
                  items: projectsAsync.maybeWhen(
                    data: (projects) => projects.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.title, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    orElse: () => [],
                  ),
                  onChanged: (v) => setState(() => _projectId = v),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Group conversation'),
                  value: _isGroup,
                  onChanged: (v) => setState(() => _isGroup = v),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              loading: () => const ShimmerList(count: 5, itemHeight: 60),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (users) {
                final filteredUsers = users
                    .where((u) => _query.isEmpty || u.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();
                
                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No contacts found.'));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (_, i) {
                    final u = filteredUsers[i];
                    final selected = _selectedUid == u.uid;
                    return ListTile(
                      leading: AvatarWidget(name: u.name, url: u.avatarUrl, size: 44),
                      title: Text(u.name, style: AppTextStyles.titleSmall),
                      subtitle: Text(u.tagline ?? u.email, style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      tileColor: selected ? AppColors.primary.withOpacity(0.06) : null,
                      shape: selected
                          ? RoundedRectangleBorder(
                              side: const BorderSide(color: AppColors.primary, width: 1),
                              borderRadius: BorderRadius.circular(10))
                          : null,
                      onTap: () => setState(() => _selectedUid = u.uid),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Start Chat',
              isLoading: _isLoading,
              onPressed: _selectedUid == null || currentUser == null ? null : () {
                final contacts = contactsAsync.valueOrNull ?? [];
                final otherUser = contacts.firstWhere((u) => u.uid == _selectedUid);
                _startConversation(otherUser, currentUser.uid, currentUser.name);
              },
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
