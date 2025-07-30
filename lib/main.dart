import 'package:erguo/firebase_options.dart';
import 'package:erguo/view/book_service_screen.dart';
import 'package:erguo/view/home_screen.dart';
import 'package:erguo/view/worker_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hzyfzaxdfunskijhlnfu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6eWZ6YXhkZnVuc2tpamhsbmZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3NzA1MzIsImV4cCI6MjA2OTM0NjUzMn0.Ma7XCXRVDOzpHNQHg-1cUx4fQTYZ7XLF0FVrkXM6Zjg',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.signInAnonymously();

  runApp(MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Registration',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      //home: HomeScreen(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/bookService': (context) => const BookServiceScreen(), // <-- Add this
        '/workerRegister': (context) => const WorkerRegister(),
      },
    );
  }
}
