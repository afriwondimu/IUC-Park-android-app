import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService with ChangeNotifier {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _currentUserKey = 'currentUser';
  static const String _currentUsernameKey = 'currentUsername';
  static const String _isAdminKey = 'isAdmin';

  final DatabaseService _databaseService;
  String? _currentUser;
  String? _currentUsername;
  bool _isAdmin = false;

  // Predefined admin credentials
  static const String _adminPhoneNumber = '0912345678';
  static const String _adminPassword = '123';
  static const String _adminUsername = 'admin';

  AuthService() : _databaseService = DatabaseService() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_currentUserKey);
    final storedUsername = prefs.getString(_currentUsernameKey);
    _isAdmin = prefs.getBool(_isAdminKey) ?? false;
    if (storedUser != null) {
      _currentUser = storedUser;
      _currentUsername = storedUsername;
      notifyListeners();
    }
  }

  Future<bool> authenticate(String phoneNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (phoneNumber == _adminPhoneNumber && password == _adminPassword) {
      _currentUser = _adminPhoneNumber;
      _currentUsername = _adminUsername;
      _isAdmin = true;
      await prefs.setString(_currentUserKey, _currentUser!);
      await prefs.setString(_currentUsernameKey, _currentUsername!);
      await prefs.setBool(_isAdminKey, _isAdmin);
      await prefs.setBool(_isLoggedInKey, true);
      notifyListeners();
      return true;
    } else {
      final isAuthenticated = await _databaseService.authenticate(phoneNumber, password);
      if (isAuthenticated) {
        final user = await _databaseService.getUserByPhoneNumber(phoneNumber);
        if (user != null) {
          final users = await _databaseService.getAllUsers();
          final userData = users.firstWhere((u) => u['phone_number'] == phoneNumber);
          _currentUser = phoneNumber;
          _currentUsername = userData['username'];
          _isAdmin = false;
          await prefs.setString(_currentUserKey, _currentUser!);
          await prefs.setString(_currentUsernameKey, _currentUsername!);
          await prefs.setBool(_isAdminKey, _isAdmin);
          await prefs.setBool(_isLoggedInKey, true);
          notifyListeners();
          return true;
        }
      }
      return false;
    }
  }

  String? getCurrentUsername() {
    return _currentUsername;
  }

  bool isAdmin() {
    return _isAdmin;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (isLoggedIn) {
      _currentUser = prefs.getString(_currentUserKey);
      _currentUsername = prefs.getString(_currentUsernameKey);
      _isAdmin = prefs.getBool(_isAdminKey) ?? false;
      if (_currentUser == null) {
        await prefs.clear();
        notifyListeners();
        return false;
      }
    } else {
      _currentUser = null;
      _currentUsername = null;
      _isAdmin = false;
      await prefs.clear();
      notifyListeners();
    }
    return isLoggedIn;
  }

  Future<String?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentUsername = null;
    _isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}