import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/admin_export_screen.dart';
import '../screens/login_screen.dart';

enum ActiveScreen { admin, export }

class AdminBar extends StatelessWidget {
  final BuildContext parentContext;
  final ActiveScreen activeScreen;

  const AdminBar({super.key, required this.parentContext, required this.activeScreen});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.logout();
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pushAndRemoveUntil(
                parentContext,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (Route<dynamic> route) => false,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBorderRadius: 8,
            tabs: const [
              GButton(
                icon: Icons.admin_panel_settings,
                text: 'Admin',
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
            selectedIndex: activeScreen == ActiveScreen.admin ? 0 : activeScreen == ActiveScreen.export ? 1 : 2,
            onTabChange: (index) {
              if (index == 0 && activeScreen != ActiveScreen.admin) {
                Navigator.pushAndRemoveUntil(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                  (Route<dynamic> route) => false,
                );
              } else if (index == 1 && activeScreen != ActiveScreen.export) {
                Navigator.pushAndRemoveUntil(
                  parentContext,
                  MaterialPageRoute(builder: (_) => const AdminExportScreen()),
                  (Route<dynamic> route) => false,
                );
              } else if (index == 2) {
                _logout(context);
              }
            },
          ),
        ),
      ),
    );
  }
}