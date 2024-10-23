import 'dart:convert';
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
import '../Models/stats_data.dart';

class SQLDatabaseHelper {
  late Database _localDbInstance;

  Future<void> initDB() async {
    var databaseDirectoryPath = await getDatabasesPath();
    String localDatabasePath = join(databaseDirectoryPath, 'pci_app.db');

    try {
      _localDbInstance = await openDatabase(
        localDatabasePath,
        onCreate: (db, version) {
          /*
          * There are 5 tables in the database
          * 1. AccelerationData: Stores the acceleration + location data
          * 2. outputData: Stores the output data(only the filename and vehicle type), used to show the data on the output screen
          * 5. userData: Stores the user data
          * 6. unsendData: Stores the data that was not sent to the server(due to no internet connection or server error)
          */
          db.execute(
              'CREATE TABLE IF NOT EXISTS AccelerationData(id INTEGER PRIMARY KEY AUTOINCREMENT, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Speed REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE IF NOT EXISTS unsendData(id INTEGER PRIMARY KEY AUTOINCREMENT, unsendDataID INTEGER, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Speed REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE IF NOT EXISTS unsendDataInfo(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE IF NOT EXISTS outputData(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE IF NOT EXISTS userData(userID TEXT, phoneNumber TEXT, email TEXT, userRole TEXT)');
          db.execute(
            'CREATE TABLE IF NOT EXISTS roadOutputData(id INTEGER PRIMARY KEY AUTOINCREMENT, journeyID INTEGER, roadName TEXT, labels TEXT, stats TEXT)',
          );
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

  Future<void> deleteUnsentDataInfo(int id) async {
    await _localDbInstance
        .delete('unsendDataInfo', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUnsentData(int id) async {
    await _localDbInstance
        .delete('unsendData', where: 'unsendDataID = ?', whereArgs: [id]);
  }

  Future<void> deleteAcctables() async {
    await _localDbInstance.delete('AccelerationData');
  }

  Future<void> deleteTable(String tableName) async {
    await _localDbInstance.delete(tableName);
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
          'INSERT INTO userData(userID, phoneNumber, email, userRole) VALUES(?,?,?,?)',
          [user.userID, user.phoneNumber, user.email, user.userRole],
        );
      },
    );
    debugPrint(
        'User Data Inserted : {${user.email}, ${user.phoneNumber}, ${user.userRole}}');
    return 'User Data Inserted';
  }

  /// Query the user data from the local database
  Future<UserData> queryUserData() async {
    try {
      List<Map<String, dynamic>> userDataQuery =
          await _localDbInstance.query('userData');
      if (userDataQuery.isEmpty) {
        return UserData(
            userID: 'null',
            phoneNumber: 'null',
            email: 'null',
            userRole: 'null');
      } else {
        UserData user = UserData(
          userID: userDataQuery[0]['userID'],
          phoneNumber: userDataQuery[0]['phoneNumber'],
          email: userDataQuery[0]['email'],
          userRole: userDataQuery[0]['userRole'],
        );
        return user;
      }
    } catch (error) {
      debugPrint(error.toString());
      return UserData(userID: '0', phoneNumber: '0', email: '0', userRole: '0');
    }
  }

  /// Delete the user data from the local database
  Future<void> deleteUserData() async {
    await _localDbInstance.delete('userData');
  }

  /// Insert the output data to the local database
  Future<int> insertJourneyData(String filename, String vehicleType) async {
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

  /// Delete the output data from the local database, used in the output screen for deleting the data
  Future<void> deleteOutputData(int id) async {
    await _localDbInstance.delete(
      'outputData',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertToRoadOutputData({
    required List<RoadOutputData> roadOutputData,
  }) async {
    await _localDbInstance.transaction((txn) async {
      var roadOutputDataBatch = txn.batch();
      for (var data in roadOutputData) {
        roadOutputDataBatch.rawInsert(
          'INSERT INTO roadOutputData(journeyID, roadName, labels, stats) VALUES(?,?,?,?)',
          [
            data.outputDataID,
            data.roadData.roadName,
            jsonEncode(data.roadData.labels),
            jsonEncode(data.roadData.stats),
          ],
        );
      }
      await roadOutputDataBatch.commit();
      debugPrint('Road Output Data inserted!');
    });
  }

  Future<List<Map<String, dynamic>>> queryRoadOutputData(int id) async {
    List<Map<String, dynamic>> roadOutputDataQuery = await _localDbInstance
        .query('roadOutputData', where: 'journeyID = ?', whereArgs: [id]);
    return roadOutputDataQuery;
  }

  Future<void> deleteRoadOutputData(int id) async {
    await _localDbInstance.delete(
      'roadOutputData',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
