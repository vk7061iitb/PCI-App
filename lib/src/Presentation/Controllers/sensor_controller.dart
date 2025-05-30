// This file contains the controller for the accelerometer data screen
// It contains the accelerometer data controller class which is used to record the accelerometer data
// and the location data of the user and store it in the database.

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:pciapp/Utils/text_styles.dart';
import 'package:pciapp/src/Presentation/Controllers/location_permission.dart';
import 'package:pciapp/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pciapp/src/service/method_channel_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pciapp/Functions/downsample_data.dart';
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

  RxDouble totalDistanceTravelled = 0.0.obs;
  Rx<Duration> elapsedTime = Duration(seconds: 0).obs;
  Timer? _timer;
  Rx<double> currSpeed = 0.0.obs;

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
  RxString remarks = "-".obs;
  RxInt currRoadIndex = (100).obs;
  RxInt prevRoadIndex = (100).obs;
  final PciMethodsCalls pciMethodsCalls = PciMethodsCalls();

  // pause
  TextEditingController pauseReasonController = TextEditingController();
  String pauseReason = "";
  GlobalKey<FormState> pauseFormKey = GlobalKey<FormState>();
  RxString pauseReasonSelectedOption = "".obs;

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
          // if getting location updates then start updating the total distance
          if (_count > 5 && !showStartButton && currRoadIndex.value >= 0) {
            // the distance shown will only increase if the reading is not paused OR started
            totalDistanceTravelled.value += Geolocator.distanceBetween(
              _devicePosition.value.latitude,
              _devicePosition.value.longitude,
              currentLocation.latitude ?? 0,
              currentLocation.longitude ?? 0,
            );
          }
          _devicePosition.value = Position(
            latitude: currentLocation.latitude!,
            longitude: currentLocation.longitude!,
            altitude: currentLocation.altitude!,
            accuracy: currentLocation.accuracy!,
            timestamp: DateTime.now(),
            altitudeAccuracy: 0,
            heading: currentLocation.heading!,
            headingAccuracy: currentLocation.headingAccuracy!,
            speed: currentLocation.speed!, // m/s
            speedAccuracy: currentLocation.speedAccuracy!,
          );

          // update the speed
          if (_isRecordingData.value) {
            currSpeed.value = currentLocation.speed!;
          }
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
      _roadSelectDialogue();
      return;
    }
    await WakelockPlus.toggle(enable: true);
    pciMethodsCalls.startNotification(); // start the noification
    _isRecordingData.value = true;
    _showStartButton.value = false;
    logger.i('Recording Started');
    _userDataController.getUserData();
    _userID = _userDataController.user['ID'];
    _accStream = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 10),
    ).listen(
      (AccelerometerEvent event) {
        accData.value = event;
        if (_count > 5) {
          _dataPointsList.add(
            // Rounding is done to reduce the size of the data
            AccData(
              xAcc: double.parse(event.x.toStringAsFixed(4)),
              yAcc: double.parse(event.y.toStringAsFixed(4)),
              zAcc: double.parse(event.z.toStringAsFixed(4)),
              latitude: _devicePosition.value.latitude,
              longitude: _devicePosition.value.longitude,
              speed:
                  double.parse(_devicePosition.value.speed.toStringAsFixed(4)),
              roadType: currRoadIndex.value,
              remarks: remarks.value,
              accTime: DateTime.now(),
            ),
          );
        }
      },
    );

    // reset the readings
    downSampledDatapoints.clear();
    dataPointsList.clear();
    _timer?.cancel();
    totalDistanceTravelled.value = 0.0;

    // this timer will be shown on reading page (duration)
    elapsedTime.value = const Duration(seconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
    // increase the time only when there's no pause
      if (currRoadIndex.value >= 0) {
        elapsedTime.value += const Duration(seconds: 1);
      }
    });
  }

  /// This function is called when the end button is pressed
  Future<void> onEndButtonPressed() async {
    logger.i('Recording Stopped');
    _isRecordingData.value = false;
    _showStartButton.value = true;
    pciMethodsCalls.stopNotification();
    _accStream?.cancel();
    _positionStream?.cancel();
    _timer?.cancel();
    elapsedTime.value = const Duration(seconds: 0);
    currSpeed.value = 0;
    totalDistanceTravelled.value = 0;
    accData.value = AccelerometerEvent(0, 0, 0, DateTime.now());
    _showResponseSheet.value = true;
    List<AccData> downSampledDatapoints = downsampleTo50Hz(_dataPointsList);
    for (AccData data in downSampledDatapoints) {
      _downSampledDatapoints.add(data);
    }
    currRoadIndex.value = 100;
    currRoadType.value = "";
    remarks.value = "-";
    await WakelockPlus.toggle(enable: false);
  }
}

void _showDialog(String title, String content) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      titleTextStyle: dialogTitleStyle,
      content: Text(
        content,
      ),
      contentTextStyle: dialogContentStyle,
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('OK', style: dialogButtonStyle,),
        ),
      ],
    ),
  );
}

void _roadSelectDialogue() {
  Get.dialog(AlertDialog(
    title: Text("Road Type not selected", ),
    titleTextStyle: dialogTitleStyle,
    content: RichText(
      text: TextSpan(
        style: dialogContentStyle,
        children: [
          const TextSpan(
            text: 'Please select the ',
          ),
          TextSpan(
            text: 'road type',
            style: dialogContentStyle.copyWith(
              color: activeColor,
            )
          ),
          const TextSpan(
            text: ' (',
          ),
          TextSpan(
            text: 'paved/unpaved/pedestrian',
            style: dialogContentStyle
          ),
          const TextSpan(
            text: ')',
          ),
        ],
      ),
    ),
    contentTextStyle: dialogContentStyle,
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text('OK', style: dialogButtonStyle,),
      ),
    ],
  ));
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

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  final minutes = twoDigits(duration.inMinutes);
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return "$minutes:$seconds";
}

String formatSpeed(double speed) {
  double converFactor = 5 / 18;
  return (speed * converFactor).toStringAsFixed(3);
}
