import 'package:erguo/view/admin/near_by_workers_screen.dart';
import 'package:flutter/material.dart';

class ServiceIssueListScreen extends StatefulWidget {
  final String serviceName;

  const ServiceIssueListScreen({super.key, required this.serviceName});

  @override
  State<ServiceIssueListScreen> createState() => _ServiceIssueListScreenState();
}

class _ServiceIssueListScreenState extends State<ServiceIssueListScreen> {
  late List<Map<String, dynamic>> issues;

  @override
  void initState() {
    super.initState();
    // Dummy issue list based on service
    issues = List.generate(
      5,
      (index) => {
        'description': 'Issue #$index for ${widget.serviceName}',
        'user': 'User ${index + 1}',
        'location': 'Flat No. ${101 + index}, Block A',
        'status': 'pending',
      },
    );
  }

 void handleDecision(int index, String action) {
  setState(() {
    issues[index]['status'] = action;
  });

  if (action == 'accepted') {
    // Generate unique code
    final uniqueCode = 'ISSUE-${DateTime.now().millisecondsSinceEpoch}';

    // Pass issue details + code to NearbyWorkersScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearbyWorkersScreen(
          issue: issues[index],
          uniqueCode: uniqueCode,
        ),
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
      appBar: AppBar(
        title: Text('${widget.serviceName} Issues'),
      ),
      body: ListView.builder(
        itemCount: issues.length,
        itemBuilder: (context, index) {
          final issue = issues[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(issue['description'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('User: ${issue['user']}'),
                  Text('Location: ${issue['location']}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: issue['status'] == 'pending'
                            ? () => handleDecision(index, 'accepted')
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text("Accept"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: issue['status'] == 'pending'
                            ? () => handleDecision(index, 'rejected')
                            : null,
                        icon: const Icon(Icons.close),
                        label: const Text("Reject"),
                      ),
                    ],
                  ),
                  if (issue['status'] != 'pending') ...[
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${issue['status']}',
                      style: TextStyle(
                        color: issue['status'] == 'accepted' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
