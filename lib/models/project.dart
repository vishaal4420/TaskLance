import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { open, active, completed, onHold, archived }

enum PricingType { fixedPrice, hourly }

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String category;
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
  final List<String> skills;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.category = 'General',
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
    this.skills = const [],
    required this.createdAt,
  });

  double get progressPercent =>
      totalMilestones == 0 ? 0 : completedMilestones / totalMilestones;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? freelancerUid,
    String? clientUid,
    String? clientName,
    String? clientAvatarUrl,
    ProjectStatus? status,
    PricingType? pricingType,
    double? budget,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    int? completedMilestones,
    int? totalMilestones,
    List<String>? teamMemberUids,
    List<String>? skills,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      freelancerUid: freelancerUid ?? this.freelancerUid,
      clientUid: clientUid ?? this.clientUid,
      clientName: clientName ?? this.clientName,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      status: status ?? this.status,
      pricingType: pricingType ?? this.pricingType,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      totalMilestones: totalMilestones ?? this.totalMilestones,
      teamMemberUids: teamMemberUids ?? this.teamMemberUids,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled Project',
        description: json['description']?.toString() ?? 'No description provided.',
        category: json['category']?.toString() ?? 'General',
        freelancerUid: json['freelancerUid']?.toString(),
        clientUid: json['clientUid']?.toString() ?? '',
        clientName: json['clientName']?.toString(),
        clientAvatarUrl: json['clientAvatarUrl']?.toString(),
        status: ProjectStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ProjectStatus.open,
        ),
        pricingType: json['pricingType'] == 'hourly'
            ? PricingType.hourly
            : PricingType.fixedPrice,
        budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
        spent: double.tryParse(json['spent']?.toString() ?? '0') ?? 0.0,
        startDate: _parseDate(json['startDate']),
        endDate: _parseDate(json['endDate']),
        completedMilestones: int.tryParse(json['completedMilestones']?.toString() ?? '0') ?? 0,
        totalMilestones: int.tryParse(json['totalMilestones']?.toString() ?? '0') ?? 0,
        teamMemberUids: (json['teamMemberUids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        skills: (json['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: _parseDate(json['createdAt']),
      );

  static DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is String) return DateTime.tryParse(dateVal) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
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
        'skills': skills,
        'createdAt': createdAt.toIso8601String(),
      };
}
