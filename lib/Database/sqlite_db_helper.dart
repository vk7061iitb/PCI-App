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
import '../Objects/pci_object.dart';

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
              'CREATE TABLE AccTable(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Speed REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE outputData(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE pciData(id INTEGER PRIMARY KEY AUTOINCREMENT, outputDataID INTEGER, latitude REAL, longitude REAL, velocity REAL, prediction REAL)');
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
            'INSERT INTO AccTable(x_acc, y_acc, z_acc, Latitude, Longitude, Speed, Time) VALUES(?,?,?,?,?,?,?)',
            [
              data.xAcc,
              data.yAcc,
              data.zAcc,
              data.latitude,
              data.longitude,
              data.speed * 3.6,
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

  Future<List<Map<String, dynamic>>> queryTable(String tableName) async {
    return await _database.query(tableName);
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
      XFile accFile1 = XFile(accPath);
      File accFile = File(accPath);
      await accFile.writeAsString(accCSV);

      debugPrint('CSV files exported to path : ${appExternalStorageDir.path}');

      await Share.shareXFiles([accFile1]);

      return 'Data Exported Successfully';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  Future<int> insertOutputData(String filename, String vehicleType) async {
    int id = -1;
    try {
      id = await _database.insert('outputData', {
        'filename': filename,
        'vehicleType': vehicleType,
        'Time': DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now())
      });
      if (kDebugMode) {
        print('OutputData ID: $id');
      }
      return id;
    } catch (e) {
      debugPrint(e.toString());
      return id;
    }
  }

  Future<void> insertPciData(List<PciData2> pciData) async {
    await _database.transaction((txn) async {
      var pciBatch = txn.batch();
      for (var data in pciData) {
        pciBatch.rawInsert(
          'INSERT INTO pciData(outputDataID, latitude, longitude, velocity, prediction) VALUES(?,?,?,?,?)',
          [
            data.outuputDataID,
            data.latitude,
            data.longitude,
            data.velocity,
            data.prediction
          ],
        );
      }
      await pciBatch.commit();
      if (kDebugMode) {
        print('PCI Data inserted');
      }
    });
  }

  Future<void> deleteOutputData(int id) async {
    await _database.delete('outputData', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PciData2>> queryPciData(int outputDataID) async {
    List<Map<String, dynamic>> pciDataQuery = await _database
        .query('pciData', where: 'outputDataID = ?', whereArgs: [outputDataID]);

    List<PciData2> pciData = [];
    for (var data in pciDataQuery) {
      pciData.add(
        PciData2(
          outuputDataID: data['outputDataID'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          velocity: data['velocity'],
          prediction: double.parse(
            data['prediction'].toString(),
          ),
        ),
      );
    }
    return pciData;
  }
}
