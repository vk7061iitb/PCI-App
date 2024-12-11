// This file contains the controller for the accelerometer data screen
// It contains the accelerometer data controller class which is used to record the accelerometer data
// and the location data of the user and store it in the database.

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart' as loc;
import 'package:pci_app/src/Presentation/Controllers/location_permission.dart';
import 'package:pci_app/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pci_app/src/service/method_channel_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  StreamSubscription<List<ConnectivityResult>>? networkStream;
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
  final RxBool _internetConnection = false.obs;
  final String startMessage = 'Tap "Start" to collect data';
  final String progressMessage = 'Collecting the data...';
  String? _userID;
  int _count = 0;
  final UserDataController _userDataController = UserDataController();
  final LocationController locationController = Get.find<LocationController>();
  List<String> roads = ["Paved", "Unpaved", "Pedestrian"];
  RxString currRoadType = "".obs;
  final PciMethodsCalls pciMethodsCalls = PciMethodsCalls();

  // Getters
  List<AccData> get downSampledDatapoints => _downSampledDatapoints;
  List<AccData> get dataPointsList => _dataPointsList;
  bool get isRecordingData => _isRecordingData.value;
  SensorPageColor get sensorScreencolor => _sensorScreencolor.value;
  bool get showStartButton => _showStartButton.value;
  String? get userID => _userID;
  bool get showResponseSheet => _showResponseSheet.value;
  Position get devicePosition => _devicePosition.value;
  bool get internetConnection => _internetConnection.value;
  // Setters
  set devicePosition(Position value) => _devicePosition.value = value;
  set downSampledDatapoints(List<AccData> value) =>
      _downSampledDatapoints.addAll(value);

  @override
  void onInit() async {
    await locationController.locationPermission().then((val) async {
      if (!val) {
        _showPermissionDialog();
        return;
      }

      /// Start the location stream to record the location data points
      loc.Location location = loc.Location();
      await location.changeSettings(
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
      ).onError((error, stackTrace) {
        logger.e('Error in location stream: $error');
      });
    });

    /// Check the network status
    networkStream = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        result.contains(ConnectivityResult.none)
            ? _internetConnection.value = false
            : _internetConnection.value = true;
      },
    );
    super.onInit();
  }

  @override
  void onClose() {
    _accStream?.cancel();
    _positionStream?.cancel();
    networkStream?.cancel();
    pciMethodsCalls.stopNotification();
    super.onClose();
  }

  /// This function is called when the start button is pressed
  void onStartButtonPressed() async {
    if (_devicePosition.value.latitude == 0) {
      _showDialog('Cound not get location data',
          'Please hit the start button again and give a try.');
      return;
    }
    if (currRoadType.value.isEmpty) {
      _showDialog('Road Type not selected',
          'Please select the road type and try again.');
      return;
    }

    await WakelockPlus.toggle(enable: true);
    pciMethodsCalls.startNotification();
    _isRecordingData.value = true;
    _showStartButton.value = false;
    downSampledDatapoints.clear();
    dataPointsList.clear();
    logger.i('Recording Started');
    _userDataController.getUserData();
    _userID = _userDataController.user['ID'];
    _accStream = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 10),
    ).listen(
      (AccelerometerEvent event) {
        accData.value = event;
        if (_count > 5) {
          dataPointsList.add(
            // Rounding is done to reduce the size of the data
            AccData(
              xAcc: double.parse(event.x.toStringAsFixed(4)),
              yAcc: double.parse(event.y.toStringAsFixed(4)),
              zAcc: double.parse(event.z.toStringAsFixed(4)),
              latitude: _devicePosition.value.latitude,
              longitude: _devicePosition.value.longitude,
              speed:
                  double.parse(_devicePosition.value.speed.toStringAsFixed(3)),
              accTime: DateTime.now(),
            ),
          );
        }
      },
    );
  }

  /// This function is called when the end button is pressed
  Future<void> onEndButtonPressed() async {
    logger.i('Recording Stopped');
    _isRecordingData.value = false;
    _showStartButton.value = true;
    pciMethodsCalls.stopNotification();
    _accStream?.cancel();
    _positionStream?.cancel();
    accData.value = AccelerometerEvent(0, 0, 0, DateTime.now());
    _showResponseSheet.value = true;
    _downSampledDatapoints.addAll(downsampleTo50Hz(dataPointsList));
    await WakelockPlus.toggle(enable: false);
  }
}

void _showDialog(String title, String content) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      titleTextStyle: GoogleFonts.inter(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 24,
      ),
      content: Text(
        content,
      ),
      contentTextStyle: GoogleFonts.inter(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 16,
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
}

void _showPermissionDialog() {
  Get.dialog(
    AlertDialog(
      title: const Text('Permission Required'),
      content: const Text(
        'Location permission is required to get the current location',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Geolocator.openAppSettings().then((_) {
              Get.back();
            });
          },
          child: const Text('Grant Permission'),
        ),
      ],
    ),
  );
}
