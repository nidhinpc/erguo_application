import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/payment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Async provider for the logged-in user's payments
final userPaymentProvider = FutureProvider<List<PaymentModel>>((ref) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      log("❌ No logged-in user found for payment fetch");
      return [];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    log("🔥 Payments fetched: ${snapshot.docs.length}");
    for (var doc in snapshot.docs) {
      log("Payment doc: ${doc.id} => ${doc.data()}");
    }

    return snapshot.docs
        .map((doc) => PaymentModel.fromDoc(doc.id, doc.data()))
        .toList();
  } catch (e, st) {
    log("❌ Error fetching payments: $e", stackTrace: st);
    return [];
  }
});
