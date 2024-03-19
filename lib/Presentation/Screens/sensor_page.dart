import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Presentation/Themes/sensor_page_color.dart';
import 'package:pci_app/Presentation/Widget/circle_widget.dart';
import 'package:pci_app/Presentation/Widget/custom_appbar.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../Database/sqlite_db_helper.dart';
import '../../Functions/request_location_permission.dart';
import '../../Objects/data.dart';
import '../../Objects/data_points.dart';
import '../Widget/readings.dart';
import '../Widget/snackbar.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  SensorPageColor sensorScreencolor = SensorPageColor();
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  late SQLDatabaseHelper localDatabase = SQLDatabaseHelper();
  late ScrollController scrollController;
  TextEditingController filenameController = TextEditingController();
  bool showReposeSheet = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: ListView(
          controller: scrollController,
          children: [
            const Gap(20),
            Center(
              child: CircleWidget(
                label: showStartButton ? "Start" : "End",
                onPressed: () async {
                  if (showStartButton) {
                    requestLocationPermission();
                    await localDatabase.deleteAlltables();
                    if (devicePosition.latitude == 0) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(customSnackBar(locationErrorMessage));
                      }
                    } else {
                      scrollToTop();
                      isRecordingData = true;
                      showStartButton = false;
                      updateAcceleration();
                      updatePosition();
                      accDataList.clear();
                      gyroDataList.clear();
                      if (kDebugMode) {
                        print('isRecordingData : $isRecordingData');
                      }
                    }
                  } else {
                    // This operation will be done when end button will be tapped
                    accCallTimer?.cancel();
                    locationCallTimer?.cancel();
                    isRecordingData = false;
                    showReposeSheet = true;
                    showStartButton = true;
                    setState(() {});
                    if (kDebugMode) {
                      print('isRecordingData : $isRecordingData');
                      print(
                          'Acceleration Frequency : ${accDataList.length / (accDataList[accDataList.length - 1].accTime.difference(accDataList[0].accTime).inSeconds)}');
                      print(
                          'Gyroscope Frequency : ${gyroDataList.length / (gyroDataList[gyroDataList.length - 1].gyroTime.difference(gyroDataList[0].gyroTime).inSeconds)}');
                    }
                    Future.delayed(const Duration(seconds: 1), () {
                      scrollToMax();
                    });
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
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ReadingsWidget(
                    iconPath: accelerationImgPath,
                    name: 'Accleration',
                    xValue: !showStartButton ? xAcceleration : 0.0,
                    yValue: !showStartButton ? yAcceleration : 0.0,
                    zValue: !showStartButton ? zAcceleration : 0.0),
                const Gap(15),
                ReadingsWidget(
                    iconPath: gyroscopeImgPath,
                    name: 'Gyroscope',
                    xValue: !showStartButton ? xGyroscope : 0.0,
                    yValue: !showStartButton ? yGyroscope : 0.0,
                    zValue: !showStartButton ? zGyroscope : 0.0),
              ],
            ),
            const Gap(25),
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: PositionReadings(
                    latitude:
                        !showStartButton ? devicePosition.latitude : 0.000,
                    longitude:
                        !showStartButton ? devicePosition.latitude : 0.000,
                    locationAcurrary:
                        !showStartButton ? devicePosition.accuracy : 0.000)),
            const Gap(20),
            showReposeSheet ? responsheeet() : const SizedBox(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    accCallTimer?.cancel();
    locationCallTimer?.cancel();
    scrollController.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    localDatabase.initDB();
    updatePosition();
    scrollController = ScrollController();
    _streamSubscriptions.add(userAccelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 1000))
        .listen(
      (UserAccelerometerEvent event) {
        if (isRecordingData) {
          accDataList.add(
            AccData(
              xAcc: event.x,
              yAcc: event.y,
              zAcc: event.z,
              devicePosition: devicePosition,
              accTime: DateTime.now(),
            ),
          );

          xAcceleration = event.x;
          yAcceleration = event.y;
          zAcceleration = event.z;
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
            });
      },
      cancelOnError: true,
    ));

    _streamSubscriptions.add(gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 1000),
    ).listen(
      (event) {
        if (isRecordingData) {
          gyroDataList.add(
            GyroData(
              xGyro: event.x,
              yGyro: event.y,
              zGyro: event.z,
              gyroTime: DateTime.now(),
            ),
          );

          xGyroscope = event.x;
          yGyroscope = event.y;
          zGyroscope = event.z;
        }
      },
      onError: (e) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text("Gyroscope Sensor Not Found"),
                content: Text(
                    "It seems that your device doesn't support User Gyroscope Sensor"),
              );
            });
      },
      cancelOnError: true,
    ));
  }

  void updateAcceleration() {
    if (isRecordingData) {
      accCallTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
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

  void scrollToMax() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToTop() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> databaseOperation(String fileName) async {
    setState(() {
      selectedIndex = 2;
    });

    await localDatabase.deleteAlltables();
    await localDatabase.insertData(accDataList, gyroDataList);
    message = await localDatabase.exportToCSV(fileName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
    }
    setState(() {
      selectedIndex = 0;
      filenameController.clear();
      showReposeSheet = false;
      scrollToTop();
    });
  }

  Widget responsheeet() {
    return SizedBox(
      width: 0.9 * MediaQuery.of(context).size.width,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            IndexedStack(
              index: selectedIndex,
              children: [
                Center(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Do you want to save the collected readings?',
                          style: GoogleFonts.inter(
                            color: sensorScreencolor.updateMessage,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Gap(15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              selectedIndex = 1;
                              setState(() {});
                              // sendData();
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: sensorScreencolor.yesButton),
                            child: Text(
                              'Yes',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(50),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Are you sure you want to discard the file?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                      'If you discard the file, any recorded data will be lost.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Don't Discard"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Yes, Discard"),
                                        onPressed: () {
                                          showReposeSheet = false;
                                          scrollToTop();

                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: sensorScreencolor.noButton),
                            child: Text(
                              'No',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: filenameController,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                                color: Colors.blue), // Remove the border side
                          ),
                          labelText: 'Enter File Name',
                          hintText: 'Road ID',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                          labelStyle: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20), // Adjust content padding
                        ),
                      ),
                      const Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await databaseOperation(filenameController.text);
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: sensorScreencolor.yesButton),
                            child: Text(
                              'Save',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Gap(50),
                          TextButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Are you sure you want to discard the file?',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                      'If you discard the file, any recorded data will be lost.',
                                      style: TextStyle(color: Colors.blueGrey),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Don't Discard"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Yes, Discard"),
                                        onPressed: () {
                                          filenameController.clear();
                                          showReposeSheet = false;
                                          scrollToTop();
                                          selectedIndex = 0;
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: sensorScreencolor.noButton),
                            child: Text(
                              'Dicard',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Saving your recorded data",
                            style: GoogleFonts.inter(
                              color: sensorScreencolor.updateMessage,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
