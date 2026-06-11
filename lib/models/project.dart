import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { open, active, completed, onHold, archived }

enum PricingType { fixedPrice, hourly }

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String? freelancerUid;
  final String clientUid;
  final String? clientName;
  final String? clientAvatarUrl;
  final ProjectStatus status;
  final PricingType pricingType;
  final double budget;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final int completedMilestones;
  final int totalMilestones;
  final List<String> teamMemberUids;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.freelancerUid,
    required this.clientUid,
    this.clientName,
    this.clientAvatarUrl,
    required this.status,
    required this.pricingType,
    required this.budget,
    this.spent = 0,
    required this.startDate,
    required this.endDate,
    this.completedMilestones = 0,
    this.totalMilestones = 0,
    this.teamMemberUids = const [],
    required this.createdAt,
  });

  double get progressPercent =>
      totalMilestones == 0 ? 0 : completedMilestones / totalMilestones;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        freelancerUid: json['freelancerUid'] as String?,
        clientUid: json['clientUid'] as String,
        clientName: json['clientName'] as String?,
        clientAvatarUrl: json['clientAvatarUrl'] as String?,
        status: ProjectStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ProjectStatus.active,
        ),
        pricingType: json['pricingType'] == 'hourly'
            ? PricingType.hourly
            : PricingType.fixedPrice,
        budget: (json['budget'] as num).toDouble(),
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        startDate: json['startDate'] is Timestamp
            ? (json['startDate'] as Timestamp).toDate()
            : DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] is Timestamp
            ? (json['endDate'] as Timestamp).toDate()
            : DateTime.parse(json['endDate'] as String),
        completedMilestones: json['completedMilestones'] as int? ?? 0,
        totalMilestones: json['totalMilestones'] as int? ?? 0,
        teamMemberUids: List<String>.from(json['teamMemberUids'] ?? []),
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        if (freelancerUid != null) 'freelancerUid': freelancerUid,
        'clientUid': clientUid,
        if (clientName != null) 'clientName': clientName,
        if (clientAvatarUrl != null) 'clientAvatarUrl': clientAvatarUrl,
        'status': status.name,
        'pricingType': pricingType.name,
        'budget': budget,
        'spent': spent,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'completedMilestones': completedMilestones,
        'totalMilestones': totalMilestones,
        'teamMemberUids': teamMemberUids,
        'createdAt': createdAt.toIso8601String(),
      };
}
