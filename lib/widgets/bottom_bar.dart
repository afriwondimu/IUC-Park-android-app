import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../screens/export_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

enum ActiveScreen { home, export }

class BottomBar extends StatelessWidget {
  final BuildContext parentContext;
  final ActiveScreen activeScreen;

  const BottomBar({super.key, required this.parentContext, required this.activeScreen});

  void _logout() {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().logout(); // Clear login state
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: GNav(
            backgroundColor: Colors.grey[900]!,
            color: Colors.white70,
            activeColor: Colors.red,
            tabBackgroundColor: Colors.red.withOpacity(0.1),
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBorderRadius: 15,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.description,
                text: 'Export',
              ),
              GButton(
                icon: Icons.logout,
                text: 'Logout',
              ),
            ],
            selectedIndex: activeScreen == ActiveScreen.home ? 0 : 1,
            onTabChange: (index) {
              if (index == 0 && activeScreen != ActiveScreen.home) {
                Navigator.pushReplacement(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else if (index == 1 && activeScreen != ActiveScreen.export) {
                Navigator.pushReplacement(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const ExportScreen()),
                );
              } else if (index == 2) {
                _logout();
              }
            },
          ),
        ),
      ),
    );
  }
}