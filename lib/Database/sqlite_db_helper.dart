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

  // Initialize the database
  Future<void> initDB() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'localDB.db');

    try {
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          // Create the AccTable
          db.execute(
              'CREATE TABLE AccTable(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Altitude REAL, Speed REAL, Time TIMESTAMP)');
        },
        version: 1,
      );
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  // Insert data into the database
  Future<void> insertData(
      List<AccData> accdata, List<GyroData> gyrodata) async {
    await _database.transaction((txn) async {
      var accBatch = txn.batch();
      for (var data in accdata) {
        accBatch.rawInsert(
            'INSERT INTO AccTable(x_acc, y_acc, z_acc, Latitude, Longitude, Altitude, Speed, Time) VALUES(?,?,?,?,?,?,?,?)',
            [
              data.xAcc,
              data.yAcc,
              data.zAcc,
              data.devicePosition.latitude,
              data.devicePosition.longitude,
              data.devicePosition.altitude,
              data.devicePosition.speed,
              DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.accTime)
            ]);
      }
      await accBatch.commit();
    });
  }

  // Delete all tables in the database
  Future<void> deleteAlltables() async {
    await _database.delete('AccTable');
  }

  // Export data to CSV file
  Future<String> exportToCSV(String fileName, String vehicleType) async {
    try {
      await requestStoragePermission();
      String rawData = "Acceleration Data";
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      Directory accDataDirectory =
          await Directory(join(appExternalStorageDir!.path, rawData))
              .create(recursive: true);

      // Check if folders exist
      if (await accDataDirectory.exists()) {
        debugPrint('Folder Already Exists');
        debugPrint("$accDataDirectory.path");
      } else {
        debugPrint('Folder Created');
      }

      // Query the AccTable
      List<Map<String, dynamic>> accTableQuery =
          await _database.query('AccTable');

      // Convert query result to CSV data
      List<List<dynamic>> accCSVdata = [
        [
          'x_acc',
          'y_acc',
          'z_acc',
          'Latitude',
          'Longitude',
          'Altitude',
          'Speed',
          'accTime'
        ],
        for (var row in accTableQuery)
          [
            row['x_acc'],
            row['y_acc'],
            row['z_acc'],
            row['Latitude'],
            row['Longitude'],
            row['Altitude'],
            row['Speed'],
            row['Time']
          ],
      ];

      // Convert CSV data to string
      String accCSV = const ListToCsvConverter().convert(accCSVdata);

      // Generate file name and path
      String accFileName =
          '${fileName}_AccData_${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}_$vehicleType.csv';
      String accPath = '${accDataDirectory.path}/$accFileName';

      // Create and write CSV file
      File accFile = File(accPath);
      await accFile.writeAsString(accCSV);

      debugPrint(
          'CSV files exported to path : ${appExternalStorageDir.path}'); // Updated debug message

      // Share the file
      // ignore: deprecated_member_use
      await Share.shareFiles([accPath]);
      return 'CSV files exported to path : ${appExternalStorageDir.path}'; // Updated return message
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}
