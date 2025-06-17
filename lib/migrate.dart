import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'main.dart';
import 'models/motorbike.dart';
import 'app_state.dart';
import 'services/auth_service.dart';

Future<void> migrateData() async {
  final directory = await getExternalStorageDirectory();
  final dbPath = join(directory!.path, 'databases');
  await Directory(dbPath).create(recursive: true);
  final filePath = join(dbPath, 'vehicles.dat');
  final file = File(filePath);
  if (!await file.exists()) {
    print('No vehicles.dat found');
    return;
  }

  final jsonString = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(jsonString);
  final dbService = DatabaseService();

  for (var json in jsonList) {
    final vehicle = Motorbike.fromJson(json as Map<String, dynamic>);
    await dbService.insertVehicle(vehicle, 'iuc'); // Default to 'iuc' for old data
    print('Migrated vehicle: ${vehicle.couponCode}');
  }

  await file.delete();
  print('Deleted vehicles.dat');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('am', null);
  await migrateData();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(
        isLoggedIn: false, // Set this to the appropriate value
        currentUser: null, // Set this to the appropriate user object or null
      ),
    ),
  );
}