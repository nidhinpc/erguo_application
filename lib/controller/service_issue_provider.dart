// lib/controller/issues_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final issuesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      serviceName,
    ) async {
      final snapshot = await FirebaseFirestore.instance
          .collection('booking')
          .where('servicename', isEqualTo: serviceName)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['status'] = data['status'] ?? 'pending'; // default
        return data;
      }).toList();
    });
