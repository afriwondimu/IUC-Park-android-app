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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'iucpark.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vehicles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            coupon_code INTEGER NOT NULL,
            plate_number INTEGER NOT NULL,
            check_in_time TEXT NOT NULL,
            check_out_time TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertVehicle(Motorbike vehicle) async {
    final db = await database;
    await db.insert(
      'vehicles',
      {
        'coupon_code': vehicle.couponCode,
        'plate_number': vehicle.plateNumber,
        'check_in_time': vehicle.checkInTime.toIso8601String(),
        'check_out_time': vehicle.checkOutTime?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCheckOut(int couponCode, DateTime checkOutTime) async {
    final db = await database;
    await db.update(
      'vehicles',
      {'check_out_time': checkOutTime.toIso8601String()},
      where: 'coupon_code = ? AND check_out_time IS NULL',
      whereArgs: [couponCode],
    );
  }

  Future<List<Vehicle>> loadVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehicles');
    return maps.map((map) {
      return Motorbike(
        map['coupon_code'],
        map['plate_number'],
        DateTime.parse(map['check_in_time']),
      )..checkOutTime = map['check_out_time'] != null
          ? DateTime.parse(map['check_out_time'])
          : null;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getRecords({
    required DateTime date,
    int? plateNumber,
  }) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    if (plateNumber != null) {
      return await db.query(
        'vehicles',
        where: 'check_in_time >= ? AND check_in_time < ? AND plate_number = ?',
        whereArgs: [
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
          plateNumber,
        ],
      );
    }
    return await db.query(
      'vehicles',
      where: 'check_in_time >= ? AND check_in_time < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}