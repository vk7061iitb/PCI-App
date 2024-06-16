import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pci_app/Functions/init_download_folder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../Objects/data_points.dart';
import '../Objects/pci_object.dart';
import '../Objects/stats_object.dart';

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
          db.execute(
              'CREATE TABLE pciDataStats(id INTEGER PRIMARY KEY AUTOINCREMENT, outputDataID INTEGER, pci TEXT, avgVelocity TEXT, distanceTravelled TEXT, numberOfSegments TEXT)');
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

  // Delete Acc Table in the database
  Future<void> deleteAcctables() async {
    await _database.delete('AccTable');
  }

  Future<List<Map<String, dynamic>>> queryTable(String tableName) async {
    return await _database.query(tableName);
  }

  // Export data to CSV file
  Future<String> exportToCSV(String fileName, String vehicleType) async {
    try {
      String accDataDirectoryPath = await initializeDirectory();
      List<Map<String, dynamic>> accTableQuery =
          await _database.query('AccTable');
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

      String accCSV = const ListToCsvConverter().convert(accCSVdata);
      String accFileName =
          '${fileName}_AccData_${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}_$vehicleType.csv';
      String accPath = '$accDataDirectoryPath/$accFileName';

      XFile accFile1 = XFile(accPath);
      File accFile = File(accPath);
      await accFile.writeAsString(accCSV);

      debugPrint('CSV files exported to path : $accDataDirectoryPath');
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

  Future<void> insertStats(List<OutputStats> stats) async {
    await _database.transaction((txn) async {
      var statsBatch = txn.batch();
      for (var data in stats) {
        statsBatch.rawInsert(
            'INSERT INTO pciDataStats(outputDataID, pci, avgVelocity, distanceTravelled, numberOfSegments) VALUES(?,?,?,?,?)',
            [
              data.outputDataID,
              data.pci,
              data.avgVelocity,
              data.distanceTravelled,
              data.numberOfSegments
            ]);
      }
      await statsBatch.commit();
      if (kDebugMode) {
        print('Stats Data inserted');
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

  Future<List<OutputStats>> queryStats(int outputDataID) async {
    List<Map<String, dynamic>> statsQuery = await _database.query(
        'pciDataStats',
        where: 'outputDataID = ?',
        whereArgs: [outputDataID]);

    List<OutputStats> stats = [];
    for (var data in statsQuery) {
      stats.add(
        OutputStats(
          outputDataID: data['outputDataID'],
          pci: data['pci'],
          avgVelocity: data['avgVelocity'],
          distanceTravelled: data['distanceTravelled'],
          numberOfSegments: data['numberOfSegments'],
        ),
      );
    }
    return stats;
  }
}
