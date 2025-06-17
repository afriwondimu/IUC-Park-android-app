import 'dart:io';
import 'package:sqflite/sqflite.dart';
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
      final db = await openDatabase(
        path,
        version: 4,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE vehicles (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              coupon_code INTEGER NOT NULL,
              plate_number TEXT NOT NULL,
              check_in_time TEXT NOT NULL,
              checkout_time TEXT,
              auth1 TEXT,
              auth2 TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              phone_number TEXT UNIQUE NOT NULL,
              password TEXT NOT NULL
            )
          ''');
        },
      );
      return db;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getDatabasePath() async {
    final directory = await getExternalStorageDirectory();
    return join(directory!.path, 'databases', 'iucpark.db');
  }

  Future<bool> isCouponActive(int couponCode) async {
    try {
      final db = await getDatabase();
      final rows = await db.query(
        'vehicles',
        where: 'coupon_code = ? AND checkout_time IS NULL',
        whereArgs: [couponCode],
      );
      return rows.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> insertVehicle(Motorbike vehicle, String auth1) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'vehicles',
        {
          'coupon_code': vehicle.couponCode,
          'plate_number': vehicle.plateNumber,
          'check_in_time': vehicle.checkInTime.toIso8601String(),
          'checkout_time': vehicle.checkOutTime?.toIso8601String(),
          'auth1': auth1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCheckOut(int couponCode, DateTime checkOutTime, String auth2) async {
    try {
      final db = await getDatabase();
      await db.update(
        'vehicles',
        {
          'checkout_time': checkOutTime.toIso8601String(),
          'auth2': auth2,
        },
        where: 'coupon_code = ? AND checkout_time IS NULL',
        whereArgs: [couponCode],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Vehicle>> loadVehicles() async {
    try {
      final db = await getDatabase();
      final List<Map<String, dynamic>> maps = await db.query('vehicles');
      return maps.map((map) {
        return Motorbike(
          map['coupon_code'] as int,
          map['plate_number'] as String,
          DateTime.parse(map['check_in_time'] as String),
        )
          ..checkOutTime = map['checkout_time'] != null
              ? DateTime.parse(map['checkout_time'] as String)
              : null
          ..auth1 = map['auth1'] as String?
          ..auth2 = map['auth2'] as String?;
      }).toList();
    } catch (e) {
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
      List<Map<String, dynamic>> records;
      if (plateNumber != null) {
        records = await db.query(
          'vehicles',
          where: 'check_in_time >= ? AND check_in_time < ? AND plate_number = ?',
          whereArgs: [
            startOfDay.toIso8601String(),
            endOfDay.toIso8601String(),
            plateNumber,
          ],
        );
      } else {
        records = await db.query(
          'vehicles',
          where: 'check_in_time >= ? AND check_in_time < ?',
          whereArgs: [
            startOfDay.toIso8601String(),
            endOfDay.toIso8601String(),
          ],
        );
      }
      return records;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> authenticate(String phoneNumber, String password) async {
    try {
      final db = await getDatabase();
      final result = await db.query(
        'users',
        where: 'phone_number = ? AND password = ?',
        whereArgs: [phoneNumber, password],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      final db = await getDatabase();
      final result = await db.query(
        'users',
        where: 'phone_number = ?',
        whereArgs: [phoneNumber],
      );
      return result.isNotEmpty ? result.first['phone_number'] as String? : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser(String username, String phoneNumber, String password) async {
    try {
      final db = await getDatabase();
      await db.insert(
        'users',
        {
          'username': username,
          'phone_number': phoneNumber,
          'password': password,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final db = await getDatabase();
      final users = await db.query('users', columns: ['id', 'username', 'phone_number', 'password']);
      return users;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final db = await getDatabase();
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(int id, String username, String phoneNumber, String password) async {
    try {
      final db = await getDatabase();
      await db.update(
        'users',
        {
          'username': username,
          'phone_number': phoneNumber,
          'password': password,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> exportDatabase(String date) async {
    try {
      if (date.length != 8 || !RegExp(r'^\d{8}$').hasMatch(date)) {
        return 'Invalid date format. Expected yyyyMMdd (e.g., 20250519)';
      }
      final year = int.parse(date.substring(0, 4));
      final month = int.parse(date.substring(4, 6));
      final day = int.parse(date.substring(6, 8));
      DateTime targetDate;
      try {
        targetDate = DateTime(year, month, day);
      } catch (e) {
        return 'Invalid date.';
      }
      final dbPath = await getDatabasePath();
      final exportDir = Directory('/storage/emulated/0/IUC Park/DB');
      await exportDir.create(recursive: true);
      final exportPath = join(exportDir.path, 'iucpark_${targetDate.toString().substring(0, 10)}.db');
      final dbFile = File(dbPath);
      await dbFile.copy(exportPath);
      return 'Exported database to $exportPath';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      final db = await getDatabase();
      await db.close();
      _database = null;
    } catch (e) {
      rethrow;
    }
  }
}