import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  final currentUser = authService.getCurrentUsername();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => authService),
      ],
      child: MyApp(
        isLoggedIn: isLoggedIn,
        currentUser: currentUser,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? currentUser;

  const MyApp({
    super.key, 
    required this.isLoggedIn,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Motor Coupon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (!isLoggedIn || currentUser == null) {
      return const LoginScreen();
    }
    return currentUser == 'admin' ? const AdminScreen() : const HomeScreen();
  }
}