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
import 'package:share_plus/share_plus.dart';
import '../../../Functions/vel_to_pci.dart';
import '../../../Objects/data.dart';

class OutputDataController extends GetxController {
  var outputDataFile = <Map<String, dynamic>>[].obs;
  RxSet<int> slectedFiles = <int>{}.obs;
  var isLoading = true.obs;
  final MapPageController _mapPageController = Get.find<MapPageController>();

  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      isLoading.value = true;
      await localDatabase.queryTable('outputData').then((value) {
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

  Future<void> deleteData(int id) async {
    try {
      await localDatabase.deleteOutputData(id);
      await localDatabase.deleteRoadOutputData(id);
      fetchData();
    } catch (e) {
      customGetSnackBar(
          "Databse Error", "Failed to delete data: $e", Icons.error_outline);
      logger.e(e.toString());
    }
  }

  // export data
  Future<void> exportData(String filename, String vehicle, String time,
      List<Map<String, dynamic>> query) async {
    List<List<dynamic>> csvData = [];
    csvData.add([
      'Road Name',
      'Latitude',
      'Longitude',
      'PCI(prediction)',
      'PCI(velocity)',
      'Velocity(km/hr)',
    ]);
    for (var road in query) {
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

  // export multiple roads as zip file
  Future<void> makeZip() async {
    final Archive archive = Archive();
    for (int id in slectedFiles) {
      List<Map<String, dynamic>> roadOutputDataQuery =
          await localDatabase.queryRoadOutputData(id);

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
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
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
        await localDatabase.queryRoadOutputData(id);
    _mapPageController.roadOutputData.add(res);
    _mapPageController.setRoadStatistics(res);
    return res;
  }

  // plot-multiple roads
  Future<void> plotRoads() async {
    _mapPageController.clearData();
    for (int id in slectedFiles) {
      List<Map<String, dynamic>> roadOutputDataQuery =
          await localDatabase.queryRoadOutputData(id);

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
    _mapPageController.plotRoadData();
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
