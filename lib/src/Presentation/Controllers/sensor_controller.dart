import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pci_app/Functions/analysis.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../Utils/sensor_page_color.dart';

class AccDataController extends GetxController {
  Rx<AccelerometerEvent> accData = AccelerometerEvent(0, 0, 0)
      .obs; // used to show the accelerometer data on the screen

  StreamSubscription<AccelerometerEvent>? _accStream;
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

  final List<AccData> _filteredAccData = [];
  final RxBool _isRecordingData = false.obs;
  StreamSubscription<Position>? _positionStream;
  final Rx<SensorPageColor> _sensorScreencolor = SensorPageColor().obs;
  final RxBool _showResponseSheet = false.obs;
  final RxBool _showStartButton = true.obs;
  String? _userID;

  // Getters
  List<AccData> get filteredAccData => _filteredAccData;
  bool get isRecordingData => _isRecordingData.value;
  SensorPageColor get sensorScreencolor => _sensorScreencolor.value;
  bool get showStartButton => _showStartButton.value;
  String? get userID => _userID;
  bool get showResponseSheet => _showResponseSheet.value;
  Position get devicePosition => _devicePosition.value;

  // Setters
  set devicePosition(Position value) => _devicePosition.value = value;
  set filteredAccData(List<AccData> value) => _filteredAccData.addAll(value);

  // On Start Button Pressed
  void onStartButtonPressed() async {
    if (_devicePosition.value.latitude == 0) {
      Get.dialog(
        AlertDialog(
          title: const Text('Cound not get location data'),
          content: const Text(
            'Pleaase hit the start button again and give a try.',
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
      filteredAccData.clear();
      accDataList.clear();
      debugPrint('Recording Started');
      _userID = await localDatabase.queryUserData().then((user) => user.userID);
      await localDatabase.deleteAcctables();
      // Start the location stream to record the location data points
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
              latitude: _devicePosition.value.latitude,
              longitude: _devicePosition.value.longitude,
              speed: _devicePosition.value.speed,
              accTime: DateTime.now(),
            ),
          );
          accData.value = event;
        },
      );
    }
  }

  Future<void> onEndButtonPressed() async {
    debugPrint('Recording Stopped');
    _isRecordingData.value = false;
    _showStartButton.value = true;
    _accStream?.cancel();
    _positionStream?.cancel();
    accData.value = AccelerometerEvent(0, 0, 0);
    _showResponseSheet.value = true;
    _filteredAccData.addAll(downsampleTo50Hz(accDataList));
    await localDatabase.insertAccData(downsampleTo50Hz(accDataList));
  }

  @override
  void onInit() {
    loc.Location location = loc.Location();
    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      distanceFilter: 0,
      interval: 1,
    );
    location.enableBackgroundMode(enable: true);
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
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
    });
    debugPrint(
        'Location = ${_devicePosition.value.latitude}, ${_devicePosition.value.longitude}');
    super.onInit();
  }
}
