import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionStatus { pending, completed, failed, refunded }

enum TransactionMethod { card, bankTransfer, wallet }

class TransactionModel {
  final String id;
  final String userId; // The user this transaction belongs to
  final String? invoiceId;
  final String? invoiceNumber;
  final String? projectId;
  final String? projectName;
  final double amount; // Negative for deduction, positive for deposit
  final TransactionStatus status;
  final TransactionMethod method;
  final String? stripePaymentIntentId;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    this.invoiceId,
    this.invoiceNumber,
    this.projectId,
    this.projectName,
    required this.amount,
    required this.status,
    required this.method,
    this.stripePaymentIntentId,
    required this.createdAt,
  });

  static DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is String) return DateTime.tryParse(dateVal) ?? DateTime.now();
    return DateTime.now();
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        invoiceId: json['invoiceId'] as String?,
        invoiceNumber: json['invoiceNumber'] as String?,
        projectId: json['projectId'] as String?,
        projectName: json['projectName'] as String?,
        amount: (json['amount'] as num).toDouble(),
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransactionStatus.pending,
        ),
        method: TransactionMethod.values.firstWhere(
          (e) => e.name == json['method'],
          orElse: () => TransactionMethod.wallet,
        ),
        stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
        createdAt: _parseDate(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        if (invoiceId != null) 'invoiceId': invoiceId,
        if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
        if (projectId != null) 'projectId': projectId,
        if (projectName != null) 'projectName': projectName,
        'amount': amount,
        'status': status.name,
        'method': method.name,
        if (stripePaymentIntentId != null)
          'stripePaymentIntentId': stripePaymentIntentId,
        'createdAt': createdAt.toIso8601String(),
      };
}

