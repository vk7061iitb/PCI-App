import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import 'package:pci_app/src/service/send_data_api.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Functions/init_download_folder.dart';
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';

class ResponseController extends GetxController {
  final RxString _dbMessage = ''.obs;
  final RxString _dropdownValue = vehicleType.first.obs;
  final Rx<TextEditingController> _fileNameController =
      TextEditingController().obs;
  final Rx<GlobalKey<FormState>> _formKey = GlobalKey<FormState>().obs;
  final RxBool _isSaveLocally = true.obs;
  final RxBool _savingData = false.obs;
  final RxString _serverMessage = ''.obs;
  final Rx<int> _serverResponseCode = 0.obs;
  SendDataToServer sendDataToServer = SendDataToServer();

  String get dropdownValue => _dropdownValue.value;
  String get dbMessage => _dbMessage.value;
  String get serverMessage => _serverMessage.value;
  bool get isSaveLocally => _isSaveLocally.value;
  bool get savingData => _savingData.value;
  GlobalKey<FormState> get formKey => _formKey.value;
  TextEditingController get fileNameController => _fileNameController.value;

  set dropdownValue(String value) => _dropdownValue.value = value;
  set isSaveLocally(bool value) => _isSaveLocally.value = value;
  set savingData(bool value) => _savingData.value = value;
  set dbMessage(String value) => _dbMessage.value = value;
  set serverMessage(String value) => _serverMessage.value = value;

  Future<void> saveData(List<AccData> accData) async {
    // Initially check whether data has lat lon changes or not
    int diffPoints = 0;
    for (int i = 1; i < accData.length; i++) {
      if (accData[i].latitude != accData[i - 1].latitude ||
          accData[i].longitude != accData[i - 1].longitude) {
        diffPoints++;
      }
    }
    debugPrint('Diff Points: $diffPoints');
    if (diffPoints < 1) {
      // show snackbar
      String message = 'Not enough data to send';

      Get.back();
      Get.showSnackbar(
        customGetSnackBar(message, Icons.error_outline),
      );
      return;
    }

    // send the data to the server
    String? userID =
        await localDatabase.queryUserData().then((user) => user.userID);
    debugPrint('User ID: $userID');
    await sendDataToServer
        .sendData(accData: accData, userID: userID!)
        .then((value) async {
      _serverMessage.value = value;
      _serverResponseCode.value = sendDataToServer.statusCode;
      _savingData.value = false;

      // If the data is not sent successfully, save the data locally
      if (_serverResponseCode.value / 100 != 2) {
        // Save the data locally
        int id = await localDatabase.insertUnsendDataInfo(
          fileName: "Unsent Data",
          vehicleType: _dropdownValue.value,
        );
        if (id != 0) {
          // Insert the data points to unsendData table
          localDatabase.insertToUnsendData(accdata: accData, id: id);
        }
      }
      Get.back();
      Get.showSnackbar(
        customGetSnackBar(
          _serverMessage.value,
          Icons.check_circle_outline,
        ),
      );
    });
    // Save the data locally
    if (_isSaveLocally.isTrue) {
      await saveDataToCSV(
        dataPointsToSave: accData,
        fileName: _fileNameController.value.text,
        vehicleType: _dropdownValue.value,
      );
    }
  }

  Future<void> saveDataToCSV({
    required List<AccData> dataPointsToSave,
    required String fileName,
    required String vehicleType,
  }) async {
    List<List<dynamic>> csvData = [];
    // Add the headers
    csvData.add([
      'x_acc',
      'y_acc',
      'z_acc',
      'Latitude',
      'Longitude',
      'Speed',
      'accTime'
    ]);

    // add the datapoints
    for (var element in dataPointsToSave) {
      csvData.add([
        element.xAcc,
        element.yAcc,
        element.zAcc,
        element.latitude,
        element.longitude,
        element.speed,
        DateFormat('yyyy-MM-dd HH:mm:ss:S').format(element.accTime)
      ]);
    }

    // convert to csv
    String savedCSVdata = const ListToCsvConverter().convert(csvData);

    // get the download folder and file path
    String accDataDirectoryPath = await initializeDirectory();
    String savedFileName =
        '$fileName#AccelerationData#${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())}#$vehicleType.csv';
    String filePath = '$accDataDirectoryPath/$savedFileName';

    // Save the file
    File savedFile = File(filePath);
    savedFile.writeAsString(
      savedCSVdata,
    );

    // Share the file
    XFile fileToShare = XFile(filePath);
    await Share.shareXFiles([fileToShare]);
  }
}
