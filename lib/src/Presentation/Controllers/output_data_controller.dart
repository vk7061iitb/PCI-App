import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import 'package:pci_app/src/service/report_pdf_api.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Utils/set_road_stats.dart';
import '../../../Functions/vel_to_pci.dart';
import '../../../Objects/data.dart';

/// Controller for managing output data(Jorney Data) in the PCI App.
///
/// This controller extends `GetxController` from the GetX package,
/// providing reactive state management for the output data.
///
/// Example usage:
/// ```dart
/// final outputDataController = Get.put(OutputDataController());
/// ```
///
/// See also:
/// - [GetxController](https://pub.dev/documentation/get/latest/get/GetxController-class.html)
/// - [GetX package](https://pub.dev/packages/get)
///
class OutputDataController extends GetxController {
  var outputDataFile = <Map<String, dynamic>>[].obs;
  RxSet<int> slectedFiles = <int>{}.obs;
  var isLoading = true.obs;
  final MapPageController _mapPageController = Get.find<MapPageController>();

  /// This method retrieves the data related to the user's journey
  /// from the local storage. It ensures that the data is up-to-date
  /// and available for further processing or display within the app.
  ///
  /// Returns a Future that completes with the user's journey data.
  /// Fetches the user's jouney data from the local database
  Future<List<Map<String, dynamic>>> fetchData() async {
    String tableToFetch = 'outputData';
    try {
      isLoading.value = true;
      await localDatabase.queryTable(tableToFetch).then((value) {
        outputDataFile.value = value;
        isLoading.value = false;
      });
    } catch (e) {
      customGetSnackBar(
          "Database Error", "Failed to fetch data: $e", Icons.error_outline);
      logger.e(e.toString());
    }
    return outputDataFile;
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
      await localDatabase.deleteRoadOutputData(id);
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
    required String time,
    required List<Map<String, dynamic>> jouneyData,
  }) async {
    List<List<dynamic>> csvData = [];
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
        labels[i]['vel_prediction'] =
            velocityToPCI(labels[i]['velocity'] * 3.6); // convert to km/hr
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
          await localDatabase.queryRoadOutputData(jouneyID: id);

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
          labels[i]['vel_prediction'] =
              velocityToPCI(labels[i]['velocity'] * 3.6); // convert to km/hr
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

  // get road stats
  Future<List<Map<String, dynamic>>> getRoadStats(int id) async {
    _mapPageController.roadOutputData = [];
    List<Map<String, dynamic>> res =
        await localDatabase.queryRoadOutputData(jouneyID: id);
    _mapPageController.roadOutputData.add(res);
    if (_mapPageController.roadStats.isNotEmpty) {
      _mapPageController.roadStats.clear();
    }
    _mapPageController.roadStats.add(setRoadStatistics(journeyData: res));
    return res;
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
    for (int id in slectedFiles) {
      List<Map<String, dynamic>> roadOutputDataQuery =
          await localDatabase.queryRoadOutputData(jouneyID: id);

      Map<String, dynamic> currRoadData = {};
      for (var road in outputDataFile) {
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
