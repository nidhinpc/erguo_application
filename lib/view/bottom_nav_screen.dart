import 'package:flutter/material.dart';
import 'package:erguo/view/admin/admin_panel.dart';
import 'package:erguo/view/users/home_screen.dart';
import 'package:erguo/view/worker/worker_code_entry_screen.dart';
import 'package:erguo/view/profile_screen.dart'; // <- Create this if not already

class BottomNavScreen extends StatefulWidget {
  final int initialIndex; // 0 = Admin, 1 = User, 2 = Worker

  const BottomNavScreen({super.key, required this.initialIndex});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = 0; // Always show main screen first
  }

  Widget getRoleScreen() {
    switch (widget.initialIndex) {
      case 0:
        return const AdminPanel();
      case 1:
        return const HomeScreen();
      case 2:
        return WorkerCodeEntryScreen();
      default:
        return const HomeScreen(); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      getRoleScreen(), // Tab 0 = Role-based screen
      const ProfileScreen(), // Tab 1 = Profile screen
    ];

    return Scaffold(
      body: _screens[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
