import 'package:erguo/firebase_options.dart';
import 'package:erguo/view/admin/admin_panel.dart';
import 'package:erguo/view/users/book_service_screen.dart';
import 'package:erguo/view/users/home_screen.dart';
import 'package:erguo/view/login_screen.dart';
import 'package:erguo/view/payment_screen.dart';
import 'package:erguo/view/users/user_payment_screen.dart';
import 'package:erguo/view/users/user_registration_screen.dart';
import 'package:erguo/view/worker/worker_code_entry_screen.dart';
import 'package:erguo/view/worker/worker_payment_request_screen.dart';
import 'package:erguo/view/worker_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hzyfzaxdfunskijhlnfu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6eWZ6YXhkZnVuc2tpamhsbmZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NzA1MzIsImV4cCI6MjA2OTM0NjUzMn0.Ma7XCXRVDOzpHNQHg-1cUx4fQTYZ7XLF0FVrkXM6Zjg', // truncated
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Remove anonymous auth, not needed
  // await FirebaseAuth.instance.signInAnonymously();

  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(ProviderScope(child: MyApp(initialLink)));
}

class MyApp extends ConsumerWidget {
  final PendingDynamicLinkData? initialLink;

  const MyApp(this.initialLink, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deepLink = initialLink?.link;
    Widget startScreen = deepLink != null && deepLink.path.contains('worker')
        ? const WorkerRegister()
        : const LoginScreen();

    return MaterialApp(
      title: 'ERGUO',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: startScreen, // OR PaymentScreen()
      routes: {
        '/bookService': (context) => const BookServiceScreen(),
        '/workerRegister': (context) => const WorkerRegister(),
        '/adminPanel': (context) => const AdminPanel(),
        '/userRegistration': (context) => const UserRegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/payment': (context) => const PaymentScreen(),
      },
    );
  }
}