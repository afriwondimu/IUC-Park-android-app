import 'dart:io';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/motorbike.dart';
import '../models/vehicle.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final directory = await getExternalStorageDirectory();
      final dbPath = join(directory!.path, 'databases');
      await Directory(dbPath).create(recursive: true);
      final path = join(dbPath, 'iucpark.db');
      print('Database path: $path');
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          print('Creating vehicles table');
          await db.execute('''
            CREATE TABLE vehicles (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              coupon_code INTEGER NOT NULL,
              plate_number TEXT NOT NULL,
              check_in_time TEXT NOT NULL,
              checkout_time TEXT
            )
          ''');
        },
      );
      print('Database opened successfully');
      return db;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<bool> isCouponActive(int couponCode) async {
    try {
      final db = await getDatabase();
      final rows = await db.query(
        'vehicles',
        where: 'coupon_code = ? AND checkout_time IS NULL',
        whereArgs: [couponCode],
      );
      print('Coupon $couponCode active: ${rows.isNotEmpty}');
      return rows.isNotEmpty;
    } catch (e) {
      print('Error checking coupon: $e');
      return false;
    }
  }

  Future<void> insertVehicle(Motorbike vehicle) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'vehicles',
        {
          'coupon_code': vehicle.couponCode,
          'plate_number': vehicle.plateNumber,
          'check_in_time': vehicle.checkInTime.toIso8601String(),
          'checkout_time': vehicle.checkOutTime?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Vehicle inserted: ${vehicle.couponCode}');
    } catch (e) {
      print('Error inserting vehicle: $e');
      rethrow;
    }
  }

  Future<void> updateCheckOut(int couponCode, DateTime checkOutTime) async {
    try {
      final db = await getDatabase();
      await db.update(
        'vehicles',
        {'checkout_time': checkOutTime.toIso8601String()},
        where: 'coupon_code = ? AND checkout_time IS NULL',
        whereArgs: [couponCode],
      );
      print('Updated checkout for: $couponCode');
    } catch (e) {
      print('Error updating checkout: $e');
      rethrow;
    }
  }

  Future<List<Vehicle>> loadVehicles() async {
    try {
      final db = await getDatabase();
      final List<Map<String, dynamic>> maps = await db.query('vehicles');
      print('Loaded ${maps.length} vehicles');
      return maps.map((map) {
        return Motorbike(
          map['coupon_code'] as int,
          map['plate_number'] as String,
          DateTime.parse(map['check_in_time'] as String),
        )..checkOutTime = map['checkout_time'] != null
            ? DateTime.parse(map['checkout_time'] as String)
            : null;
      }).toList();
    } catch (e) {
      print('Error loading vehicles: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRecords({
    required DateTime date,
    String? plateNumber,
  }) async {
    try {
      final db = await getDatabase();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      if (plateNumber != null) {
        final records = await db.query(
          'vehicles',
          where: 'check_in_time >= ? AND check_in_time < ? AND plate_number = ?',
          whereArgs: [
            startOfDay.toIso8601String(),
            endOfDay.toIso8601String(),
            plateNumber,
          ],
        );
        print('Fetched ${records.length} records for plate $plateNumber');
        return records;
      }
      final records = await db.query(
        'vehicles',
        where: 'check_in_time >= ? AND check_in_time < ?',
        whereArgs: [
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
      );
      print('Fetched ${records.length} records for date $date');
      return records;
    } catch (e) {
      print('Error fetching records: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      final db = await getDatabase();
      await db.close();
      _database = null;
      print('Database closed');
    } catch (e) {
      print('Error closing database: $e');
      rethrow;
    }
  }
}