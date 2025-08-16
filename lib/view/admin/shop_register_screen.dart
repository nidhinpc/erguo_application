// lib/view/shop_register_screen.dart
import 'package:erguo/controller/shop_provider.dart';
import 'package:erguo/model/shop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopRegisterScreen extends ConsumerStatefulWidget {
  const ShopRegisterScreen({super.key});

  @override
  ConsumerState<ShopRegisterScreen> createState() => _ShopRegisterScreenState();
}

class _ShopRegisterScreenState extends ConsumerState<ShopRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _registerShop() async {
    if (_formKey.currentState!.validate()) {
      final shop = ShopModel(
        id: "", // Firestore will generate one
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        place: _placeController.text.trim(),
      );

      await ref.read(shopProvider.notifier).addShop(shop);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Shop registered successfully")),
      );

      _nameController.clear();
      _phoneController.clear();
      _placeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shopsState = ref.watch(shopProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Register Shop")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Registration Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Shop Name"),
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter shop name"
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(labelText: "Place"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter place" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Enter phone" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerShop,
                    child: const Text("Register Shop"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Shop List
            Expanded(
              child: shopsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (shops) {
                  if (shops.isEmpty) {
                    return const Center(child: Text("No shops registered yet"));
                  }
                  return ListView.builder(
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.store, color: Colors.green),
                          title: Text(shop.name),
                          subtitle: Text("${shop.place} | ${shop.phone}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
