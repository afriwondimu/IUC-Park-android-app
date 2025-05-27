import 'package:flutter/material.dart';
import '../widgets/export_form.dart';
import '../widgets/bottom_bar.dart';
import 'home_screen.dart'; // Added import for HomeScreen

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                        ), // Updated to navigate to HomeScreen
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Export Records',
                        style: TextStyle(
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
                        ExportForm(),
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
      bottomNavigationBar: BottomBar(
        parentContext: context,
        activeScreen: ActiveScreen.export,
      ),
    );
  }
}