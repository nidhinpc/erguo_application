import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:erguo/view/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? role;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uid = currentUser.uid;
    final userEmail = currentUser.email;

    email = userEmail;

    // Try 'users' collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (userDoc.exists) {
      setState(() {
        name = userDoc.data()?["fullname"] ?? 'User';
        role = userDoc.data()?['role'] ?? 'user';
        isLoading = false;
      });
      return;
    }

    // Try 'admin' collection
    final adminSnapshot = await FirebaseFirestore.instance
        .collection('admin')
        .where('email', isEqualTo: userEmail)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      setState(() {
        name = adminSnapshot.docs.first.data()['name'] ?? 'Admin';
        role = 'admin';
        isLoading = false;
      });
      return;
    }

    setState(() {
      name = "Unknown";
      role = "unknown";
      isLoading = false;
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: ColorConstants.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: $name", style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        "Email: $email",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text("Role: $role", style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: logout,
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
