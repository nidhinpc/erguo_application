import 'package:erguo/controller/payment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class WorkerSendPaymentScreen extends ConsumerStatefulWidget {
  final String userid;
  const WorkerSendPaymentScreen({super.key, required this.userid});

  @override
  ConsumerState<WorkerSendPaymentScreen> createState() =>
      _WorkerSendPaymentScreenState();
}

class _WorkerSendPaymentScreenState
    extends ConsumerState<WorkerSendPaymentScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? createdPaymentId;

  Future<void> _refreshPayments() async {
    await ref
        .read(paymentProvider.notifier)
        .fetchPaymentsForUser(widget.userid);
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentProvider);

    // Find the latest payment for this user by this worker
    final filtered = payments.where(
      (p) =>
          p.id == createdPaymentId &&
          p.workerId == FirebaseAuth.instance.currentUser!.uid,
    );
    final payment = filtered.isNotEmpty ? filtered.first : null;

    // If paid is true → show animation
    if (payment != null && payment.paid) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshPayments,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/success.json',
                        repeat: false,
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Payment Successfully Completed!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Send Salary Request")),
      body: RefreshIndicator(
        onRefresh: _refreshPayments,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Work Description"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(amountController.text) ?? 0;
                final workerId = FirebaseAuth.instance.currentUser!.uid;
                final userId = widget.userid;

                final id = await ref
                    .read(paymentProvider.notifier)
                    .sendPaymentByWorker(
                      workerId: workerId,
                      userId: userId,
                      amount: amount,
                      description: descriptionController.text,
                    );

                setState(() {
                  createdPaymentId = id;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment request sent")),
                );
              },
              child: const Text("Send Request"),
            ),
          ],
        ),
      ),
    );
  }
}
