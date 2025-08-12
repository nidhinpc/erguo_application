import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/model/payment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userPaymentProvider = FutureProvider.family<List<PaymentModel>, int>((
  ref,
  bookId,
) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      log("❌ No logged-in user found for payment fetch");
      return [];
    }

    Query query = FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: currentUser.uid);

    // ✅ Filter by bookId if provided
    query = query.where('bookId', isEqualTo: bookId);

    final snapshot = await query.get();

    log("🔥 Payments fetched: ${snapshot.docs.length}");
    for (var doc in snapshot.docs) {
      log("Payment doc: ${doc.id} => ${doc.data()}");
    }

    return snapshot.docs
        .map(
          (doc) =>
              PaymentModel.fromDoc(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  } catch (e, st) {
    log("❌ Error fetching payments: $e", stackTrace: st);
    return [];
  }
});
