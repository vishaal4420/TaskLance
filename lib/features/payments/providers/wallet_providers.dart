import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/transaction.dart';
import '../../auth/providers/auth_providers.dart';

final walletTransactionsProvider = StreamProvider<List<TransactionModel>>((ref) async* {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    yield [];
    return;
  }

  yield* FirebaseFirestore.instance
      .collection('transactions')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => TransactionModel.fromJson(doc.data())).toList();
  });
});

final walletBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(walletTransactionsProvider).valueOrNull ?? [];
  return transactions.fold(0.0, (sum, tx) => sum + tx.amount);
});
