import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/invoice.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../models/user.dart';

final projectInvoicesProvider = StreamProvider.autoDispose.family<List<InvoiceModel>, String>((ref, projectId) {
  return FirebaseFirestore.instance
      .collection('invoices')
      .where('projectId', isEqualTo: projectId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => InvoiceModel.fromJson({...doc.data(), 'id': doc.id})).toList();
  });
});

// Stream for a single invoice
final invoiceDetailProvider = StreamProvider.family<InvoiceModel?, String>((ref, id) {
  return FirebaseFirestore.instance.collection('invoices').doc(id).snapshots().map((doc) {
    if (!doc.exists) return null;
    return InvoiceModel.fromJson(doc.data()!);
  });
});

// Stream for the list of invoices for the current user
final invoicesProvider = StreamProvider.autoDispose<List<InvoiceModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);

  if (user.role == UserRole.client) {
    return FirebaseFirestore.instance
        .collection('invoices')
        .where('clientUid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => InvoiceModel.fromJson(doc.data())).toList());
  } else {
    return FirebaseFirestore.instance
        .collection('invoices')
        .where('freelancerUid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => InvoiceModel.fromJson(doc.data())).toList());
  }
});

// Repository for invoice actions
final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository());

class InvoiceRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createInvoice(InvoiceModel invoice) async {
    await _db.collection('invoices').doc(invoice.id).set(invoice.toJson());
  }

  Future<void> updateInvoiceStatus(String invoiceId, InvoiceStatus status) async {
    await _db.collection('invoices').doc(invoiceId).update({'status': status.name});
  }
}
