import 'package:flutter/material.dart';
import 'services/check_in_service.dart';
import 'services/check_out_service.dart';
import 'services/export_service.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'models/vehicle.dart';
import 'models/motorbike.dart';

class AppState extends ChangeNotifier {
  List<Vehicle> vehicles = [];
  List<bool> couponAvailability = List.generate(300, (_) => true);
  final DatabaseService databaseService;
  final AuthService authService;
  late CheckInService checkInService;
  late CheckOutService checkOutService;
  late ExportService exportService;

  AppState() : databaseService = DatabaseService(), authService = AuthService() {
    checkInService = CheckInService(databaseService, authService);
    checkOutService = CheckOutService(databaseService, couponAvailability, authService);
    exportService = ExportService(databaseService);
    _loadData();
    authService.addListener(_onAuthChange);
  }

  void _onAuthChange() {
    notifyListeners();
  }

  Future<void> _loadData() async {
    vehicles = await databaseService.loadVehicles();
    for (var v in vehicles) {
      if (v is Motorbike && v.checkOutTime == null) {
        couponAvailability[v.couponCode - 1] = false;
      }
    }
    notifyListeners();
  }

  Future<void> saveData() async {
    await _loadData();
    notifyListeners();
  }


  String? getCurrentUsername() {
    return authService.getCurrentUsername();
  }

  Future<void> login(String phoneNumber, String password) async {
    final success = await authService.authenticate(phoneNumber, password);
    if (success) {
      notifyListeners();
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    await authService.logout();
    vehicles.clear();
    couponAvailability = List.generate(300, (_) => true);
    notifyListeners();
  }

  @override
  void dispose() {
    authService.removeListener(_onAuthChange);
    super.dispose();
  }
}