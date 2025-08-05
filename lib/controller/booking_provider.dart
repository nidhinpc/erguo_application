import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ✅ Provider to fetch current user's bookings from Firestore
final userBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return []; // or throw Exception('User not logged in');
  }

  final snapshot = await FirebaseFirestore.instance
      .collection('booking')
      .where('userId', isEqualTo: user.uid)
      .get();

  return snapshot.docs.map((doc) => doc.data()).toList();
});
