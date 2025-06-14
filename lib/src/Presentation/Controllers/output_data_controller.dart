import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pciapp/Utils/set_road_stats.dart';
import 'package:pciapp/Utils/to_geojson.dart';
import 'package:pciapp/src/Models/stats_data.dart';
import 'package:pciapp/src/Presentation/Controllers/map_page_controller.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';
import 'package:pciapp/src/service/report_pdf_api.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Utils/vel_to_pci.dart';
import '../../../Objects/data.dart';
import 'dart:ui' as ui;

import '../../service/drive_helper.dart';

/// Controller for managing output data(Jorney Data)
class OutputDataController extends GetxController {
  // the output data file stores all the journey metadata from local db,
  // this used in showing this list tile in jounrney page
  var outputDataFile = <Map<String, dynamic>>[].obs;
  RxSet<int> slectedFiles =
      <int>{}.obs; // store the current slected file(s) to be plotted on the map
  var isLoading = true.obs;
  RxBool showProgressInStatsPage = true.obs;
  GlobalKey repaintKey = GlobalKey();
  Uint8List screenShotBytes = Uint8List.fromList([]);
  final MapPageController _mapPageController = Get.find<MapPageController>();

  /// Fetches the user's jouney data from the local database
  Future<List<Map<String, dynamic>>> fetchData() async {
    String tableToFetch = 'outputData';
    try {
      isLoading.value = true;
      await localDatabase.queryTable(tableToFetch).then((value) {
        outputDataFile.value = value.reversed.toList();
        isLoading.value = false;
      });
    } catch (e) {
      customGetSnackBar(
          "Database Error", "Failed to fetch data: $e", Icons.error_outline);
      logger.e(e.toString());
    }
    return outputDataFile;
  }

