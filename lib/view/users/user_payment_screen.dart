import 'package:erguo/controller/payment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPaymentScreen extends ConsumerStatefulWidget {
  const UserPaymentScreen({super.key});

  @override
  ConsumerState<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends ConsumerState<UserPaymentScreen> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    ref.read(paymentProvider.notifier).fetchPaymentsForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentProvider);

    final pendingPayments = payments.where((p) => !p.paid).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Pending Payments")),
      body: pendingPayments.isEmpty
          ? const Center(child: Text("No pending payments"))
          : ListView.builder(
              itemCount: pendingPayments.length,
              itemBuilder: (context, index) {
                final p = pendingPayments[index];

                return Card(
                  child: ListTile(
                    title: Text("₹\${p.amount} - \${p.description}"),
                    subtitle: Text("Worker ID: \${p.workerId}"),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await ref.read(paymentProvider.notifier).markAsPaid(p.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Payment completed")),
                        );
                      },
                      child: const Text("Pay"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
