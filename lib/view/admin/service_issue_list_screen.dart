// lib/view/admin/service_issue_list_screen.dart

import 'package:erguo/controller/service_issue_provider.dart';
import 'package:erguo/view/admin/near_by_workers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceIssueListScreen extends ConsumerWidget {
  final String serviceName;

  const ServiceIssueListScreen({super.key, required this.serviceName});

  void handleDecision(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> issue,
    String action,
  ) async {
    final issueId = issue['id'];

    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(issueId)
          .update({'status': action});

      if (action == 'accepted') {
        final uniqueCode =
            'ISSUE-${issue['userId']}&${DateTime.now().millisecondsSinceEpoch}';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NearbyWorkersScreen(issue: issue, uniqueCode: uniqueCode),
          ),
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Issue marked as $action')));

      // Refresh provider after update
      ref.refresh(issuesProvider(serviceName));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(issuesProvider(serviceName));

    return Scaffold(
      appBar: AppBar(title: Text('$serviceName Issues')),
      body: issuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (issues) {
          if (issues.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }
          return ListView.builder(
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
                                ? () => handleDecision(
                                    context,
                                    ref,
                                    issue,
                                    'accepted',
                                  )
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
                                ? () => handleDecision(
                                    context,
                                    ref,
                                    issue,
                                    'rejected',
                                  )
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
          );
        },
      ),
    );
  }
}
