import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderUid;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderUid,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, [String? docId]) => MessageModel(
        id: (json['id'] as String?) ?? docId ?? '',
        conversationId: json['conversationId'] as String? ?? '',
        senderUid: (json['senderUid'] as String?) ?? (json['senderId'] as String?) ?? '',
        senderName: json['senderName'] as String? ?? 'Unknown',
        senderAvatarUrl: json['senderAvatarUrl'] as String?,
        content: (json['content'] as String?) ?? (json['text'] as String?) ?? '',
        type: MessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MessageType.text,
        ),
        fileUrl: json['fileUrl'] as String?,
        fileName: json['fileName'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: (json['createdAt'] ?? json['timestamp']) is Timestamp
            ? ((json['createdAt'] ?? json['timestamp']) as Timestamp).toDate()
            : ((json['createdAt'] ?? json['timestamp']) is int
                ? DateTime.fromMillisecondsSinceEpoch((json['createdAt'] ?? json['timestamp']) as int)
                : ((json['createdAt'] ?? json['timestamp']) is String
                    ? DateTime.parse((json['createdAt'] ?? json['timestamp']) as String)
                    : DateTime.now())),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'senderUid': senderUid,
        'senderName': senderName,
        if (senderAvatarUrl != null) 'senderAvatarUrl': senderAvatarUrl,
        'content': content,
        'type': type.name,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileName != null) 'fileName': fileName,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ConversationModel {
  final String id;
  final List<String> participantUids;
  final List<String> participantNames;
  final String? projectId;
  final String? projectName;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCounts;
  final bool isGroup;
  final String? groupName;

  const ConversationModel({
    required this.id,
    required this.participantUids,
    required this.participantNames,
    this.projectId,
    this.projectName,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCounts = const {},
    this.isGroup = false,
    this.groupName,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, [String? docId]) =>
      ConversationModel(
        id: (json['id'] as String?) ?? docId ?? '',
        participantUids: List<String>.from(json['participantUids'] ?? json['participants'] ?? []),
        participantNames: List<String>.from(json['participantNames'] ?? []),
        projectId: json['projectId'] as String?,
        projectName: json['projectName'] as String?,
        lastMessage: json['lastMessage'] as String? ?? '',
        lastMessageAt: json['lastMessageAt'] != null
            ? (json['lastMessageAt'] is Timestamp
                ? (json['lastMessageAt'] as Timestamp).toDate()
                : (json['lastMessageAt'] is int
                    ? DateTime.fromMillisecondsSinceEpoch(json['lastMessageAt'] as int)
                    : (json['lastMessageAt'] is String
                        ? DateTime.parse(json['lastMessageAt'] as String)
                        : DateTime.now())))
            : (json['updatedAt'] != null
                ? (json['updatedAt'] is int
                    ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
                    : DateTime.now())
                : DateTime.now()),
        unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
        isGroup: json['isGroup'] as bool? ?? false,
        groupName: json['groupName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantUids': participantUids,
        'participantNames': participantNames,
        if (projectId != null) 'projectId': projectId,
        if (projectName != null) 'projectName': projectName,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt.toIso8601String(),
        'unreadCounts': unreadCounts,
        'isGroup': isGroup,
        if (groupName != null) 'groupName': groupName,
      };
}
