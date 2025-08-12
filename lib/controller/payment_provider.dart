// --- Riverpod StateNotifier ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/model/payment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentProvider =
    StateNotifierProvider<PaymentController, List<PaymentModel>>((ref) {
      return PaymentController();
    });

class PaymentController extends StateNotifier<List<PaymentModel>> {
  PaymentController() : super([]);

  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchPaymentsForUser(String userId, int bookId) async {
    final snapshot = await _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId) // <-- now filtering by booking
        .get();

    state = snapshot.docs
        .map((doc) => PaymentModel.fromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<String> sendPaymentByWorker({
    required String workerId,
    required String userId,
    required int amount,
    required String description,
    required int bookId,
  }) async {
    final doc = await _firestore.collection('payments').add({
      "workerId": workerId,
      "userId": userId,
      "amount": amount,
      "description": description,
      "paid": false,
      "bookId": bookId, // Assuming bookId is same as userId for this example
      "timestamp": FieldValue.serverTimestamp(),
    });

    state = [
      ...state,
      PaymentModel.fromDoc(doc.id, {
        "workerId": workerId,
        "userId": userId,
        "amount": amount,
        "description": description,
        "paid": false,
        "bookId": bookId,
      }),
    ];

    return doc.id; // Return payment ID
  }

  Future<void> markAsPaid(String paymentId) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'paid': true,
    });

    state = state.map((p) {
      if (p.id == paymentId) {
        return PaymentModel(
          id: p.id,
          workerId: p.workerId,
          userId: p.userId,
          amount: p.amount,
          description: p.description,
          paid: true,
          bookId: p.bookId,
        );
      }
      return p;
    }).toList();
  }
}
