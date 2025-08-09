import 'dart:developer';
import 'package:erguo/controller/booking_provider.dart';
import 'package:erguo/controller/user_payment_provider.dart';
import 'package:erguo/view/users/user_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

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

  void _showPendingBookingsSheet(
    BuildContext context,
    List<Map<String, dynamic>> bookings,
    List payments,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            final pendingPayment = payments.firstWhereOrNull((p) {
              final match =
                  p.userId.trim() == (booking['userId'] ?? '').trim() &&
                  p.description.trim().toLowerCase() ==
                      (booking['description'] ?? '').trim().toLowerCase() &&
                  !p.paid;

              log(
                "🔍 Checking booking: ${booking['description']} | "
                "Match: $match | Payment paid: ${p.paid}",
              );
              return match;
            });

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: booking['photo'] != null
                    ? Image.network(
                        booking['photo'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : null,
                title: Text(booking['servicename'] ?? 'Unknown'),
                subtitle: Text(booking['description'] ?? ''),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (pendingPayment != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserPaymentScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No pending payment')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pendingPayment != null
                        ? Colors.orange
                        : Colors.grey,
                  ),
                  child: Text(pendingPayment != null ? 'Go to Pay' : 'Pending'),
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
    final paymentAsyncValue = ref.watch(userPaymentProvider);

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
        data: (bookings) => paymentAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading payments: $e')),
          data: (payments) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userBookingsProvider);
              ref.invalidate(userPaymentProvider);
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return GestureDetector(
                        onTap: () =>
                            _navigateToBookService(context, service['title']),
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
                              Icon(
                                service['icon'],
                                size: 40,
                                color: Colors.green,
                              ),
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
                      onPressed: () => _showPendingBookingsSheet(
                        context,
                        bookings,
                        payments,
                      ),
                      child: const Text("My Bookings"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
