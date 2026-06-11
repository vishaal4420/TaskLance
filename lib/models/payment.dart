enum PaymentStatus { pending, completed, failed, refunded }

enum PaymentMethod { card, bankTransfer }

class PaymentModel {
  final String id;
  final String invoiceId;
  final String invoiceNumber;
  final String projectId;
  final String projectName;
  final String payerUid;
  final String recipientUid;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? stripePaymentIntentId;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.projectId,
    required this.projectName,
    required this.payerUid,
    required this.recipientUid,
    required this.amount,
    required this.status,
    required this.method,
    this.stripePaymentIntentId,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as String,
        invoiceId: json['invoiceId'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        projectId: json['projectId'] as String,
        projectName: json['projectName'] as String,
        payerUid: json['payerUid'] as String,
        recipientUid: json['recipientUid'] as String,
        amount: (json['amount'] as num).toDouble(),
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => PaymentStatus.pending,
        ),
        method: json['method'] == 'bankTransfer'
            ? PaymentMethod.bankTransfer
            : PaymentMethod.card,
        stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'projectId': projectId,
        'projectName': projectName,
        'payerUid': payerUid,
        'recipientUid': recipientUid,
        'amount': amount,
        'status': status.name,
        'method': method.name,
        if (stripePaymentIntentId != null)
          'stripePaymentIntentId': stripePaymentIntentId,
        'createdAt': createdAt.toIso8601String(),
      };
}
