import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/view/worker/worker_live_tracking_screen.dart';
import 'package:flutter/material.dart';

class WorkerCodeEntryScreen extends StatefulWidget {
  const WorkerCodeEntryScreen({super.key});

  @override
  State<WorkerCodeEntryScreen> createState() => _WorkerCodeEntryScreenState();
}

class _WorkerCodeEntryScreenState extends State<WorkerCodeEntryScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool assigned = false;

  void submitCode() async {
    final code = _codeController.text.trim();

    if (!code.startsWith("ISSUE-") || !code.contains("&")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid code format")));
      return;
    }

    final parts = code.split(RegExp(r"[-&]"));
    if (parts.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid code structure")));
      return;
    }

    final userId = parts[1]; // Extracted between '-' and '&'
    final codeTimestamp =
        parts[2]; // Optional: you can use this for expiry check

    try {
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('booking')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        setState(() {
          assigned = true;
        });

        log("Worker assigned with userId: $userId");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code accepted. You got the job!")),
        );

        // Optional: fetch userLat and userLng from booking
        final bookingData = bookingSnapshot.docs.first.data();
        final userLat = bookingData['latitude'] ?? 0.0;
        final userLng = bookingData['longitude'] ?? 0.0;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerLiveTrackingScreen(
              userLat: userLat,
              userLng: userLng,
              userid: userId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No booking found for this code.")),
        );
      }
    } catch (e) {
      log("Error verifying code: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Job Code")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Enter Unique Code",
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: assigned ? null : submitCode,
              child: const Text("Submit"),
            ),
            if (assigned)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "You have been assigned successfully!",
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
