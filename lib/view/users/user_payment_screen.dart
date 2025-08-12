import 'package:erguo/controller/payment_provider.dart';
import 'package:erguo/controller/user_payment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UserPaymentScreen extends ConsumerStatefulWidget {
  final int bookId; // ✅ Pass this from HomeScreen

  const UserPaymentScreen({super.key, required this.bookId});

  @override
  ConsumerState<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends ConsumerState<UserPaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    // _razorpay = Razorpay();

    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("✅ Payment Success: ${response.paymentId}")),
  //   );

  //   // ✅ Mark payment as paid in Firestore
  //   final payments =
  //       ref.read(userPaymentProvider(widget.bookId)).asData?.value ?? [];

  //   if (payments.isNotEmpty) {
  //     await ref
  //         .read(paymentProvider.notifier)
  //         .markAsPaid(payments.first.id); // mark first matching payment
  //   }
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("❌ Payment Failed: ${response.message}")),
  //   );
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("💳 External Wallet: ${response.walletName}")),
  //   );
  // }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsyncValue = ref.watch(userPaymentProvider(widget.bookId));

    return Scaffold(
      appBar: AppBar(title: const Text("Pending Payment")),
      body: paymentAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text("No pending payments"));
          }

          final pendingPayments = payments.where((p) => !p.paid).toList();
          if (pendingPayments.isEmpty) {
            return const Center(child: Text("✅ Payment already completed"));
          }

          return ListView.builder(
            itemCount: pendingPayments.length,
            itemBuilder: (context, index) {
              final p = pendingPayments[index];

              return Card(
                child: ListTile(
                  title: Text("₹ ${p.amount} - ${p.description}"),
                  subtitle: Text("Worker ID: ${p.workerId}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // ✅ Open Razorpay payment gateway
                      Razorpay razorpay = Razorpay();
                      var options = {
                        'key':
                            'rzp_live_ILgsfZCZoFIKMb', // replace with live key
                        'amount': 1 * 100, // Razorpay needs paise
                        'currency': 'INR',
                        'name': 'Erguo Services',
                        'description': p.description,
                        'retry': {'enabled': true, 'max_count': 1},
                        'send_sms_hash': true,
                        'prefill': {
                          'contact': "9605714179",
                          'email': "zeuobackendfile@gmail.com",
                        },
                        'external': {
                          'wallets': ['paytm'],
                        },
                      };
                      razorpay.on(
                        Razorpay.EVENT_PAYMENT_ERROR,
                        handlePaymentErrorResponse,
                      );
                      razorpay.on(
                        Razorpay.EVENT_PAYMENT_SUCCESS,
                        handlePaymentSuccessResponse,
                      );
                      razorpay.on(
                        Razorpay.EVENT_EXTERNAL_WALLET,
                        handleExternalWalletSelected,
                      );
                      razorpay.open(options);
                    },
                    child: const Text("Pay Now"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    showAlertDialog(
      context,
      "Payment Failed",
      "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}",
    );
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    showAlertDialog(
      context,
      "Payment Successful",
      "Payment ID: ${response.paymentId}",
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
      context,
      "External Wallet Selected",
      "${response.walletName}",
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(title: Text(title), content: Text(message));
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
