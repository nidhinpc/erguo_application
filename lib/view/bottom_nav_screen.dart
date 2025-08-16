import 'package:erguo/view/admin/shop_register_screen.dart';
import 'package:erguo/view/near_by_shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:erguo/view/admin/admin_panel.dart';
import 'package:erguo/view/users/home_screen.dart';
import 'package:erguo/view/worker/worker_code_entry_screen.dart';
import 'package:erguo/view/profile_screen.dart';

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
    _selectedTabIndex = 0; // Start on dashboard tab
  }

  /// Returns role-based dashboard screen
  Widget getRoleScreen() {
    switch (widget.initialIndex) {
      case 0:
        return const AdminPanel();
      case 1:
        return const HomeScreen();
      case 2:
        return WorkerCodeEntryScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screens based on role
    late List<Widget> screens;
    late List<BottomNavigationBarItem> navItems;

    if (widget.initialIndex == 0) {
      // ADMIN: Dashboard + Profile
      screens = [getRoleScreen(), ShopRegisterScreen(), const ProfileScreen()];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_business),
          label: 'Register Shop',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    } else {
      // USER or WORKER: Dashboard + Nearby Shops + Profile
      screens = [
        getRoleScreen(),
        const NearbyElectricalShopsScreen(
          // userLat: 10.1234, // replace with actual location
          // userLng: 76.5678,
          // workerLat: 10.4567,
          // workerLng: 76.6789,
        ),
        const ProfileScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Nearby Shops'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }

    return Scaffold(
      body: screens[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}
