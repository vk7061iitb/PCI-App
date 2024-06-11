import 'package:pci_app/Presentation/Themes/sensor_page_color.dart';
import 'package:pci_app/Presentation/Widget/circle_widget.dart';
import 'package:pci_app/Presentation/Widget/custom_appbar.dart';
import '../../Functions/analysis.dart';
import '../../Functions/request_location_permission.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../Objects/data_points.dart';
import '../Widget/response_sheet.dart';
import '../Widget/sensor_readings.dart';
import '../Widget/snackbar.dart';
import '../../Objects/data.dart';
import 'package:gap/gap.dart';
import 'dart:async';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  List<AccData> filteredAccData = [];
  SensorPageColor sensorScreencolor = SensorPageColor();

  @override
  void dispose() async {
    accCallTimer?.cancel();
    locationCallTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    streamSubscriptions.add(
      accelerometerEventStream(
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
      ),
    );
  }

  void updateAcceleration() {
    if (isRecordingData) {
      accCallTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {});
      });
    }
  }

  void updatePosition() {
    locationCallTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      devicePosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: ListView(
          children: [
            const Gap(20),
            Center(
              child: CircleWidget(
                label: showStartButton ? "Start" : "End",
                onPressed: () async {
                  if (showStartButton) {
                    requestLocationPermission();
                    if (devicePosition.latitude == 0) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          customSnackBar(locationErrorMessage),
                        );
                      }
                    } else {
                      isRecordingData = true;
                      showStartButton = false;
                      updateAcceleration();
                      updatePosition();
                      accDataList.clear();
                      gyroDataList.clear();
                      await localDatabase.deleteAlltables();
                      if (kDebugMode) {
                        print('isRecordingData : $isRecordingData');
                      }
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
                    if (kDebugMode) {
                      print('isRecordingData : $isRecordingData');
                    }
                  }
                  if (context.mounted && !isRecordingData) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: false,
                      builder: (BuildContext context) {
                        return ResponseSheet(
                          onPressed: () {},
                          filteredAccData: filteredAccData,
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
            SensorReading(accData: accData, gyroData: gyroData),
          ],
        ),
      ),
    );
  }
}
