import 'dart:developer';

import 'package:flutter/material.dart';

class NearbyWorkersScreen extends StatefulWidget {
  final Map<String, dynamic> issue;
  final String uniqueCode;

  const NearbyWorkersScreen({
    super.key,
    required this.issue,
    required this.uniqueCode,
  });

  @override
  State<NearbyWorkersScreen> createState() => _NearbyWorkersScreenState();
}

class _NearbyWorkersScreenState extends State<NearbyWorkersScreen> {
  final List<Map<String, dynamic>> workers = [
    {'name': 'Raj', 'distance': 1.5, 'phone': '9876543210'},
    {'name': 'Amit', 'distance': 2.0, 'phone': '9876543211'},
    {'name': 'Nikhil', 'distance': 3.4, 'phone': '9876543212'},
  ];

  @override
  void initState() {
    super.initState();
    workers.sort((a, b) => a['distance'].compareTo(b['distance']));
  }

  void sendCodeToWorker(String name, String phone) {
    // Here you'd send the code (via SMS, Firestore, or WhatsApp logic)
    // For now, just showing a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Code sent to $name ($phone): ${widget.uniqueCode}"),
      ),
    );
    log("Code sent to $name ($phone): ${widget.uniqueCode}");

    // OPTIONAL: Save the code in Firestore under that worker's node
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Workers")),
      body: ListView.builder(
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];
          return Card(
            child: ListTile(
              title: Text(worker['name']),
              subtitle: Text("${worker['distance']} km | ${worker['phone']}"),
              trailing: ElevatedButton(
                onPressed: () => sendCodeToWorker(worker['name'], worker['phone']),
                child: const Text("Send Code"),
              ),
            ),
          );
        },
      ),
    );
  }
}
