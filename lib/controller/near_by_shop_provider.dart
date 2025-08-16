import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nearbyshopProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final snapshot = await FirebaseFirestore.instance.collection('shops').get();
  return snapshot.docs.map((doc) => doc.data()).toList();
});
