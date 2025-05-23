import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pciapp/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pciapp/src/Presentation/Controllers/saved_file_controller.dart';
import 'package:pciapp/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';
import 'package:pciapp/src/service/method_channel_helper.dart';
import 'package:pciapp/src/service/send_data_api.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';

class ResponseController extends GetxController {
  SendDataToServer sendDataToServer = SendDataToServer();

  final RxString _dbMessage = ''.obs;
  final RxString _dropdownValue = vehicleType.first.obs;
  final Rx<TextEditingController> _fileNameController =
      TextEditingController().obs;
  final Rx<GlobalKey<FormState>> _formKey = GlobalKey<FormState>().obs;
  final RxBool _savingData = false.obs;
  final RxString _serverMessage = ''.obs;
  final Rx<int> _serverResponseCode = 0.obs;
  final RxBool isPlanned = false.obs;
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
  TextEditingController get fileNameController => _fileNameController.value;

  set dropdownValue(String value) => _dropdownValue.value = value;
  set savingData(bool value) => _savingData.value = value;
  set dbMessage(String value) => _dbMessage.value = value;
  set serverMessage(String value) => _serverMessage.value = value;

  Future<void> saveData({
    required List<AccData> accData,
  }) async {
    // Initially check whether data has lat lon changes or not
    int diffPoints = 0;
    for (int i = 1; i < accData.length; i++) {
      AccData prevPoint = accData[i - 1];
      AccData currentPoint = accData[i];
      bool isSame = (currentPoint.latitude == prevPoint.latitude) ||
          (currentPoint.longitude == prevPoint.longitude);
      if (!isSame) {
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
    PciMethodsCalls pciMethodsCalls = PciMethodsCalls();
    var user = await _userDataController.getUserData();
    // will be inserted in savedData table
    int status = -1;
    DateTime currTime = DateTime.now();
    try {
      // this data will be send to server
      List<Map<String, dynamic>> sensorData =
          accData.map((datapoint) => datapoint.toJson()).toList();
      // send the data to the server
      var userID = _userDataController.user['ID'];
      logger.i('User ID: $userID');
      await pciMethodsCalls.startSending();
      var value = await sendDataToServer.sendData(
        accData: sensorData,
        userID: userID!.toString(),
        filename: _fileNameController.value.text,
        vehicleType: _dropdownValue.value,
        time: DateTime.now(),
        planned: isPlanned.value ? "Planned" : "Unplanned",
      );
      _serverMessage.value = value;
      _serverResponseCode.value = sendDataToServer.statusCode;
      _savingData.value = false;
      Get.back();

      if (_serverResponseCode.value == 200) {
        status = 1; // submitted
        Get.showSnackbar(
          customGetSnackBar(
            "Server Message",
            _serverMessage.value,
            Icons.message_outlined,
          ),
        );
      } else {
        status = 0; // not-submitted
        // Save the data locally
        int id = await localDatabase.insertUnsendDataInfo(
            fileName: _fileNameController.value.text,
            vehicleType: _dropdownValue.value,
            time: currTime,
            planned: isPlanned.value ? "Planned" : "Unplanned");
        if (id != 0) {
          // Insert the data points to unsendData table
          localDatabase.insertToUnsendData(
            accdata: accData,
            id: id,
          );
        }

        Get.showSnackbar(
          customGetSnackBar(
            "Server Message",
            _serverMessage.value,
            Icons.message_outlined,
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
      String path = await _getFilePath(
          _fileNameController.value.text, _dropdownValue.value);
      Map<String, dynamic> data = {
        "filename": _fileNameController.value.text,
        "time": dateTimeParser.formatDateTime(currTime, "dd-MMM-yyyy HH:mm"),
        "vehicleType": _dropdownValue.value,
        "path": path,
        "status": status
      };

      Future.wait([
        localDatabase.insertToSavedData(data),
        saveDataToCSV(
          dataPointsToSave: accData,
          fileName: _fileNameController.value.text,
          vehicleType: _dropdownValue.value,
          planned: isPlanned.value ? "Planned" : "Unplanned",
          userNo: user['phone'],
          time: dateTimeParser.formatDateTime(currTime, "dd-MMM-yyyy HH:mm"),
          submissionStatus: status,
        ),
        _outputDataController.fetchData(),
        _savedFileController.refreshData(),
      ]);

      pciMethodsCalls.stopSending();
      _fileNameController.value.clear();
    }
  }

  Future<int> reSendData({
    required List<Map<String, dynamic>> unsentData,
    required String filename,
    required String vehicleType,
    required DateTime time,
    required String planned,
  }) async {
    int responseCode = 0;

    try {
      // Fetch user data and ensure it's valid
      _userDataController.getUserData();
      var user = _userDataController.user;
      if (user['ID'] == null) {
        throw Exception("User ID is missing or invalid.");
      }
      var userID = user['ID'];

      // Send data to the server
      final value = await sendDataToServer.sendData(
        accData: unsentData,
        userID: userID,
        filename: filename,
        vehicleType: vehicleType,
        time: time,
        planned: planned,
      );

      // Handle server response
      _serverMessage.value = value;
      _serverResponseCode.value = sendDataToServer.statusCode;
      responseCode = sendDataToServer.statusCode;

      if (responseCode == 200) {
        // Refresh data only if the submission is successful
        await _outputDataController.fetchData();
      } else {
        _serverMessage.value =
            "Failed to send data. Server responded with code $responseCode.";
      }
    } catch (e) {
      // Log the error and set response code
      _serverMessage.value = "An error occurred: $e";
      _serverResponseCode.value = 500;
      responseCode = 500;
    } finally {
      _savingData.value = false; // Ensure savingData is reset
    }
    return responseCode;
  }

  Future<void> saveDataToCSV({
    required List<AccData> dataPointsToSave,
    required String fileName,
    required String vehicleType,
    required String userNo,
    required String planned,
    required String time,
    required int submissionStatus,
  }) async {
    List<List<dynamic>> csvData = _prepareCsvData(
      dataPointsToSave,
      fileName,
      vehicleType,
      planned,
      time,
      submissionStatus,
    );
    String savedCSVdata = _convertToCsv(csvData);
    String filePath = await _getFilePath(fileName, vehicleType);
    await _saveFile(savedCSVdata, filePath);
  }

  List<List<dynamic>> _prepareCsvData(
    List<AccData> dataPointsToSave,
    String fileName,
    String vehicleType,
    String planned,
    String time,
    int submissionStatus,
  ) {
    List<List<dynamic>> csvData = [];

    // Add metadata before CSV data
    Map<String, dynamic> metaData = {
      "file": fileName,
      "vehicleType": vehicleType,
      "userNo.": _userDataController.user['phone'],
      "planned/unplanned": planned,
      "time": time,
      "submissionStatus": submissionStatus,
    };
    String metaDataString = jsonEncode(metaData);
    csvData.add([metaDataString]);
    // Add column headers
    csvData.add([
      'x_acc',
      'y_acc',
      'z_acc',
      'Latitude',
      'Longitude',
      'Speed',
      'roadType',
      'remarks',
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
        element.roadType,
        element.remarks,
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
        '$fileName${dateTimeParser.formatDateTime(DateTime.now(), "dd-MMM-yyyy_HH:mm")}.csv';
    return '$accDataDirectoryPath/$savedFileName';
  }

  Future<void> _saveFile(String savedCSVdata, String filePath) async {
    File savedFile = File(filePath);
    await savedFile.writeAsString(savedCSVdata);
  }

  Future<void> shareFile(String filePath) async {
    XFile fileToShare = XFile(filePath);
    await Share.shareXFiles(
      [fileToShare],
    );
  }

  // Compresses a JSON Map<String, dynamic> to GZIP binary format.
  List<int> compressJson(Map<String, dynamic> jsonData) {
    String jsonString = jsonEncode(jsonData);
    List<int> jsonBytes = utf8.encode(jsonString);
    return gzip.encode(jsonBytes);
  }

  // Decompresses GZIP binary back to JSON Map<String, dynamic>.
  Map<String, dynamic> decompressJson(List<int> compressedData) {
    List<int> decompressedBytes = gzip.decode(compressedData);
    String jsonString = utf8.decode(decompressedBytes);
    return jsonDecode(jsonString);
  }
}
