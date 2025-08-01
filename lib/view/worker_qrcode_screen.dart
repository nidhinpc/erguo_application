// // worker_qrcode_screen.dart
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class WorkerQRCodeScreen extends StatelessWidget {
//   final String workerId;

//   const WorkerQRCodeScreen({super.key, required this.workerId});

//   @override
//   Widget build(BuildContext context) {
//     // This value should match a route or deep link that you want to open
//    final qrValue = 'myapp://workerRegister'; // Use deep link format
// // or a deep link like 'myapp://register'

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Worker QR Code'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             QrImageView(
//               data: qrValue,
//               version: QrVersions.auto,
//               size: 250.0,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Scan to Register',
//               style: TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
