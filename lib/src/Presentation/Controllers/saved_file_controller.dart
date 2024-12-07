import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pci_app/src/Presentation/Controllers/unsent_data_controller.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../Objects/data.dart';
import '../../Models/file_info.dart';

class SavedFileController extends GetxController {
  // Variables
  RxList<Map<String, dynamic>> unsentFiles = <Map<String, dynamic>>[].obs;
  Rx<Future<List<File>>> savedFiles = Future.value(<File>[]).obs;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  var isLoading = true.obs;

  final UnsentDataController _unsentDataController =
      Get.put(UnsentDataController());

  // Methods
  Future<void> refreshData() async {
    isLoading.value = true;
    savedFiles.value = loadSavedFiles();

    try {
      unsentFiles.value = await _unsentDataController.getUnsentData();
    } finally {
      isLoading.value = false;
      // Refresh the refresh indicator
      await refreshKey.currentState?.show();
    }
  }

  Future<List<File>> loadSavedFiles() async {
    try {
      Directory? appExternalStorageDir = await getExternalStorageDirectory();
      if (appExternalStorageDir == null) return [];

      Directory accDataDirectory =
          Directory(join(appExternalStorageDir.path, "Acceleration Data"));

      if (await accDataDirectory.exists()) {
        List<FileSystemEntity> files = await accDataDirectory.list().toList();
        return files.whereType<File>().toList();
      } else {
        return [];
      }
    } catch (e) {
      logger.e("Error loading saved files: $e");
      return [];
    }
  }

  Future<void> deleteFile(File file) async {
    try {
      await file.delete();
      refreshData();
    } catch (e) {
      logger.e("Error deleting file: $e");
    }
  }

  Future<void> shareFile(File file) async {
    try {
      XFile xFile = XFile(file.path);
      await Share.shareXFiles([xFile]);
    } catch (e) {
      logger.e("Error sharing file: $e");
    }
  }

  FileInfo getFileInfo(String input) {
    try {
      List<String> parts = input.split('#');
      if (parts.length < 4) throw Exception("Invalid file format");

      String fileName = parts[0];
      String dataType = 'AccData';
      String timeString = parts[2];
      String vehicleType = parts[3].split('.csv').first;

      return FileInfo(
        fileName: fileName,
        dataType: dataType,
        time: timeString,
        vehicleType: vehicleType,
      );
    } catch (e) {
      logger.e("Error parsing file info: $e");
      return FileInfo(
          fileName: 'Unknown',
          dataType: 'Unknown',
          time: 'Unknown',
          vehicleType: 'Unknown');
    }
  }

  @override
  void onInit() {
    refreshData();
    super.onInit();
  }
}
