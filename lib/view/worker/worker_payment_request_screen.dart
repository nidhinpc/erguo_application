// --- Worker Screen ---
import 'package:erguo/controller/payment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkerSendPaymentScreen extends ConsumerWidget {
  const WorkerSendPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Send Salary Request")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount")),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Work Description")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(amountController.text) ?? 0;
                final workerId = FirebaseAuth.instance.currentUser!.uid;
                final userId = "user_uid_here"; // Replace with actual user ID logic

                await ref.read(paymentProvider.notifier).sendPaymentByWorker(
                      workerId: workerId,
                      userId: userId,
                      amount: amount,
                      description: descriptionController.text,
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment request sent")),
                );
              },
              child: const Text("Send Request"),
            )
          ],
        ),
      ),
    );
  }
}