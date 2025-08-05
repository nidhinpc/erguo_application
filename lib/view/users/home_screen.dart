import 'package:erguo/controller/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> services = const [
    {'title': 'Plumbing', 'icon': Icons.plumbing},
    {'title': 'Electrical', 'icon': Icons.electrical_services},
    {'title': 'Garden work', 'icon': Icons.grass},
    {'title': 'Wooden work', 'icon': Icons.chair_alt},
    {'title': 'STP', 'icon': Icons.water},
    {'title': 'AC', 'icon': Icons.ac_unit},
  ];

  void _navigateToBookService(BuildContext context, String serviceName) {
    Navigator.pushNamed(context, '/bookService', arguments: serviceName);
  }

  void _showPendingBookingsSheet(BuildContext context, List<Map<String, dynamic>> bookings) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: booking['photo'] != null
                    ? Image.network(booking['photo'], width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(booking['servicename'] ?? 'Unknown'),
                subtitle: Text(booking['description'] ?? ''),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Add navigation or actions
                  },
                  child: const Text('Pending'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsyncValue = ref.watch(userBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: bookingAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userBookingsProvider); // 🔁 Refresh
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Book a Service',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () => _navigateToBookService(context, service['title']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
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
                            Icon(service['icon'], size: 40, color: Colors.green),
                            const SizedBox(height: 10),
                            Text(
                              service['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPendingBookingsSheet(context, bookings),
                    child: const Text("My Bookings"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
