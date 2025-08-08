// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'billing_screen.dart';

// class WorkingScreen extends StatefulWidget {
//   const WorkingScreen({super.key});

//   @override
//   State<WorkingScreen> createState() => _WorkingScreenState();
// }

// class _WorkingScreenState extends State<WorkingScreen> {
//   late Timer _timer;
//   int _seconds = 0;
//   bool _isRunning = false;

//   void _startTimer() {
//     if (_isRunning) return;
//     _isRunning = true;
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() => _seconds++);
//     });
//   }

//   void _pauseTimer() {
//     if (!_isRunning) return;
//     _timer.cancel();
//     _isRunning = false;
//   }

//   void _finishTimer() {
//     _timer.cancel();
//     _isRunning = false;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => BillingScreen(durationInSeconds: _seconds),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     if (_isRunning) _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final duration = Duration(seconds: _seconds);
//     final formatted = duration.toString().split('.').first;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Work In Progress")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(formatted, style: const TextStyle(fontSize: 40)),
//             const SizedBox(height: 20),
//             ElevatedButton(onPressed: _startTimer, child: const Text("Start Work")),
//             ElevatedButton(onPressed: _pauseTimer, child: const Text("Pause")),
//             ElevatedButton(onPressed: _finishTimer, child: const Text("Finish")),
//           ],
//         ),
//       ),
//     );
//   }
// }
