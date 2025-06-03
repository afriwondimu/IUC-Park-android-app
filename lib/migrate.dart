import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iucpark/app_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'main.dart';
import 'models/motorbike.dart';


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
    await dbService.insertVehicle(vehicle);
    print('Migrated vehicle: ${vehicle.couponCode}');
  }

  await file.delete();
  print('Deleted vehicles.dat');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await migrateData();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(),
    ),
  );
}