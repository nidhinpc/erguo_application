import 'package:flutter/material.dart';

class BillingScreen extends StatelessWidget {
  final int durationInSeconds;

  const BillingScreen({super.key, required this.durationInSeconds});

  @override
  Widget build(BuildContext context) {
    final timeInMinutes = (durationInSeconds / 60).ceil();
    final labourCharge = (timeInMinutes <= 30) ? 500 : 750; // Example logic
    final materialCharge = 500;
    final otherCharge = 500;
    final total = labourCharge + materialCharge + otherCharge;

    return Scaffold(
      appBar: AppBar(title: const Text("Billing Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Work Duration: $timeInMinutes min", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Labour: ₹$labourCharge"),
            Text("Material: ₹$materialCharge"),
            Text("Other: ₹$otherCharge"),
            const Divider(),
            Text("Total: ₹$total", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
