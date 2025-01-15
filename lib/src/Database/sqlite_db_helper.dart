import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
          db.execute('PRAGMA foreign_keys = ON');
          db.execute(
            '''CREATE TABLE IF NOT EXISTS unsendDataInfo(
                  id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  filename TEXT, 
                  vehicleType TEXT,
                  Time TIMESTAMP,
                  planned TEXT
            )''',
          );
          db.execute(
            '''CREATE TABLE IF NOT EXISTS unsendData(
                  id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  x_acc REAL, 
                  y_acc REAL, 
                  z_acc REAL, 
                  Latitude REAL, 
                  Longitude REAL, 
                  Speed REAL,
                  roadType INTEGER, 
                  bnb INTEGER,
                  Time TIMESTAMP,
                  FOREIGN KEY (unsendDataID) REFERENCES unsendDataInfo(id) ON DELETE CASCADE
            )''',
          );

          db.execute(
            '''CREATE TABLE IF NOT EXISTS outputData(
                  id INTEGER PRIMARY KEY AUTOINCREMENT, 
                  filename TEXT, 
                  vehicleType TEXT, 
                  Time TIMESTAMP,
                  planned TEXT
              )''',
          );
          db.execute(
            '''CREATE TABLE IF NOT EXISTS roadOutputData(
                  id INTEGER PRIMARY KEY AUTOINCREMENT,  
                  roadName TEXT, 
                  labels TEXT, 
                  stats TEXT
                  FOREIGN KEY (journeyID) REFERENCES outputData(id) ON DELETE CASCADE
            )''',
          );

          /// status will be 0 for unsent, 1 for sent
          db.execute(
            '''CREATE TABLE IF NOT EXISTS savedData(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              filename TEXT, 
              time TEXT,
              vehicleType TEXT,
              path TEXT,
              status INTEGER,
          )''',
          );
        },
        onUpgrade: onUpgrade,
        version: 4,
      );
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      db.execute(
          '''ALTER TABLE outputData ADD COLUMN driveFileID TEXT DEFAULT ""''');
    }
  }

  Future<void> dbSize() async {
    int? pgCont = Sqflite.firstIntValue(
        await _localDbInstance.rawQuery('PRAGMA page_count'));
    int? pgSz = Sqflite.firstIntValue(
        await _localDbInstance.rawQuery('PRAGMA page_size'));
    final dbSizeinMB = (pgCont! * pgSz!) / (1024 * 1024);
    final message = 'Database size: $dbSizeinMB MB';
    logger.i(message);
  }

  Future<String> initializeDirectory() async {
    String rawData = "Acceleration Data";
    Directory? appExternalStorageDir = await getExternalStorageDirectory();
    Directory path = await Directory(join(appExternalStorageDir!.path, rawData))
        .create(recursive: true);
    return path.path;
  }

  Future<String> getReportDir() async {
    String report = "Reports";
    Directory? appExternalStorageDir = await getExternalStorageDirectory();
    Directory path = await Directory(join(appExternalStorageDir!.path, report))
        .create(recursive: true);
    return path.path;
  }

  Future<void> insertToUnsendData({
    required List<AccData> accdata,
    required int id,
  }) async {
    await _localDbInstance.transaction((txn) async {
      var accBatch = txn.batch();
      for (var data in accdata) {
        accBatch.insert(
          'unsendData',
          {
            'unsendDataID': id,
            'x_acc': data.xAcc,
            'y_acc': data.yAcc,
            'z_acc': data.zAcc,
            'Latitude': data.latitude,
            'Longitude': data.longitude,
            'Speed': data.speed,
            'roadType': data.roadType,
            'bnb': data.bnb,
            'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(data.accTime),
          },
        );
      }
      await accBatch.commit();
    });
  }

  Future<int> insertUnsendDataInfo({
    required String fileName,
    required String vehicleType,
    required DateTime time,
    required String planned,
  }) async {
    int id = -1;
    try {
      id = await _localDbInstance.insert(
        'unsendDataInfo',
        {
          'filename': fileName,
          'vehicleType': vehicleType,
          'Time': DateFormat('dd-MMM-yyyy HH:mm').format(time),
          'planned': planned,
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
  Future<int> insertJourneyData({
    required String filename,
    required String vehicleType,
    required DateTime time,
    required String planned,
  }) async {
    int id = -1;
    try {
      id = await _localDbInstance.insert('outputData', {
        'filename': filename,
        'vehicleType': vehicleType,
        'Time': DateFormat('dd-MMM-yyyy HH:mm').format(time),
        'planned': planned,
      });
      logger.d('OutputData ID: $id');
      return id;
    } catch (e) {
      logger.e(e.toString());
      return id;
    }
  }

  Future<void> updateJourneyData(String driveFileID, int id) async {
    logger.d("id: $id");
    logger.d("driveFileID: $driveFileID");
    try {
      _localDbInstance.update(
          'outputData',
          {
            'driveFileID': driveFileID,
          },
          where: 'id = ?',
          whereArgs: [id]);
    } catch (e) {
      logger.f(e);
    }
  }

  /// Delete the output data from the local database,
  ///  used in the output screen for deleting the data
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

  Future<List<Map<String, dynamic>>> querySavedFiles() async {
    try {
      List<Map<String, dynamic>> savedFiles =
          await _localDbInstance.query('savedData');
      return savedFiles;
    } catch (e) {
      logger.f("error while quering savedData: $e");
      return [];
    }
  }

  Future<void> deleteSavedFile(Map<String, dynamic> data) async {
    try {
      int count = await _localDbInstance.delete(
        'savedData',
        where: 'time = ?',
        whereArgs: [data['time']],
      );
      logger.i("$count files have been deleted");
    } catch (e, s) {
      logger.i("Error while deleting saved files : $e");
      logger.i("stacktrace: $s");
    }
  }

  Future<int> insertToSavedData(
    Map<String, dynamic> data,
  ) async {
    int id = -1;
    try {
      id = await _localDbInstance.insert('savedData', {
        'filename': data['filename'],
        'time': data['time'],
        'vehicleType': data['vehicleType'],
        'path': data['path'],
        'status': data['status']
      });
      return id;
    } catch (e, s) {
      logger.f("error while inserting to saved data:$e");
      logger.d("stacktrace: $s");
      return id;
    }
  }

  Future<void> updateSavedStatus(Map<String, dynamic> data) async {
    _localDbInstance.update(
      'savedData',
      {
        'filename': data['filename'],
        'time': data['time'],
        'vehicleType': data['vehicleType'],
        'path': data['path'],
        'status': data['status']
      },
      where: 'time = ?',
      whereArgs: [data['time']],
    );
  }

  Future<void> deleteTable(String table) async {
    _localDbInstance.delete(table);
  }
}
