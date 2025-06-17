import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart';
import '../../widgets/export_db.dart';
import '../../widgets/export_form.dart';
import '../../widgets/admin_bar.dart';

class AdminExportScreen extends StatefulWidget {
  const AdminExportScreen({super.key});

  @override
  _AdminExportScreenState createState() => _AdminExportScreenState();
}

class _AdminExportScreenState extends State<AdminExportScreen> {
  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AppState>(context).getCurrentUsername();
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withOpacity(0.15),
                    Colors.red.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icon/appicon.png',
                        height: 50,
                        width: 50,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'IUC Park - ${username ?? "Guest"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(height: cardPadding),
                        const ExportDB(),
                        SizedBox(height: cardPadding),
                        const ExportForm(),
                        SizedBox(height: cardPadding * 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBar(
        parentContext: context,
        activeScreen: ActiveScreen.export,
      ),
    );
  }
}