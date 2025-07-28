import 'package:erguo/view/book_service_screen.dart';
import 'package:erguo/view/home_screen.dart';
import 'package:erguo/view/worker_register.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MyWidget());
}
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

