import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pci_app/Functions/analysis.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../Objects/data.dart';
import '../../../Utils/sensor_page_color.dart';
import '../../Models/data_points.dart';

class AccDataController extends GetxController {
  final List<AccData> _filteredAccData = [];
  final RxBool _isRecordingData = false.obs;
  final RxBool _showResponseSheet = false.obs;
  final Rx<SensorPageColor> _sensorScreencolor = SensorPageColor().obs;
  final RxBool _showStartButton = true.obs;
  Rx<AccelerometerEvent> accData = AccelerometerEvent(0, 0, 0)
      .obs; // used to show the accelerometer data on the screen
  String? _userID;
  //late Rx<StreamSubscription> _positionStream;
  StreamSubscription<AccelerometerEvent>? _accStream;

  // Getters
  List<AccData> get filteredAccData => _filteredAccData;
  bool get isRecordingData => _isRecordingData.value;
  SensorPageColor get sensorScreencolor => _sensorScreencolor.value;
  bool get showStartButton => _showStartButton.value;
  String? get userID => _userID;
  bool get showResponseSheet => _showResponseSheet.value;

  // Setters
  set filteredAccData(List<AccData> value) => _filteredAccData.addAll(value);

  // On Start Button Pressed
  void onStartButtonPressed() async {
    _isRecordingData.value = true;
    _showStartButton.value = false;
    filteredAccData.clear();
    accDataList.clear();
    debugPrint('Recording Started');
    _userID = await localDatabase.queryUserData().then((user) => user.userID);

    // Start the accelerometer stream to record the data points
    _accStream = accelerometerEventStream(
      samplingPeriod: const Duration(microseconds: 1000),
    ).listen(
      (AccelerometerEvent event) {
        accDataList.add(
          AccData(
            xAcc: event.x,
            yAcc: event.y,
            zAcc: event.z,
            latitude: devicePosition.latitude,
            longitude: devicePosition.longitude,
            speed: devicePosition.speed,
            accTime: DateTime.now(),
          ),
        );
        accData.value = event;
      },
    );
  }

  Future<void> onEndButtonPressed() async {
    _isRecordingData.value = false;
    _showStartButton.value = true;
    debugPrint('Recording Stopped');
    _accStream?.cancel();
    accData.value = AccelerometerEvent(0, 0, 0);
    // Show the response sheet
    _showResponseSheet.value = true;
    filteredAccData.addAll(
      downsampleTo50Hz(accDataList),
    );
  }
}
