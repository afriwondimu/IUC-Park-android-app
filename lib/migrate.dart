import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iucpark/app_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart'; // Added import for provider
import 'services/database_service.dart';
import 'main.dart';
import 'models/motorbike.dart';


Future<void> migrateData() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = join(directory.path, 'vehicles.dat');
  final file = File(filePath);
  if (!await file.exists()) return;

  final jsonString = await file.readAsString();
  final List<dynamic> jsonList = jsonDecode(jsonString);
  final dbService = DatabaseService();

  for (var json in jsonList) {
    final vehicle = Motorbike.fromJson(json as Map<String, dynamic>);
    await dbService.insertVehicle(vehicle);
  }

  await file.delete();
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