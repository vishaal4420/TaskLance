import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/shimmer_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/message.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    _textCtrl.clear();

    final msgId = const Uuid().v4();
    final msg = MessageModel(
      id: msgId,
      conversationId: widget.conversationId,
      senderUid: user.uid,
      senderName: user.name,
      content: text,
      type: MessageType.text,
      isRead: false,
      createdAt: DateTime.now(),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final msgRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages')
          .doc(msgId);
      batch.set(msgRef, msg.toJson());
      
      final convRef = FirebaseFirestore.instance.collection('conversations').doc(widget.conversationId);
      batch.update(convRef, {
        'lastMessage': text,
        'lastMessageAt': msg.createdAt.toIso8601String(),
      });
      
      await batch.commit();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to send message: $e');
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final conversations = ref.watch(inboxProvider).valueOrNull ?? [];
    
    // Find the conversation from the inbox list
    final conversation = conversations.where((c) => c.id == widget.conversationId).firstOrNull;
    
    final otherName = conversation?.participantNames
            .where((n) => n != currentUser?.name)
            .firstOrNull ??
        'Contact';

    final messagesAsync = ref.watch(chatMessagesProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherName, style: AppTextStyles.titleMedium),
            Text('Online',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Project context card
          if (conversation?.projectName != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(conversation!.projectName!,
                      style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.statusActive.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Active',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.statusActive)),
                  ),
                ],
              ),
            ),
          // Messages
          Expanded(
            child: messagesAsync.when(
              loading: () => const ShimmerList(count: 6, itemHeight: 80),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text('No messages yet. Say hi!', 
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight)),
                  );
                }
                
                // Sort messages descending for reverse ListView
                final sortedMessages = List<MessageModel>.from(messages)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  
                return ListView.builder(
                  controller: _scrollCtrl,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: sortedMessages.length,
                  itemBuilder: (_, i) {
                    final msg = sortedMessages[i];
                    final isMe = msg.senderUid == currentUser?.uid;
                    return _MessageBubble(msg: msg, isMe: isMe, timeStr: _formatTime(msg.createdAt));
                  },
                );
              },
            ),
          ),
          // Input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded),
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.single;
                        if (file.path == null) return;
                        
                        try {
                          final appDir = await getApplicationDocumentsDirectory();
                          final chatDir = Directory('${appDir.path}/chat_attachments/${widget.conversationId}');
                          if (!await chatDir.exists()) {
                            await chatDir.create(recursive: true);
                          }
                          
                          final newPath = '${chatDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
                          await File(file.path!).copy(newPath);
                          final downloadUrl = newPath;
                          
                          _textCtrl.text = downloadUrl;
                          _send();
                          
                          if (context.mounted) {
                            AppSnackBar.success(context, 'File attached and sent!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackBar.error(context, 'Failed to upload file: $e');
                          }
                        }
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;
  final String timeStr;

  const _MessageBubble({required this.msg, required this.isMe, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 40),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Builder(
                    builder: (context) {
                      final isFile = msg.content.contains('chat_attachments');
                      final lower = msg.content.toLowerCase();
                      final isImage = isFile && (lower.endsWith('.jpg') || lower.endsWith('.png') || lower.endsWith('.jpeg'));

                      if (isImage) {
                        final isNetwork = msg.content.startsWith('http');
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isNetwork 
                            ? Image.network(
                                msg.content,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                              )
                            : Image.file(
                                File(msg.content),
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                              ),
                        );
                      } else if (isFile) {
                        // Extract filename by splitting by slashes and taking everything after the first underscore
                        final rawName = msg.content.split(RegExp(r'[\\/]')).last;
                        final parts = rawName.split('_');
                        final fileName = parts.length > 1 ? parts.sublist(1).join('_') : rawName;
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.insert_drive_file, color: isMe ? Colors.white : AppColors.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                fileName.isEmpty ? 'File' : fileName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }

                      return Text(
                        msg.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isMe
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                      );
                    }
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }
}
