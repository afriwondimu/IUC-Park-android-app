import 'package:flutter/material.dart';
import 'services/check_in_service.dart';
import 'services/check_out_service.dart';
import 'services/export_service.dart';
import 'services/database_service.dart';
import 'models/vehicle.dart';
import 'models/motorbike.dart';

class AppState extends ChangeNotifier {
  List<Vehicle> vehicles = [];
  List<bool> couponAvailability = List.generate(300, (_) => true);
  final DatabaseService databaseService = DatabaseService();
  late CheckInService checkInService;
  late CheckOutService checkOutService;
  late ExportService exportService;

  AppState() {
    checkInService = CheckInService(databaseService, couponAvailability);
    checkOutService = CheckOutService(databaseService, couponAvailability);
    exportService = ExportService(databaseService);
    _loadData();
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
}