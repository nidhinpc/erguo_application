import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/view/admin/near_by_workers_screen.dart';
import 'package:flutter/material.dart';

class ServiceIssueListScreen extends StatefulWidget {
  final String serviceName;

  const ServiceIssueListScreen({super.key, required this.serviceName});

  @override
  State<ServiceIssueListScreen> createState() => _ServiceIssueListScreenState();
}

class _ServiceIssueListScreenState extends State<ServiceIssueListScreen> {
  List<Map<String, dynamic>> issues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServiceIssues();
  }

  Future<void> fetchServiceIssues() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('booking')
          .where('servicename', isEqualTo: widget.serviceName)
          .get();

      final fetchedIssues = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['status'] = data['status'] ?? 'pending'; // default
        return data;
      }).toList();

      setState(() {
        issues = fetchedIssues;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching issues: $e");
      setState(() => isLoading = false);
    }
  }

  void handleDecision(int index, String action) {
    setState(() {
      issues[index]['status'] = action;
    });

    if (action == 'accepted') {
      final uniqueCode = 'ISSUE-${DateTime.now().millisecondsSinceEpoch}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              NearbyWorkersScreen(issue: issues[index], uniqueCode: uniqueCode),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Issue ${index + 1} marked as $action')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.serviceName} Issues')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : issues.isEmpty
          ? const Center(child: Text("No bookings found."))
          : ListView.builder(
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue = issues[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (issue['photo'] != null)
                          Image.network(
                            issue['photo'],
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          "Description: ${issue['description'] ?? ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text("Location: ${issue['location'] ?? ''}"),
                        Text("Address: ${issue['address'] ?? ''}"),
                        Text("Scheduled: ${issue['sheduledtime'] ?? ''}"),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: issue['status'] == 'pending'
                                  ? () => handleDecision(index, 'accepted')
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text("Accept"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: issue['status'] == 'pending'
                                  ? () => handleDecision(index, 'rejected')
                                  : null,
                              icon: const Icon(Icons.close),
                              label: const Text("Reject"),
                            ),
                          ],
                        ),
                        if (issue['status'] != 'pending') ...[
                          const SizedBox(height: 6),
                          Text(
                            "Status: ${issue['status']}",
                            style: TextStyle(
                              color: issue['status'] == 'accepted'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
