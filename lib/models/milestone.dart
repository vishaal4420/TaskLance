import 'package:cloud_firestore/cloud_firestore.dart';

enum MilestoneStatus { upcoming, inProgress, review, approved, revision, overdue }

class MilestoneModel {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final MilestoneStatus status;
  final double value;
  final DateTime dueDate;
  final String? assigneeUid;
  final List<String> taskIds;
  final int completedTasks;
  final int totalTasks;
  final DateTime createdAt;

  const MilestoneModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.value,
    required this.dueDate,
    this.assigneeUid,
    this.taskIds = const [],
    this.completedTasks = 0,
    this.totalTasks = 0,
    required this.createdAt,
  });

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && status != MilestoneStatus.approved;

  double get progressPercent =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  factory MilestoneModel.fromJson(Map<String, dynamic> json) => MilestoneModel(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: MilestoneStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MilestoneStatus.upcoming,
        ),
        value: (json['value'] as num).toDouble(),
        dueDate: json['dueDate'] is Timestamp
            ? (json['dueDate'] as Timestamp).toDate()
            : DateTime.parse(json['dueDate'] as String),
        assigneeUid: json['assigneeUid'] as String?,
        taskIds: List<String>.from(json['taskIds'] ?? []),
        completedTasks: json['completedTasks'] as int? ?? 0,
        totalTasks: json['totalTasks'] as int? ?? 0,
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        if (description != null) 'description': description,
        'status': status.name,
        'value': value,
        'dueDate': dueDate.toIso8601String(),
        if (assigneeUid != null) 'assigneeUid': assigneeUid,
        'taskIds': taskIds,
        'completedTasks': completedTasks,
        'totalTasks': totalTasks,
        'createdAt': createdAt.toIso8601String(),
      };
}
