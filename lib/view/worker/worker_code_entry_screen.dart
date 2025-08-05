import 'dart:developer';

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

  void submitCode() {
    final code = _codeController.text.trim();

    // You should verify this with Firestore
    if (code.startsWith("ISSUE-")) {
      setState(() {
        assigned = true;
      });
      
      Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerLiveTrackingScreen(userLat: 05.0, userLng: 0.0)));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code accepted. You got the job!")),
      );
      log("Worker assigned with code: ISSUE-$code");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code")),
      );
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
              decoration: const InputDecoration(labelText: "Enter Unique Code"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: assigned ? null : submitCode,
              child: const Text("Submit"),
            ),
            if (assigned)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("You have been assigned successfully!", style: TextStyle(color: Colors.green)),
              )
          ],
        ),
      ),
    );
  }
}
