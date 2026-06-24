import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import '../../../core/widgets/empty_error_states.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_providers.dart';

import '../providers/chat_providers.dart';

class InboxListScreen extends ConsumerStatefulWidget {
  const InboxListScreen({super.key});

  @override
  ConsumerState<InboxListScreen> createState() => _InboxListScreenState();
}

class _InboxListScreenState extends ConsumerState<InboxListScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/chat/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final f in ['all', 'project', 'direct'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        f[0].toUpperCase() + f.substring(1),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: _filter == f
                              ? AppColors.primary
                              : Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: inboxAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(count: 4, itemHeight: 72),
              ),
              error: (e, _) => ErrorState(message: e.toString()),
              data: (conversations) {
                if (conversations.isEmpty) {
                  return EmptyState(
                    title: 'No Messages',
                    subtitle: 'Start a conversation with a client or team member',
                    lottieAsset: 'assets/lottie/no_messages.json',
                    actionLabel: 'New Message',
                    onAction: () => context.push('/chat/new'),
                  );
                }
                return ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
                  itemBuilder: (_, i) {
                    final conv = conversations[i];
                    final unread = conv.unreadCounts.values
                        .fold<int>(0, (s, v) => s + v);
                        
                    final user = ref.watch(currentUserProvider).valueOrNull;
                    final myName = user?.name ?? '';
                        
                    final otherName = conv.participantNames
                        .where((n) => n != myName)
                        .firstOrNull ?? conv.participantNames.firstOrNull ?? 'Unknown';

                    return Dismissible(
                      key: Key(conv.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.archive_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) {},
                      child: ListTile(
                        leading: AvatarWidget(name: otherName, size: 48),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(otherName, style: AppTextStyles.titleSmall),
                            ),
                            if (conv.projectName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  conv.projectName!.length > 12
                                      ? '${conv.projectName!.substring(0, 12)}…'
                                      : conv.projectName!,
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          conv.lastMessage ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontWeight: unread > 0 ? FontWeight.w600 : null,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _relativeTime(conv.lastMessageAt),
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                            if (unread > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unread.toString(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () => context.push('/chat/${conv.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
