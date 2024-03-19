import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../Functions/request_storage_permission.dart';
import '../Objects/data_points.dart';

class SQLDatabaseHelper {
  late Database _database;

  Future<void> initDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'localDB.db');

    try {
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          db.execute(
              'CREATE TABLE AccTable(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE GyroTable(id INTEGER PRIMARY KEY AUTOINCREMENT, x_Gyro REAL, y_Gyro REAL, z_Gyro REAL, Time TIMESTAMP)');
        },
        version: 1,
      );
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  Future<void> insertData(
      List<AccData> accdata, List<GyroData> gyrodata) async {
    await _database.transaction((txn) async {
      var accBatch = txn.batch();
      for (var data in accdata) {
        accBatch.rawInsert(
            'INSERT INTO AccTable(x_acc, y_acc, z_acc, Latitude, Longitude, Time) VALUES(?,?,?,?,?,?)',
            [
              data.xAcc,
              data.yAcc,
              data.zAcc,
              data.devicePosition.latitude,
              data.devicePosition.longitude,
              DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.accTime)
            ]);
      }
      await accBatch.commit();

      var gyroBatch = txn.batch();
      for (var data in gyrodata) {
        gyroBatch.rawInsert(
            'INSERT INTO GyroTable(x_Gyro, y_Gyro, z_Gyro, Time) VALUES(?,?,?,?)',
            [
              data.xGyro,
              data.yGyro,
              data.zGyro,
              DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.gyroTime)
            ]);
      }
      await gyroBatch.commit();
    });
  }

  Future<void> deleteAlltables() async {
    await _database.delete('AccTable');
    await _database.delete('GyroTable');
  }

  Future<String> exportToCSV(String fileName) async {
    try {
      await requestStoragePermission();
      String rawData = "Acceleration Data";
      String gyroDataFolder = "Acceleration Data";
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      Directory accDataDirectory =
          await Directory(join(appExternalStorageDir!.path, rawData))
              .create(recursive: true);
      Directory gyroaccDataDirectory =
          await Directory(join(appExternalStorageDir.path, gyroDataFolder))
              .create(recursive: true);

      // Check if folders exist
      if (await accDataDirectory.exists()) {
        debugPrint('Folder Already Exists');
        debugPrint("$accDataDirectory.path");
      } else {
        debugPrint('Folder Created');
      }

      List<Map<String, dynamic>> accTableQuery =
          await _database.query('AccTable');
      List<Map<String, dynamic>> gyroTableQuery =
          await _database.query('GyroTable');

      List<List<dynamic>> accCSVdata = [
        ['x_acc', 'y_acc', 'z_acc', 'Latitude', 'Longitude', 'accTime'],
        for (var row in accTableQuery)
          [
            row['x_acc'],
            row['y_acc'],
            row['z_acc'],
            row['Latitude'],
            row['Longitude'],
            row['Time']
          ],
      ];

      List<List<dynamic>> gyroCSVdata = [
        ['x_Gyro', 'y_Gyro', 'z_Gyro', 'Time'],
        for (var row in gyroTableQuery)
          [row['x_Gyro'], row['y_Gyro'], row['z_Gyro'], row['Time']],
      ];

      String accCSV = const ListToCsvConverter().convert(accCSVdata);
      String gyroCSV = const ListToCsvConverter().convert(gyroCSVdata);

      String accFileName =
          '${fileName}AccData${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv';
      String accPath = '${accDataDirectory.path}/$accFileName';

      String gyroFileName =
          '${fileName}GyroData${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}.csv'; // Corrected filename
      String gyroPath =
          '${gyroaccDataDirectory.path}/$gyroFileName'; // Corrected path

      File accFile = File(accPath);
      File gyroFile = File(gyroPath);

      await accFile.writeAsString(accCSV);
      await gyroFile.writeAsString(gyroCSV);

      debugPrint(
          'CSV files exported to path : ${appExternalStorageDir.path}'); // Updated debug message

      // Share the file
      // ignore: deprecated_member_use
      await Share.shareFiles([accPath, gyroPath]);

      return 'CSV files exported to path : ${appExternalStorageDir.path}'; // Updated return message
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}
