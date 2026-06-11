import 'package:cloud_firestore/cloud_firestore.dart';

class ContractModel {
  final String id;
  final String projectId;
  final String title;
  final String clientUid;
  final String clientName;
  final String freelancerUid;
  final String freelancerName;
  final String terms;
  final double amount;
  final DateTime signedAt;

  const ContractModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.clientUid,
    required this.clientName,
    required this.freelancerUid,
    required this.freelancerName,
    required this.terms,
    required this.amount,
    required this.signedAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) => ContractModel(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        clientUid: json['clientUid'] as String,
        clientName: json['clientName'] as String,
        freelancerUid: json['freelancerUid'] as String,
        freelancerName: json['freelancerName'] as String,
        terms: json['terms'] as String,
        amount: (json['amount'] as num).toDouble(),
        signedAt: json['signedAt'] is Timestamp
            ? (json['signedAt'] as Timestamp).toDate()
            : DateTime.parse(json['signedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'clientUid': clientUid,
        'clientName': clientName,
        'freelancerUid': freelancerUid,
        'freelancerName': freelancerName,
        'terms': terms,
        'amount': amount,
        'signedAt': signedAt.toIso8601String(),
      };
}
