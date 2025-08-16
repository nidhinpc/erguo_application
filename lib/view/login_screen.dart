import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:erguo/view/admin/admin_panel.dart';
import 'package:erguo/view/bottom_nav_screen.dart';
import 'package:erguo/view/users/home_screen.dart';
import 'package:erguo/view/worker/worker_code_entry_screen.dart';
import 'package:erguo/view/worker_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   // Navigate to role-based screen directly
    //   _navigateToRoleBasedScreen(user);
    // }
  }

  void _navigateToRoleBasedScreen(User user) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String? role = userDoc.data()?['role'];

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavScreen(initialIndex: 0)),
      );
    } else if (role == 'worker') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavScreen(initialIndex: 2)),
      );
    } else if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavScreen(initialIndex: 1)),
      );
    } else {
      // Handle unknown role
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unknown role: $role")));
    }
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      // Step 1: Try to fetch from 'users' collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      String? role;

      if (userDoc.exists) {
        role = userDoc.data()?['role'];
      } else {
        // Step 2: Try to fetch from 'admin' collection
        final adminSnapshot = await FirebaseFirestore.instance
            .collection('admin')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (adminSnapshot.docs.isNotEmpty) {
          role = 'admin';
        } else {
          throw Exception("User role not found.");
        }
      }

      // Step 3: Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavScreen(initialIndex: 0),
          ),
        );
      } else if (role == 'worker') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavScreen(initialIndex: 2),
          ),
        );
      } else if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavScreen(initialIndex: 1),
          ),
        );
      } else {
        throw Exception("Unknown role: $role");
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') message = "User not found";
      if (e.code == 'wrong-password') message = "Incorrect password";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.successColor,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "ZEUO",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,

                        colors: [
                          const Color.fromARGB(255, 9, 31, 71).withOpacity(0.1),
                          const Color.fromARGB(255, 79, 7, 2).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,

                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,

                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              fillColor: ColorConstants.secondaryColor,
                              filled: true,
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              disabledBorder: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Enter your email' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              fillColor: ColorConstants.secondaryColor,
                              filled: true,
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              disabledBorder: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter your password' : null,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: ColorConstants.primaryColor,
                            ),

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorConstants.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),

                              onPressed: _isLoading ? null : loginUser,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: ColorConstants.secondaryColor,
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ColorConstants.secondaryColor,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/userRegistration');
                            },
                            child: const Text(
                              "Don't have an account? Register",
                              style: TextStyle(
                                color: ColorConstants.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
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
