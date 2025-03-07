import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pciapp/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';
import 'package:pciapp/src/service/method_channel_helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../Objects/data.dart';
import '../../service/send_data_api.dart';

class SavedFileController extends GetxController {
  // Variables
  RxList<Map<String, dynamic>> unsentFiles = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> submittedFiles = [];
  List<Map<String, dynamic>> notSubmittedFiles = [];
  RxBool showSubmitted = false.obs;
  RxBool showNotSubmitted = false.obs;
  RxBool showAll = true.obs;
  RxInt selectedFilter = 2.obs;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  SendDataToServer sendDataToServer = SendDataToServer();
  var isLoading = true.obs;

  // Methods
  Future<void> refreshData() async {
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    isLoading.value = true;
    try {
      await outputDataController.fetchData();
      unsentFiles.value = await localDatabase.queryTable('unsendDataInfo');
    } finally {
      isLoading.value = false;
      // Refresh the refresh indicator
      await refreshKey.currentState?.show();
    }
  }

  Future<void> searchUnsentData(Map<String, dynamic> data) async {
    unsentFiles.value = await localDatabase.queryTable('unsendDataInfo');
    for (var file in unsentFiles) {
      if (file['Time'] == data['time']) {
        int id = file['id'];
        String planned = file['planned'];
        var accData = await localDatabase.queryUnsentData(id);
        final user = userDataController.storage.read('user');
        PciMethodsCalls pciMethodsCalls = PciMethodsCalls();
        try {
          await pciMethodsCalls.startSending();
          var value = await sendDataToServer.sendData(
            accData: accData,
            userID: user['ID'],
            filename: data['filename'],
            vehicleType: data['vehicleType'],
            time: dateTimeParser.parseDateTime(
                data['time'], "dd-MMM-yyyy HH:mm")!,
            planned: planned,
          );
          var m = "Data Submitted Successfully";
          if (value == m) {
            Get.showSnackbar(
              customGetSnackBar(
                "Server Message",
                value,
                Icons.message_outlined,
              ),
            );
            Map<String, dynamic> newData = Map.from(data);
            newData['status'] = 1;
            logger.i("Updated saved data: $newData");
            await Future.wait([
              localDatabase.updateSavedStatus(newData),
              localDatabase.deleteUnsentData(id),
              localDatabase.deleteUnsentDataInfo(id),
            ]);
          } else {
            Get.showSnackbar(
              customGetSnackBar(
                "Submission Failed",
                value,
                Icons.error_outline,
              ),
            );
          }
        } catch (e) {
          logger.e(e.toString());
          Get.showSnackbar(
            customGetSnackBar(
              "Error",
              e.toString(),
              Icons.error_outline,
            ),
          );
        } finally {
          await pciMethodsCalls.stopSending();
          await refreshData();
        }
        return;
      }
    }
  }

  Future<List<Map<String, dynamic>>> loadSavedFiles() async {
    try {
      submittedFiles.clear();
      notSubmittedFiles.clear();
      List<Map<String, dynamic>> files = await localDatabase.querySavedFiles();
      for (var file in files) {
        if (file['status'] == 1) {
          submittedFiles.add(file);
        } else {
          notSubmittedFiles.add(file);
        }
      }
      if (showSubmitted.value) return submittedFiles;
      if (showNotSubmitted.value) return notSubmittedFiles;
      return files.reversed.toList();
    } catch (e) {
      logger.e("Error loading saved files: $e");
      return [];
    }
  }

  Future<void> deleteFile(Map<String, dynamic> data) async {
    try {
      await localDatabase.deleteSavedFile(data);
      refreshData();
    } catch (e) {
      logger.e("Error deleting file: $e");
    }
  }

  Future<void> shareFile(Map<String, dynamic> data) async {
    try {
      if (data['path'] != null) {
        XFile xFile = XFile(data['path']);
        await Share.shareXFiles([xFile]);
      }
    } catch (e) {
      logger.e("Error sharing file: $e");
    }
  }

  @override
  void onInit() {
    refreshData();
    super.onInit();
  }
}
