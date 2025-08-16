import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/model/shop_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

final shopProvider =
    StateNotifierProvider<ShopNotifier, AsyncValue<List<ShopModel>>>((ref) {
      return ShopNotifier();
    });

class ShopNotifier extends StateNotifier<AsyncValue<List<ShopModel>>> {
  ShopNotifier() : super(const AsyncValue.loading()) {
    fetchShops();
  }

  final _db = FirebaseFirestore.instance;

  Future<void> fetchShops() async {
    try {
      final snapshot = await _db.collection("shops").get();
      final shops = snapshot.docs
          .map((doc) => ShopModel.fromDoc(doc.id, doc.data()))
          .toList();
      state = AsyncValue.data(shops);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print("Error fetching shops: $e");
    }
  }

  Future<void> addShop(ShopModel shop) async {
    try {
      await _db.collection("shops").add(shop.toMap());
      fetchShops(); // Refresh the list after adding
    } catch (e, st) {
      log("Error adding shop: $e", error: e, stackTrace: st);
      throw e; // Re-throw to handle it in the UI
    }
  }
}
