import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum NotificationType {
  milestoneApproved,
  paymentReceived,
  revisionRequested,
  message,
  deadline,
  newAssignment,
  statusChanged,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? deepLink;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.deepLink,
    this.isRead = false,
    required this.createdAt,
  });

  Color get typeColor {
    switch (type) {
      case NotificationType.milestoneApproved:
        return AppColors.secondary;
      case NotificationType.paymentReceived:
        return AppColors.success;
      case NotificationType.revisionRequested:
        return AppColors.warning;
      case NotificationType.message:
        return AppColors.primary;
      case NotificationType.deadline:
        return AppColors.error;
      case NotificationType.newAssignment:
        return AppColors.info;
      case NotificationType.statusChanged:
        return AppColors.textSecondaryLight;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.milestoneApproved:
        return Icons.check_circle_rounded;
      case NotificationType.paymentReceived:
        return Icons.payments_rounded;
      case NotificationType.revisionRequested:
        return Icons.edit_note_rounded;
      case NotificationType.message:
        return Icons.chat_bubble_rounded;
      case NotificationType.deadline:
        return Icons.schedule_rounded;
      case NotificationType.newAssignment:
        return Icons.assignment_rounded;
      case NotificationType.statusChanged:
        return Icons.swap_horiz_rounded;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.statusChanged,
        ),
        deepLink: json['deepLink'] as String?,
        isRead: json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type.name,
        if (deepLink != null) 'deepLink': deepLink,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}
