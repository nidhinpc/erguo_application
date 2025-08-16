import 'package:erguo/controller/near_by_shop_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NearbyElectricalShopsScreen extends ConsumerWidget {
  const NearbyElectricalShopsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(nearbyshopProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Electrical Shops")),
      body: shopsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (shops) {
          if (shops.isEmpty) {
            return const Center(child: Text("No shops available"));
          }

          return ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.store, color: Colors.orange),
                  title: Text(shop["name"] ?? "Unnamed Shop"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Place: ${shop["place"] ?? "Unknown"}"),
                      Text("Phone: ${shop["phone"] ?? "N/A"}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
