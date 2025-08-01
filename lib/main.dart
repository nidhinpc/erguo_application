import 'package:erguo/firebase_options.dart';
import 'package:erguo/view/admin_panel.dart';
import 'package:erguo/view/book_service_screen.dart';
import 'package:erguo/view/home_screen.dart';
import 'package:erguo/view/login_screen.dart';
import 'package:erguo/view/users/user_registration_screen.dart';
import 'package:erguo/view/worker_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hzyfzaxdfunskijhlnfu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9....', // truncated
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Remove anonymous auth, not needed
  // await FirebaseAuth.instance.signInAnonymously();

  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(MyApp(initialLink));
}

class MyApp extends StatelessWidget {
  final PendingDynamicLinkData? initialLink;

  const MyApp(this.initialLink, {super.key});

  @override
  Widget build(BuildContext context) {
    final deepLink = initialLink?.link;
    Widget startScreen;

    if (deepLink != null && deepLink.path.contains('worker')) {
      startScreen = const WorkerRegister();
    } else {
      startScreen = const LoginScreen();
    }

  return MaterialApp(
  title: 'ERGUO',
  theme: ThemeData(primarySwatch: Colors.blue),
  debugShowCheckedModeBanner: false,
  home: startScreen, // use dynamic screen here
  routes: {
    '/bookService': (context) => const BookServiceScreen(),
    '/workerRegister': (context) => const WorkerRegister(),
    '/adminPanel': (context) => const AdminPanel(),
    '/userRegistration': (context) => const UserRegistrationScreen(),
    '/login': (context) => const LoginScreen(),
  },
);
  }
}
