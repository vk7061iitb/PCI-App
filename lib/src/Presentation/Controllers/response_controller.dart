import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/saved_file_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import 'package:pci_app/src/service/send_data_api.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';

class ResponseController extends GetxController {
  SendDataToServer sendDataToServer = SendDataToServer();

  final RxString _dbMessage = ''.obs;
  final RxString _dropdownValue = vehicleType.first.obs;
  final Rx<TextEditingController> _fileNameController =
      TextEditingController().obs;
  final Rx<TextEditingController> _pedestianController =
      TextEditingController().obs;

  final Rx<GlobalKey<FormState>> _formKey = GlobalKey<FormState>().obs;
  final Rx<GlobalKey<FormState>> _pedestrianFormKey =
      GlobalKey<FormState>().obs;
  final RxBool _savingData = false.obs;
  final RxString _serverMessage = ''.obs;
  final Rx<int> _serverResponseCode = 0.obs;
  final UserDataController _userDataController = UserDataController();
  final OutputDataController _outputDataController =
      Get.find<OutputDataController>();
  final SavedFileController _savedFileController =
      Get.put(SavedFileController());

  String get dropdownValue => _dropdownValue.value;
  String get dbMessage => _dbMessage.value;
  String get serverMessage => _serverMessage.value;
  bool get savingData => _savingData.value;
  GlobalKey<FormState> get formKey => _formKey.value;
  GlobalKey<FormState> get pedestrianFormKey => _pedestrianFormKey.value;
  TextEditingController get fileNameController => _fileNameController.value;
  TextEditingController get pedestianController => _pedestianController.value;

  set dropdownValue(String value) => _dropdownValue.value = value;
  set savingData(bool value) => _savingData.value = value;
  set dbMessage(String value) => _dbMessage.value = value;
  set serverMessage(String value) => _serverMessage.value = value;

  Future<void> saveData({
    required List<AccData> accData,
    required roadType,
  }) async {
    // Initially check whether data has lat lon changes or not
    int diffPoints = 0;
    for (int i = 1; i < accData.length; i++) {
      if (accData[i].latitude != accData[i - 1].latitude ||
          accData[i].longitude != accData[i - 1].longitude) {
        diffPoints++;
        if (diffPoints > 1) {
          break;
        }
      }
    }

    if (diffPoints < 1) {
      // show snackbar
      String message = 'Not enough data to send';

      Get.back();
      Get.showSnackbar(
        customGetSnackBar("Insufficient Data", message, Icons.error_outline),
      );
      return;
    }

    // send the data to the server
    var user = await _userDataController.getUserData();
    var userID = _userDataController.user['ID'];
    logger.i('User ID: $userID');
    await sendDataToServer
        .sendData(
      accData: accData,
      userID: userID!.toString(),
      filename: _fileNameController.value.text,
      vehicleType: _dropdownValue.value,
      roadType: roadType,
      time: DateTime.now(),
    )
        .then((value) async {
      _serverMessage.value = value;
      _serverResponseCode.value = sendDataToServer.statusCode;
      _savingData.value = false;
      // If the data is not sent successfully, save the data locally
      if (_serverResponseCode.value / 100 != 2) {
        // Save the data locally
        int id = await localDatabase.insertUnsendDataInfo(
          fileName: _fileNameController.value.text,
          vehicleType: _dropdownValue.value,
          roadType: roadType,
        );
        if (id != 0) {
          // Insert the data points to unsendData table
          localDatabase.insertToUnsendData(
            accdata: accData,
            id: id,
          );
        }
      }
      Get.back();
      Get.showSnackbar(
        customGetSnackBar(
          "Server Message",
          _serverMessage.value,
          Icons.message_outlined,
        ),
      );
    });
    // Save the data locally
    await saveDataToCSV(
      dataPointsToSave: accData,
      fileName: _fileNameController.value.text,
      vehicleType: _dropdownValue.value,
      roadType: roadType,
      userNo: user['phone'],
    );
    await _outputDataController.fetchData();
    await _savedFileController.refreshData();
    _fileNameController.value.clear();
  }

  Future<int> reSendData({
    required List<Map<String, dynamic>> unsentData,
    required String filename,
    required String roadType,
    required String vehicleType,
    required DateTime time,
  }) async {
    int responseCode = 0;
    List<AccData> accData = [];
    for (var data in unsentData) {
      accData.add(
        AccData(
          xAcc: data['x_acc'],
          yAcc: data['y_acc'],
          zAcc: data['z_acc'],
          latitude: data['Latitude'],
          longitude: data['Longitude'],
          speed: data['Speed'],
          accTime: dateTimeParser.parseDateTime(
              data['Time'], 'yyyy-MM-dd HH:mm:ss:S')!,
        ),
      );
    }
    // send the data to the server
    _userDataController.getUserData();
    var userID = _userDataController.user['ID'];
    await sendDataToServer
        .sendData(
      accData: accData,
      userID: userID!,
      filename: filename,
      vehicleType: vehicleType,
      roadType: roadType,
      time: time,
    )
        .then((value) {
      _serverMessage.value = value;
      _serverResponseCode.value = sendDataToServer.statusCode;
      responseCode = sendDataToServer.statusCode;
      _savingData.value = false;
      return responseCode;
    });
    await _outputDataController.fetchData();
    await _savedFileController.refreshData();
    return responseCode;
  }

  Future<void> saveDataToCSV({
    required List<AccData> dataPointsToSave,
    required String fileName,
    required String vehicleType,
    required String roadType,
    required String userNo,
  }) async {
    List<List<dynamic>> csvData = _prepareCsvData(
      dataPointsToSave,
      fileName,
      vehicleType,
      roadType,
    );
    String savedCSVdata = _convertToCsv(csvData);
    String filePath = await _getFilePath(fileName, vehicleType);
    await _saveFile(savedCSVdata, filePath);
    await _shareFile(filePath);
  }

  List<List<dynamic>> _prepareCsvData(
    List<AccData> dataPointsToSave,
    String fileName,
    String vehicleType,
    String roadType,
  ) {
    List<List<dynamic>> csvData = [];

    // Add metadata before CSV data
    csvData.add([
      'FileName',
      'VehicleType',
      'RoadType',
      'UserNo',
      'Date',
      'Time',
    ]);
    csvData.add([
      fileName,
      vehicleType,
      roadType,
      _userDataController.user['phone'],
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      DateFormat('HH:mm:ss').format(DateTime.now()),
    ]);
    // Add column headers
    csvData.add([
      'x_acc',
      'y_acc',
      'z_acc',
      'Latitude',
      'Longitude',
      'Speed',
      'accTime'
    ]);
    // Add data points
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
    return csvData;
  }

  String _convertToCsv(List<List<dynamic>> csvData) {
    return const ListToCsvConverter().convert(csvData);
  }

  Future<String> _getFilePath(String fileName, String vehicleType) async {
    String accDataDirectoryPath = await localDatabase.initializeDirectory();
    String savedFileName =
        '$fileName#AccelerationData#${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())}#$vehicleType.csv';
    return '$accDataDirectoryPath/$savedFileName';
  }

  Future<void> _saveFile(String savedCSVdata, String filePath) async {
    File savedFile = File(filePath);
    await savedFile.writeAsString(savedCSVdata);
  }

  Future<void> _shareFile(String filePath) async {
    XFile fileToShare = XFile(filePath);
    await Share.shareXFiles([fileToShare]);
  }
}