  Future<Uint8List> takeSS() async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    final img = await boundary.toImage(pixelRatio: 1);
    final bytedata = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );
    screenShotBytes = bytedata!.buffer.asUint8List();
    return screenShotBytes;
  }

  /// Deletes the data associated with the given [id].
  ///
  /// This method performs an asynchronous operation to delete the data
  /// from the data source. Ensure that the [id] provided is valid and
  /// corresponds to an existing data entry.
  ///
  /// Throws an exception if the deletion fails.
  Future<void> deleteData(int id) async {
    try {
      await localDatabase.deleteOutputData(id);
      fetchData(); // refresh the data
    } catch (e) {
      customGetSnackBar(
          "Databse Error", "Failed to delete data: $e", Icons.error_outline);
      logger.e(e.toString());
    }
  }

  /// Exports data to a specified file.
  ///
  /// This function exports data to a file with the given [filename].
  /// The [vehicle] parameter specifies the vehicle information to be included in the export.
  /// The [time] parameter specifies the time information to be included in the export.
  ///
  /// Throws an [Exception] if the export fails.
  /// Exports the data to a CSV file and shares it with the user
  ///
  Future<void> exportData({
    required String filename,
    required String vehicle,
    required String planned,
    required String time,
    required List<Map<String, dynamic>> jouneyData,
  }) async {
    List<List<dynamic>> csvData = [];
    // Add metadata
    csvData.add([
      'FileName',
      'VehicleType',
      'UserNo',
      'Planned/Unplanned',
      'Date',
      'Time',
    ]);
    csvData.add(
      [
        filename,
        vehicle,
        userDataController.storage.read('user')['phone'],
        planned,
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
        DateFormat('HH:mm:ss').format(DateTime.now()),
      ],
    );
    // Add data
    csvData.add([
      'Road Name',
      'Latitude',
      'Longitude',
      'PCI(prediction)',
      'PCI(velocity)',
      'Velocity(km/hr)',
    ]);
    for (var road in jouneyData) {
      String roadName = road["roadName"];
      List<dynamic> labels = jsonDecode(road["labels"]);

      // add the velocity_prediction in the labels
      for (int i = 0; i < labels.length; i++) {
        labels[i]['vel_prediction'] = velocityToPCI(
            velocityKmph: labels[i]['velocity'] * 3.6); // convert to km/hr
      }

      for (int i = 0; i < labels.length; i++) {
        List<dynamic> row = [];
        row.add(roadName);
        row.add(labels[i]['latitude']);
        row.add(labels[i]['longitude']);
        row.add(labels[i]['prediction']);
        row.add(labels[i]['vel_prediction']);
        row.add(labels[i]['velocity'] * 3.6); // convert to km/hr
        csvData.add(row);
      }
    }
    final tempdir = await getTemporaryDirectory();
    String csv = const ListToCsvConverter().convert(csvData);
    String fileName = '$filename-$vehicle-$time.csv';
    String path = '${tempdir.path}/$fileName';
    File file = File(path);
    file.writeAsString(csv);
    XFile fileToShare = XFile(path);
    await fileToShare.readAsString();
    Share.shareXFiles([fileToShare]).then((value) {
      file.delete();
    });
  }

  Future<void> exportJSON({
    required List<Map<String, dynamic>> query,
    required Map<String, dynamic> metaData,
    bool exportGeoJSON = false,
  }) async {
    List<Map<String, dynamic>> finalData = query.map((row) {
      return {
        ...row,
        "labels":
            row["labels"] is String ? jsonDecode(row["labels"]) : row["labels"],
        "stats":
            row["stats"] is String ? jsonDecode(row["stats"]) : row["stats"],
      };
    }).toList();

    Map<String, dynamic> data;
    if (exportGeoJSON) {
      data = toGeoJSON(finalData, metaData);
    } else {
      data = {"data": finalData, "info": metaData};
    }

    final fileExtensionName = (exportGeoJSON) ? ".geojson" : ".json";
    // make a temporary direnctory
    final tempDir = await localDatabase.getTempDir();
    String path = '$tempDir/${metaData['filename']}$fileExtensionName';
    File file = File(path);

    file.writeAsString(jsonEncode(data));
    XFile fileToShare = XFile(path);
    await fileToShare.readAsString();
    Share.shareXFiles([fileToShare]).then((value) {
      file.delete();
    });
  }

  /// Creates a ZIP file asynchronously.
  ///
  /// This method performs the necessary operations to generate a ZIP file
  /// containing the required data. It does not take any parameters and
  /// returns a [Future] that completes when the ZIP file creation is finished.
  ///
  /// Throws an exception if the ZIP file creation fails.
  Future<void> makeZip() async {
    final Archive archive = Archive();
    for (int id in slectedFiles) {
      List<Map<String, dynamic>> roadOutputDataQuery =
          await localDatabase.queryRoadOutputData(journeyID: id);

      Map<String, dynamic> currRoadData = {};
      for (var road in outputDataFile) {
        if (road["id"] == id) {
          currRoadData = road;
          break;
        }
      }
      List<List<dynamic>> csvData = [];
      csvData.add([
        'Road Name',
        'Latitude',
        'Longitude',
        'PCI(prediction)',
        'PCI(velocity)',
        'Velocity(km/hr)',
      ]);
      for (var road in roadOutputDataQuery) {
        String roadName = road["roadName"];
        List<dynamic> labels = jsonDecode(road["labels"]);

        // add the velocity_prediction in the labels
        for (int i = 0; i < labels.length; i++) {
          labels[i]['vel_prediction'] = velocityToPCI(
              velocityKmph: labels[i]['velocity'] * 3.6); // convert to km/hr
        }

        for (int i = 0; i < labels.length; i++) {
          List<dynamic> row = [];
          row.add(roadName);
          row.add(labels[i]['latitude']);
          row.add(labels[i]['longitude']);
          row.add(labels[i]['prediction']);
          row.add(labels[i]['vel_prediction']);
          row.add(labels[i]['velocity'] * 3.6); // convert to km/hr
          csvData.add(row);
        }
        final tempdir = await getTemporaryDirectory();
        String csv = const ListToCsvConverter().convert(csvData);
        String fileName =
            '${currRoadData['filename']}-${currRoadData['vehicleType']}-${currRoadData['Time']}.csv';
        String path = '${tempdir.path}/$fileName';
        File file = File(path);
        file.writeAsString(csv);

        // add the file to the archive
        final List<int> bytes = await file.readAsBytes();
        ArchiveFile archiveFile = ArchiveFile(
          file.path.split("/").last,
          bytes.length,
          bytes,
        );
        archive.addFile(archiveFile);
      }
    }
    final List<int> zipData = ZipEncoder().encode(archive)!;
    final tempdir = await getTemporaryDirectory();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd_HH-mm");
    final time = dateFormat.format(DateTime.now());
    String zipPath = '${tempdir.path}/${time}_JourneyData.zip';
    final File file = File(zipPath);
    await file.writeAsBytes(zipData);

    XFile fileToShare = XFile(zipPath);
    await fileToShare.readAsBytes();
    Share.shareXFiles([fileToShare]).then((value) {
      file.delete();
    });
  }

  /// Plots the roads on the map.
  ///
  /// This method fetches the necessary data and updates the map with the
  /// plotted roads. It is an asynchronous operation and should be awaited
  /// to ensure the roads are plotted before proceeding.
  ///
  /// Throws:
  /// - [Exception] if there is an error during the plotting process.
  ///
  /// Usage:
  /// ```dart
  /// await plotRoads();
  /// ```
  ///
  /// Note: Ensure that the map is initialized before calling this method.
  Future<void> plotRoads() async {
    _mapPageController.clearData();
    // note: if user selects multiple files at the same time, then plot all of them
    for (int id in slectedFiles) {
      List<Map<String, dynamic>> roadOutputDataQuery = await localDatabase
          .queryRoadOutputData(journeyID: id); // get pci data for a road

      Map<String, dynamic> currRoadData = {};
      for (var road in outputDataFile) {
        // get the id for metadata
        if (road["id"] == id) {
          currRoadData = road;
          break;
        }
      }
      var roadMetaData = {
        "filename": currRoadData["filename"],
        "vehicleType": currRoadData["vehicleType"],
        "time": currRoadData["Time"],
      };
      logger.d("plotting road: ${currRoadData["filename"]}");
      _mapPageController.selectedRoads.add(roadMetaData);
      _mapPageController.roadOutputData.add(roadOutputDataQuery);
    }
    await _mapPageController.plotRoadData();
  }

  Future<void> dowloadReport(Map<String, dynamic> data) async {
    GenerateReport report = GenerateReport();
    try {
      await report
          .generateReport(
        filename: data['filename'],
      )
          .then((message) {
        Get.showSnackbar(
          customGetSnackBar(
            "Report",
            message,
            Icons.message_outlined,
          ),
        );
      });
    } catch (e) {
      logger.e(e.toString());
    }
  }

  // upload the JSON formatted journey data and inset to the database
  Future<void> insertJourneyDataviaUpload() async {
    File? file;
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: 'Please select the journey file',
    );
    if (res != null) {
      file = File(res.files.single.path!);
    }
    if (file == null) {
      return;
    }
    int outputDataID = -1;
    try {
      String jsonData = await file.readAsString();
      // decode the JSON string
      final decodeJSONdata = jsonDecode(jsonData);
      // extract the metadata
      final metaData = decodeJSONdata['info'];
      // extract the output data
      final outputData = decodeJSONdata['data']; // may contains multiple road
      // insert to database
      outputDataID = await localDatabase.insertJourneyData(
        filename: metaData['filename'],
        vehicleType: metaData['vehicleType'],
        time: dateTimeParser.parseDateTime(
            metaData['time'], "dd-MMM-yyyy HH:mm")!,
        planned: metaData['planned'] ?? "Planned",
      );
      List<RoadOutputData> roadOutputData = [];
      // extract each road and insert to db
      for (var road in outputData) {
        RoadData roadData = RoadData(
          roadName: road['roadName'],
          labels: parseLabels(road['labels']),
          stats: parseStats(road['stats']),
        );
        roadOutputData.add(
          RoadOutputData(
            outputDataID: outputDataID,
            roadData: roadData,
          ),
        );
      }
      // finally inert to database after verification
      localDatabase.insertToRoadOutputData(roadOutputData: roadOutputData);
    } catch (error, stackTrace) {
      if (outputDataID != -1) {
        await localDatabase.deleteOutputData(outputDataID);
      }
      logger.d(error);
      logger.d(stackTrace);
      Get.showSnackbar(customGetSnackBar(
          "Import Failed", error.toString(), Icons.error_outline));
    } finally {
      await fetchData();
    }
  }

  List<Map<String, dynamic>> parseLabels(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e as Map<String, dynamic>).toList();
    }

    if (raw is String) {
      // Decode once
      final decoded = jsonDecode(raw);

      if (decoded is String) {
        // Double-encoded: decode again
        return (jsonDecode(decoded) as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }

      return (decoded as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    throw FormatException("Unsupported labels format");
  }

  Map<String, dynamic> parseStats(dynamic raw) {
    if (raw is String) return jsonDecode(raw);
    return raw as Map<String, dynamic>;
  }

  Future<void> uploadToDrive(Map<String, dynamic> metaData, int id) async {
    try {
      DriveHelper driveHelper = DriveHelper();
      String? appFolderID = await driveHelper.createAppFolder();
      if (appFolderID == null) {
        return;
      }
      String? journeyfolderID =
          await driveHelper.createFolder("journeys", appFolderID);
      List<Map<String, dynamic>> query =
          await localDatabase.queryRoadOutputData(journeyID: id);
      final data = {"data": query, "info": metaData};
      final tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/${metaData['filename']}.json';
      File file = File(path);
      file.writeAsString(jsonEncode(data));
      String? fileID = await driveHelper.uploadJourneyData(
          file, journeyfolderID ?? "", metaData['filename']);
      if (fileID == null) {
        return;
      }
      await localDatabase.updateJourneyData(fileID, id);
      Get.showSnackbar(
        customGetSnackBar(
            "Uploaded", "Journey succesfully uploaded to drive", Icons.check),
      );
    } catch (error, stackTrace) {
      logger.f(error);
      logger.d(stackTrace);
      customGetSnackBar(
        "Eror",
        error.toString(),
        Icons.error_outline,
      );
    } finally {
      await fetchData();
    }
  }

  // fundtion to update the stats as soon as user go to see the statistics
  Future<int> setRoadStats({
    required int journeyID,
    required String filename,
  }) async {
    showProgressInStatsPage.value = true;
    // show progress indicator
    await Future.delayed(const Duration(seconds: 1));
    List<Map<String, dynamic>> query =
        await localDatabase.queryRoadOutputData(journeyID: journeyID);
    for (var journeyData in query) {
      final completStats =
          setRoadStatistics(journeyData: journeyData, filename: filename);
      _mapPageController.roadStats.add(completStats[0]);
      _mapPageController.segStats.add(completStats[1]);
    }
    showProgressInStatsPage.value = false;
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    outputDataFile = outputDataFile.toList().obs; // Convert to mutable list
    slectedFiles = slectedFiles.toSet().obs; // Convert to mutable list

    outputDataFile.clear();
    slectedFiles.clear();
    super.onClose();
  }
}
