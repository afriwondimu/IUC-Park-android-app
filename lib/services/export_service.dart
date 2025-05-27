import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';

class ExportService {
  final DatabaseService _databaseService;

  ExportService(this._databaseService);

  Future<String> exportRecords(String date, int? plateNumber) async {
    try {
      if (date.length != 8 || !RegExp(r'^\d{8}$').hasMatch(date)) {
        return 'Invalid date format. Expected yyyyMMdd (e.g., 20250519)';
      }

      final year = int.parse(date.substring(0, 4));
      final month = int.parse(date.substring(4, 6));
      final day = int.parse(date.substring(6, 8));

      if (year < 2000 || month < 1 || month > 12 || day < 1 || day > 31) {
        return 'Invalid date. Use year ≥ 2000, month 01-12, day 01-31';
      }

      DateTime targetDate;
      try {
        targetDate = DateTime(year, month, day);
      } catch (e) {
        return 'Invalid date. Ensure valid date (e.g., not 20250230)';
      }

      bool hasPermission = await Permission.storage.isGranted;
      if (Platform.isAndroid) {
        hasPermission = hasPermission || await Permission.manageExternalStorage.isGranted;
        if (!hasPermission) {
          await [Permission.storage, Permission.manageExternalStorage].request();
          hasPermission = await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted;
        }
      }
      if (!hasPermission) {
        return 'Storage permission required. Please grant permission in app settings.';
      }

      String dirPath = '/storage/emulated/0/IUC Park';
      Directory dir = Directory(dirPath);
      bool useFallback = false;

      try {
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        if (!await dir.exists()) {
          useFallback = true;
        }
      } catch (e) {
        useFallback = true;
      }

      if (useFallback) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir == null) {
          return 'Error accessing storage: No external storage available.';
        }
        dirPath = '${externalDir.path}/IUC';
        dir = Directory(dirPath);
        try {
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          if (!await dir.exists()) {
            return 'Failed to create directory IUC in app storage.';
          }
        } catch (e) {
          return 'Error creating directory in app storage: ${e.toString()}';
        }
      }

      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final fileName = plateNumber == null
          ? 'report_${targetDate.toString().substring(0, 10)}.txt'
          : 'report_${targetDate.toString().substring(0, 10)}_$plateNumber.txt';
      final file = File('$dirPath/$fileName');

      try {
        final sink = file.openWrite();

        // Header with updated alignment
        sink.write('+--------------+--------------+------------------------+------------------------+\n');
        sink.write('| ታርጋ ቁጥር     | ኩፖን ቁጥር     |       የገባው               |        የወጣው            |\n');
        sink.write('+--------------+--------------+------------------------+------------------------+\n');

        final records = await _databaseService.getRecords(date: targetDate, plateNumber: plateNumber);
        bool hasRecords = false;

        for (var record in records) {
          final checkOut = record['check_out_time'] != null
              ? formatter.format(DateTime.parse(record['check_out_time']))
              : 'Not checked out';

          sink.write('| ${record['plate_number'].toString().padRight(12)}'
              '| ${record['coupon_code'].toString().padRight(12)}'
              '| ${formatter.format(DateTime.parse(record['check_in_time'])).padRight(24)}'
              '| ${checkOut.padRight(24)}|\n');

          hasRecords = true;
        }

        if (!hasRecords) {
          sink.close();
          try {
            await file.delete();
          } catch (e) {}
          return plateNumber == null
              ? 'በ ቀን ${targetDate.toString().substring(0, 10)} ምንም መረጃ የለም'
              : 'በ ቀን ${targetDate.toString().substring(0, 10)} እና ታርጋ ቁጥር $plateNumber ምንም መረጃ የለም';
        }

        sink.write('+--------------+--------------+------------------------+------------------------+\n');
        await sink.close();
        return 'Exported to $dirPath/$fileName';
      } catch (e) {
        return 'Error writing file: ${e.toString()}';
      }
    } catch (e) {
      return 'Error exporting: ${e.toString()}';
    }
  }
}
