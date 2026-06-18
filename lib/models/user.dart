import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { freelancer, client }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? tagline;
  final UserRole role;
  final List<String> skills;
  final double? hourlyRate;
  final String? companyName;
  final String? industry;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final double rating;
  final int reviewCount;
  final int projectsCompleted;
  final double totalEarned;
  final double onTimePercent;
  final bool emailVerified;
  final bool pushNotifs;
  final bool emailNotifs;
  final bool marketingNotifs;
  final DateTime createdAt;
  final List<String> teamMemberUids;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.tagline,
    required this.role,
    this.skills = const [],
    this.hourlyRate,
    this.companyName,
    this.industry,
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.projectsCompleted = 0,
    this.totalEarned = 0,
    this.onTimePercent = 0,
    this.emailVerified = false,
    this.pushNotifs = true,
    this.emailNotifs = true,
    this.marketingNotifs = false,
    required this.createdAt,
    this.teamMemberUids = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        bio: json['bio'] as String?,
        tagline: json['tagline'] as String?,
        role: json['role'] == 'client' ? UserRole.client : UserRole.freelancer,
        skills: List<String>.from(json['skills'] ?? []),
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
        companyName: json['companyName'] as String?,
        industry: json['industry'] as String?,
        githubUrl: json['githubUrl'] as String?,
        linkedinUrl: json['linkedinUrl'] as String?,
        portfolioUrl: json['portfolioUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        projectsCompleted: json['projectsCompleted'] as int? ?? 0,
        totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0,
        onTimePercent: (json['onTimePercent'] as num?)?.toDouble() ?? 0,
        emailVerified: json['emailVerified'] as bool? ?? false,
        pushNotifs: json['pushNotifs'] as bool? ?? true,
        emailNotifs: json['emailNotifs'] as bool? ?? true,
        marketingNotifs: json['marketingNotifs'] as bool? ?? false,
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
        teamMemberUids: List<String>.from(json['teamMemberUids'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (tagline != null) 'tagline': tagline,
        'role': role.name,
        'skills': skills,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (companyName != null) 'companyName': companyName,
        if (industry != null) 'industry': industry,
        if (githubUrl != null) 'githubUrl': githubUrl,
        if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
        if (portfolioUrl != null) 'portfolioUrl': portfolioUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'projectsCompleted': projectsCompleted,
        'totalEarned': totalEarned,
        'onTimePercent': onTimePercent,
        'emailVerified': emailVerified,
        'pushNotifs': pushNotifs,
        'emailNotifs': emailNotifs,
        'marketingNotifs': marketingNotifs,
        'createdAt': createdAt.toIso8601String(),
        'teamMemberUids': teamMemberUids,
      };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    String? bio,
    String? tagline,
    List<String>? skills,
    double? hourlyRate,
    String? companyName,
    String? industry,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
    bool? pushNotifs,
    bool? emailNotifs,
    bool? marketingNotifs,
    List<String>? teamMemberUids,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        tagline: tagline ?? this.tagline,
        role: role,
        skills: skills ?? this.skills,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        companyName: companyName ?? this.companyName,
        industry: industry ?? this.industry,
        githubUrl: githubUrl ?? this.githubUrl,
        linkedinUrl: linkedinUrl ?? this.linkedinUrl,
        portfolioUrl: portfolioUrl ?? this.portfolioUrl,
        rating: rating,
        reviewCount: reviewCount,
        projectsCompleted: projectsCompleted,
        totalEarned: totalEarned,
        onTimePercent: onTimePercent,
        emailVerified: emailVerified,
        pushNotifs: pushNotifs ?? this.pushNotifs,
        emailNotifs: emailNotifs ?? this.emailNotifs,
        marketingNotifs: marketingNotifs ?? this.marketingNotifs,
        createdAt: createdAt,
        teamMemberUids: teamMemberUids ?? this.teamMemberUids,
      );
}
