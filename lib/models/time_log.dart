class TimeLogModel {
  final String id;
  final String taskId;
  final String projectId;
  final String userId;
  final String taskName;
  final String projectName;
  final Duration duration;
  final DateTime loggedAt;
  final String? notes;

  const TimeLogModel({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.userId,
    required this.taskName,
    required this.projectName,
    required this.duration,
    required this.loggedAt,
    this.notes,
  });

  factory TimeLogModel.fromJson(Map<String, dynamic> json) => TimeLogModel(
        id: json['id'] as String,
        taskId: json['taskId'] as String,
        projectId: json['projectId'] as String,
        userId: json['userId'] as String,
        taskName: json['taskName'] as String,
        projectName: json['projectName'] as String,
        duration: Duration(minutes: json['durationMinutes'] as int),
        loggedAt: DateTime.parse(json['loggedAt'] as String),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'projectId': projectId,
        'userId': userId,
        'taskName': taskName,
        'projectName': projectName,
        'durationMinutes': duration.inMinutes,
        'loggedAt': loggedAt.toIso8601String(),
        if (notes != null) 'notes': notes,
      };
}
