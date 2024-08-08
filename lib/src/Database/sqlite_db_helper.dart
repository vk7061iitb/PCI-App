import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pci_app/Functions/init_download_folder.dart';
import 'package:pci_app/src/Models/user_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../Models/data_points.dart';
import '../Models/pci_data.dart';
import '../Models/stats_data.dart';

class SQLDatabaseHelper {
  late Database _localDbInstance;

  Future<void> initDB() async {
    var databaseDirectoryPath = await getDatabasesPath();
    String localDatabasePath = join(databaseDirectoryPath, 'local.db');

    try {
      _localDbInstance = await openDatabase(
        localDatabasePath,
        onCreate: (db, version) {
          /*
          * There are 5 tables in the database
          * 1. AccelerationData: Stores the acceleration + location data
          * 2. outputData: Stores the output data(only the filename and vehicle type), used to show the data on the output screen
          * 3. pciData: Stores the PCI data(lat,lng,velocity,PCI) for each outputDataID
          * 4. pciDataStats: Stores the stats data for each outputDataID
          * 5. userData: Stores the user data
          * 6. unsendData: Stores the data that was not sent to the server(due to no internet connection or server error)
          */
          db.execute(
              'CREATE TABLE AccelerationData(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Speed REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE unsendData(id INTEGER PRIMARY KEY AUTOINCREMENT, unsendDataID INTEGER, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Speed REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE unsendDataInfo(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE outputData(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE pciData(id INTEGER PRIMARY KEY AUTOINCREMENT, outputDataID INTEGER, latitude REAL, longitude REAL, velocity REAL, prediction REAL)');
          db.execute(
              'CREATE TABLE pciDataStats(id INTEGER PRIMARY KEY AUTOINCREMENT, outputDataID INTEGER, pci TEXT, avgVelocity TEXT, distanceTravelled TEXT, numberOfSegments TEXT)');
          db.execute(
              'CREATE TABLE userData(userID TEXT, phoneNumber TEXT, email TEXT)');
        },
        version: 1,
      );
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  /// Insert Acceleration + Location Data to the local database
  Future<void> insertAccData(List<AccData> accdata) async {
    await _localDbInstance.transaction((txn) async {
      var accBatch = txn.batch();
      for (var data in accdata) {
        accBatch.rawInsert(
            'INSERT INTO AccelerationData(x_acc, y_acc, z_acc, Latitude, Longitude, Speed, Time) VALUES(?,?,?,?,?,?,?)',
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

  Future<void> insertToUnsendData({
    required List<AccData> accdata,
    required int id,
  }) async {
    await _localDbInstance.transaction((txn) async {
      var accBatch = txn.batch();
      for (var data in accdata) {
        accBatch.rawInsert(
            'INSERT INTO unsendData(unsendDataID, x_acc, y_acc, z_acc, Latitude, Longitude, Speed, Time) VALUES(?,?,?,?,?,?,?,?)',
            [
              id,
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

  Future<int> insertUnsendDataInfo(
      {required String fileName, required String vehicleType}) async {
    int id = -1;
    try {
      id = await _localDbInstance.insert(
        'unsendDataInfo',
        {
          'filename': fileName,
          'vehicleType': vehicleType,
          'Time': DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())
        },
      );
      debugPrint('UnsendDataInfo ID: $id');
      return id;
    } catch (e) {
      debugPrint(e.toString());
      return id;
    }
  }

  Future<void> deleteAcctables() async {
    await _localDbInstance.delete('AccelerationData');
  }

  Future<List<Map<String, dynamic>>> queryTable(String tableName) async {
    return await _localDbInstance.query(tableName);
  }

  Future<String> exportToCSV(String fileName, String vehicleType) async {
    try {
      String accDataDirectoryPath = await initializeDirectory();
      List<Map<String, dynamic>> accTableQuery =
          await _localDbInstance.query('AccelerationData');
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
          '$fileName#AccelerationData#${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())}#$vehicleType.csv';
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

  /// Insert the user data to the local database
  Future<String> insertUserData(UserData user) async {
    await _localDbInstance.transaction(
      (txn) async {
        txn.rawInsert(
            'INSERT INTO userData(userID, phoneNumber, email) VALUES(?,?,?)',
            [user.userID, user.phoneNumber, user.email]);
      },
    );
    debugPrint('User Data Inserted');
    return 'User Data Inserted';
  }

  /// Query the user data from the local database
  Future<UserData> queryUserData() async {
    try {
      List<Map<String, dynamic>> userDataQuery =
          await _localDbInstance.query('userData');
      if (userDataQuery.isEmpty) {
        return UserData(userID: 'null', phoneNumber: 'null', email: 'null');
      } else {
        UserData user = UserData(
          userID: userDataQuery[0]['userID'],
          phoneNumber: userDataQuery[0]['phoneNumber'],
          email: userDataQuery[0]['email'],
        );
        return user;
      }
    } catch (error) {
      debugPrint(error.toString());
      return UserData(userID: '0', phoneNumber: '0', email: '0');
    }
  }

  /// Delete the user data from the local database
  Future<void> deleteUserData() async {
    await _localDbInstance.delete('userData');
  }

  /// Insert the output data to the local database
  Future<int> insertOutputData(String filename, String vehicleType) async {
    int id = -1;
    try {
      id = await _localDbInstance.insert('outputData', {
        'filename': filename,
        'vehicleType': vehicleType,
        'Time': DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())
      });
      debugPrint('OutputData ID: $id');
      return id;
    } catch (e) {
      debugPrint(e.toString());
      return id;
    }
  }

  /// Insert the PCI Data to the local database
  Future<void> insertPciData(List<PciData2> pciData) async {
    await _localDbInstance.transaction((txn) async {
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
      debugPrint('PCI Data inserted');
    });
  }

  /// Insert the Road Statistics to the local database
  Future<void> insertStats(List<OutputStats> stats) async {
    await _localDbInstance.transaction((txn) async {
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
      debugPrint('Stats Data inserted');
    });
  }

  /// Delete the output data from the local database, used in the output screen for deleting the data
  Future<void> deleteOutputData(int id) async {
    await _localDbInstance
        .delete('outputData', where: 'id = ?', whereArgs: [id]);
  }

  /// Query the PCI Data to show it on the Map Page
  Future<List<PciData2>> queryPciData(int outputDataID) async {
    List<Map<String, dynamic>> pciDataQuery = await _localDbInstance
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

  /// Query the Road Statistics to show it on the Map Page
  Future<List<OutputStats>> queryStats(int outputDataID) async {
    List<Map<String, dynamic>> statsQuery = await _localDbInstance.query(
      'pciDataStats',
      where: 'outputDataID = ?',
      whereArgs: [outputDataID],
    );

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
