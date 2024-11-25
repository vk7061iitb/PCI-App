// This file contains the controller for the accelerometer data screen
// It contains the accelerometer data controller class which is used to record the accelerometer data
// and the location data of the user and store it in the database.

import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pci_app/Functions/downsample_data.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../Utils/sensor_page_color.dart';

class AccDataController extends GetxController {
  Rx<AccelerometerEvent> accData = AccelerometerEvent(0, 0, 0, DateTime.now())
      .obs; // used to show the accelerometer data on the screen

  StreamSubscription<AccelerometerEvent>? _accStream;
  final List<AccData> _dataPointsList = [];
  final Rx<Position> _devicePosition = Position(
    latitude: 0.0,
    longitude: 0.0,
    altitude: 10.0,
    accuracy: 0.0,
    timestamp: DateTime.now(),
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0,
    speedAccuracy: 0,
  ).obs;

  final List<AccData> _downSampledDatapoints = [];
  final RxBool _isRecordingData = false.obs;
  StreamSubscription<Position>? _positionStream;
  final Rx<SensorPageColor> _sensorScreencolor = SensorPageColor().obs;
  final RxBool _showResponseSheet = false.obs;
  final RxBool _showStartButton = true.obs;
  final String startMessage = 'Tap "Start" to collect data';
  final String progressMessage = 'Collecting the data...';
  String? _userID;
  int _count = 0;

  @override
  void onInit() {
    // Start the location stream to record the location data points
    loc.Location location = loc.Location();
    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      distanceFilter: 0,
      interval: 1,
    );
    location.onLocationChanged.listen(
      (loc.LocationData currentLocation) {
        _count++;
        _devicePosition.value = Position(
          latitude: currentLocation.latitude!,
          longitude: currentLocation.longitude!,
          altitude: currentLocation.altitude!,
          accuracy: currentLocation.accuracy!,
          timestamp: DateTime.now(),
          altitudeAccuracy: 0,
          heading: currentLocation.heading!,
          headingAccuracy: currentLocation.headingAccuracy!,
          speed: currentLocation.speed!,
          speedAccuracy: currentLocation.speedAccuracy!,
        );
      },
    );
    super.onInit();
  }

  // Getters
  List<AccData> get downSampledDatapoints => _downSampledDatapoints;
  List<AccData> get dataPointsList => _dataPointsList;
  bool get isRecordingData => _isRecordingData.value;
  SensorPageColor get sensorScreencolor => _sensorScreencolor.value;
  bool get showStartButton => _showStartButton.value;
  String? get userID => _userID;
  bool get showResponseSheet => _showResponseSheet.value;
  Position get devicePosition => _devicePosition.value;
  // Setters
  set devicePosition(Position value) => _devicePosition.value = value;
  set downSampledDatapoints(List<AccData> value) =>
      _downSampledDatapoints.addAll(value);

  // This function is called when the start button is pressed
  void onStartButtonPressed() async {
    if (_devicePosition.value.latitude == 0) {
      Get.dialog(
        AlertDialog(
          title: const Text('Cound not get location data'),
          content: const Text(
            'Please hit the start button again and give a try.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _isRecordingData.value = true;
      _showStartButton.value = false;
      downSampledDatapoints.clear();
      dataPointsList.clear();
      logger.i('Recording Started');
      _userID = await localDatabase.queryUserData().then((user) => user.userID);
      _accStream = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 10),
      ).listen(
        (AccelerometerEvent event) {
          accData.value = event;
          if (_count > 5) {
            dataPointsList.add(
              AccData(
                xAcc: event.x,
                yAcc: event.y,
                zAcc: event.z,
                latitude: _devicePosition.value.latitude,
                longitude: _devicePosition.value.longitude,
                speed: _devicePosition.value.speed,
                accTime: DateTime.now(),
              ),
            );
          }
        },
      );
    }
  }

  // This function is called when the end button is pressed
  Future<void> onEndButtonPressed() async {
    logger.i('Recording Stopped');
    _isRecordingData.value = false;
    _showStartButton.value = true;
    _accStream?.cancel();
    _positionStream?.cancel();
    accData.value = AccelerometerEvent(0, 0, 0, DateTime.now());
    _showResponseSheet.value = true;
    _downSampledDatapoints.addAll(downsampleTo50Hz(dataPointsList));
  }
}
