import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pci_app/Objects/data.dart';
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
          db.execute(
              'CREATE TABLE IF NOT EXISTS unsendData(id INTEGER PRIMARY KEY AUTOINCREMENT, unsendDataID INTEGER, x_acc REAL, y_acc REAL, z_acc REAL, Latitude REAL, Longitude REAL, Speed REAL, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE IF NOT EXISTS unsendDataInfo(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
          db.execute(
              'CREATE TABLE IF NOT EXISTS outputData(id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, vehicleType TEXT, Time TIMESTAMP)');
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
              data.speed,
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
      logger.d('UnsendDataInfo ID: $id');
      return id;
    } catch (e) {
      logger.e(e.toString());
      return id;
    }
  }

  Future<List<Map<String, dynamic>>> queryUnsentData(int id) async {
    List<Map<String, dynamic>> unsentDataQuery = await _localDbInstance
        .query('unsendData', where: 'unsendDataID = ?', whereArgs: [id]);
    return unsentDataQuery;
  }

  Future<void> deleteUnsentDataInfo(int id) async {
    await _localDbInstance
        .delete('unsendDataInfo', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUnsentData(int id) async {
    await _localDbInstance
        .delete('unsendData', where: 'unsendDataID = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryTable(String tableName) async {
    return await _localDbInstance.query(tableName);
  }

  /// Insert the output data to the local database
  Future<int> insertJourneyData(
      String filename, String vehicleType, DateTime time) async {
    int id = -1;
    try {
      id = await _localDbInstance.insert('outputData', {
        'filename': filename,
        'vehicleType': vehicleType,
        'Time': DateFormat('dd-MMM-yyyy HH:mm').format(time)
      });
      logger.d('OutputData ID: $id');
      return id;
    } catch (e) {
      logger.e(e.toString());
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
      logger.i('Road Output Data inserted!');
    });
  }

  Future<List<Map<String, dynamic>>> queryRoadOutputData(
      {required jouneyID}) async {
    List<Map<String, dynamic>> roadOutputDataQuery = await _localDbInstance
        .query('roadOutputData', where: 'journeyID = ?', whereArgs: [jouneyID]);
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
