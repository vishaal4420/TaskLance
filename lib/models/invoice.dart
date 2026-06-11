enum InvoiceStatus { draft, sent, viewed, paid, overdue, voided }

class InvoiceLineItem {
  final String description;
  final double quantity;
  final double unitPrice;

  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) => InvoiceLineItem(
        description: json['description'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String projectId;
  final String projectName;
  final String freelancerUid;
  final String clientUid;
  final String clientName;
  final List<InvoiceLineItem> lineItems;
  final double taxPercent;
  final double discountPercent;
  final String? notes;
  final DateTime dueDate;
  final DateTime createdAt;
  final InvoiceStatus status;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.projectId,
    required this.projectName,
    required this.freelancerUid,
    required this.clientUid,
    required this.clientName,
    required this.lineItems,
    this.taxPercent = 0,
    this.discountPercent = 0,
    this.notes,
    required this.dueDate,
    required this.createdAt,
    required this.status,
  });

  double get subtotal => lineItems.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * taxPercent / 100;
  double get discountAmount => subtotal * discountPercent / 100;
  double get total => subtotal + taxAmount - discountAmount;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        projectId: json['projectId'] as String,
        projectName: json['projectName'] as String,
        freelancerUid: json['freelancerUid'] as String,
        clientUid: json['clientUid'] as String,
        clientName: json['clientName'] as String,
        lineItems: (json['lineItems'] as List<dynamic>)
            .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 0,
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String?,
        dueDate: DateTime.parse(json['dueDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: InvoiceStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => InvoiceStatus.draft,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'projectId': projectId,
        'projectName': projectName,
        'freelancerUid': freelancerUid,
        'clientUid': clientUid,
        'clientName': clientName,
        'lineItems': lineItems.map((e) => e.toJson()).toList(),
        'taxPercent': taxPercent,
        'discountPercent': discountPercent,
        if (notes != null) 'notes': notes,
        'dueDate': dueDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };
}
