import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/motorbike.dart';
import '../models/vehicle.dart';

class FileService {
  Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/vehicles.dat';
  }

  Future<List<Vehicle>> loadFromFile() async {
    try {
      final file = File(await _filePath);
      if (!await file.exists()) return [];
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Motorbike.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveToFile(List<Vehicle> vehicles) async {
    try {
      final file = File(await _filePath);
      final jsonList = vehicles.map((v) => v.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Error saving data');
    }
  }
}