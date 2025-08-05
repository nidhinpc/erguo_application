import 'package:erguo/view/admin/service_issue_list_screen.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final List<Map<String, dynamic>> services = [
    {'title': 'Plumbing', 'icon': Icons.plumbing},
    {'title': 'Electrical', 'icon': Icons.electrical_services},
    {'title': 'Garden work', 'icon': Icons.grass},
    {'title': 'Wooden work', 'icon': Icons.chair_alt},
    {'title': 'STP', 'icon': Icons.water},
    {'title': 'AC', 'icon': Icons.ac_unit},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 boxes per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: () {
                // Handle each service box tap here
                Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ServiceIssueListScreen(serviceName: service['title']),
    ),
  );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service['icon'], size: 40, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      service['title'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
