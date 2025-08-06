// lib/view/admin/nearby_workers_screen.dart

import 'dart:developer';
import 'package:erguo/controller/worker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NearbyWorkersScreen extends ConsumerWidget {
  final Map<String, dynamic> issue;
  final String uniqueCode;

  const NearbyWorkersScreen({
    super.key,
    required this.issue,
    required this.uniqueCode,
  });

  void sendCodeToWorker(BuildContext context, String name, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Code sent to $name ($phone): $uniqueCode")),
    );
    log("Code sent to $name ($phone): $uniqueCode");

    // OPTIONAL: Save code under Firestore for tracking
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workerAsync = ref.watch(workerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Workers")),
      body: workerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (workers) {
          if (workers.isEmpty) {
            return const Center(child: Text("No workers available"));
          }

          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(worker['fullname'] ?? 'No Name'),
                  subtitle: Text(
                    "${worker['location'] ?? 'N/A'} | ${worker['phone'] ?? 'N/A'}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => sendCodeToWorker(
                      context,
                      worker['fullname'] ?? '',
                      worker['phone'] ?? '',
                    ),
                    child: const Text("Send Code"),
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
