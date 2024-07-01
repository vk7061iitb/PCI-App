import 'package:geolocator/geolocator.dart';
import 'package:pci_app/Utils/sensor_page_color.dart';
import 'package:pci_app/src/Screens/SensorPage/widgets/start_end_widget.dart';
import 'package:pci_app/src/Widgets/custom_appbar.dart';
import '../../../Functions/analysis.dart';
import '../../../Functions/request_location_permission.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import '../../Models/data_points.dart';
import 'widgets/response_sheet.dart';
import 'widgets/sensor_readings.dart';
import '../../Widgets/snackbar.dart';
import '../../../Objects/data.dart';
import 'package:gap/gap.dart';
import 'dart:async';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  List<AccData> filteredAccData = [];
  bool isRecordingData = false;
  SensorPageColor sensorScreencolor = SensorPageColor();
  bool showStartButton = true;
  late String? userID;
  late StreamSubscription positionStream;
  late StreamSubscription<AccelerometerEvent> accStream;

  @override
  void initState() {
    super.initState();
    positionStream = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
      forceLocationManager: true,
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      intervalDuration: const Duration(milliseconds: 1000),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'PCI App',
        notificationText: 'Collecting Location Data',
        notificationChannelName: 'PCI App',
        setOngoing: true,
        enableWakeLock: true,
        color: Colors.blueAccent,
      ),
    )).listen(
      (event) {
        devicePosition = event;
      },
    );
    accStream = accelerometerEventStream(
      samplingPeriod: const Duration(microseconds: 100),
    ).listen(
      (AccelerometerEvent event) {
        if (isRecordingData) {
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

          accData[0] = event.x;
          accData[1] = event.y;
          accData[2] = event.z;
        }
      },
      onError: (e) {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Sensor Not Found"),
              content: Text(
                  "It seems that your device doesn't support User Accelerometer Sensor"),
            );
          },
        );
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() async {
    positionStream.cancel();
    accStream.cancel();
    accCallTimer?.cancel();
    locationCallTimer?.cancel();
    super.dispose();
  }

  void updateAcceleration() {
    if (isRecordingData) {
      accCallTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: ListView(
          children: [
            const Gap(20),
            Center(
              child: StartEndButton(
                showStartButton: showStartButton,
                label: showStartButton ? "Start" : "End",
                onPressed: () async {
                  if (showStartButton) {
                    requestLocationPermission();
                    localDatabase.queryUserData().then((value) {
                      userID = value.userID;
                    });
                    if (devicePosition.latitude == 0) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          customSnackBar(locationErrorMessage),
                        );
                      }
                    } else {
                      isRecordingData = true;
                      showStartButton = false;
                      filteredAccData.clear();
                      accDataList.clear();
                      gyroDataList.clear();
                      await localDatabase.deleteAcctables();
                      updateAcceleration();
                      debugPrint('isRecordingData : $isRecordingData');
                    }
                  } else {
                    // This operation will be done when end button will be tapped
                    accData = [0, 0, 0];
                    gyroData = [0, 0, 0];
                    accCallTimer?.cancel();
                    locationCallTimer?.cancel();
                    isRecordingData = false;
                    showStartButton = true;
                    filteredAccData = downsampleTo50Hz(accDataList);
                    accDataList.clear();
                    debugPrint('isRecordingData : $isRecordingData');
                  }
                  if (context.mounted && !isRecordingData) {
                    debugPrint("User ID : $userID");
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: false,
                      builder: (BuildContext context) {
                        return ResponseSheet(
                          onPressed: () {},
                          filteredAccData: filteredAccData,
                          userID: userID!,
                        );
                      },
                    );
                  }
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Center(
                child: Text(
                  showStartButton ? startMessage : progressMessage,
                  style: GoogleFonts.inter(
                    color: sensorScreencolor.updateMessage,
                    fontWeight: FontWeight.w500,
                    fontSize: MediaQuery.textScalerOf(context).scale(18),
                  ),
                ),
              ),
            ),
            SensorReading(
              accData: accData,
              gyroData: gyroData,
              isRecordingData: isRecordingData,
            ),
          ],
        ),
      ),
    );
  }
}
