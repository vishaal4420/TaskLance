import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { todo, inProgress, inReview, done }

enum TaskPriority { low, medium, high }

class TaskSubtask {
  final String id;
  final String title;
  final bool isCompleted;

  const TaskSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory TaskSubtask.fromJson(Map<String, dynamic> json) => TaskSubtask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  TaskSubtask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return TaskSubtask(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TaskActivity {
  final String id;
  final String text;
  final DateTime timestamp;
  final String icon;

  const TaskActivity({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.icon,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) => TaskActivity(
        id: json['id'] as String,
        text: json['text'] as String,
        timestamp: json['timestamp'] is Timestamp
            ? (json['timestamp'] as Timestamp).toDate()
            : DateTime.parse(json['timestamp'] as String),
        icon: json['icon'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'icon': icon,
      };
}

class TaskModel {
  final String id;
  final String projectId;
  final String? milestoneId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeUid;
  final String? assigneeName;
  final String? assigneeAvatarUrl;
  final DateTime? dueDate;
  final List<String> attachmentUrls;
  final List<TaskSubtask> subtasks;
  final List<TaskActivity> activities;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.projectId,
    this.milestoneId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeUid,
    this.assigneeName,
    this.assigneeAvatarUrl,
    this.dueDate,
    this.attachmentUrls = const [],
    this.subtasks = const [],
    this.activities = const [],
    required this.createdAt,
  });

  static TaskStatus _parseStatus(dynamic val) {
    if (val == null) return TaskStatus.todo;
    final str = val.toString();
    switch (str) {
      case 'todo': return TaskStatus.todo;
      case 'in-progress': return TaskStatus.inProgress;
      case 'in-review': return TaskStatus.inReview;
      case 'done': return TaskStatus.done;
      // Fallback for old data
      case 'inProgress': return TaskStatus.inProgress;
      case 'inReview': return TaskStatus.inReview;
      default: return TaskStatus.todo;
    }
  }

  static String _statusToColumnId(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return 'todo';
      case TaskStatus.inProgress: return 'in-progress';
      case TaskStatus.inReview: return 'in-review';
      case TaskStatus.done: return 'done';
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        milestoneId: json['milestoneId'] as String?,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        status: _parseStatus(json['columnId'] ?? json['status']),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        assigneeUid: json['assigneeUid'] as String?,
        assigneeName: json['assigneeName'] as String?,
        assigneeAvatarUrl: json['assigneeAvatarUrl'] as String?,
        dueDate: json['dueDate'] == null
            ? null
            : json['dueDate'] is Timestamp
                ? (json['dueDate'] as Timestamp).toDate()
                : DateTime.parse(json['dueDate'] as String),
        attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((e) => TaskSubtask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        activities: (json['activities'] as List<dynamic>?)
                ?.map((e) => TaskActivity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        if (milestoneId != null) 'milestoneId': milestoneId,
        'title': title,
        'description': description,
        'columnId': _statusToColumnId(status),
        'priority': priority.name,
        if (assigneeUid != null) 'assigneeUid': assigneeUid,
        if (assigneeName != null) 'assigneeName': assigneeName,
        if (assigneeAvatarUrl != null) 'assigneeAvatarUrl': assigneeAvatarUrl,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        'attachmentUrls': attachmentUrls,
        'subtasks': subtasks.map((e) => e.toJson()).toList(),
        'activities': activities.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  TaskModel copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    String? title,
    List<TaskSubtask>? subtasks,
    List<TaskActivity>? activities,
  }) =>
      TaskModel(
        id: id,
        projectId: projectId,
        milestoneId: milestoneId,
        title: title ?? this.title,
        description: description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        assigneeUid: assigneeUid,
        assigneeName: assigneeName,
        assigneeAvatarUrl: assigneeAvatarUrl,
        dueDate: dueDate,
        attachmentUrls: attachmentUrls,
        subtasks: subtasks ?? this.subtasks,
        activities: activities ?? this.activities,
        createdAt: createdAt,
      );
}
