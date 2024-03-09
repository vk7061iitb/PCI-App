import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Functions/get_sensor_data.dart';
import 'package:pci_app/Functions/request_location_permission.dart';
import 'package:pci_app/Functions/request_storage_permission.dart';
import 'package:pci_app/Presentation/Themes/sensor_page_color.dart';
import 'package:pci_app/Presentation/Widget.dart/circle_widget.dart';
import '../../Database/sqlite_db_helper.dart';
import '../../Objects/data.dart';
import '../Widget.dart/custom_appbar.dart';
import '../Widget.dart/readings.dart';
import '../Widget.dart/snackbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SensorPageColor sensorScreencolor = SensorPageColor();
  String startMessage = 'Tap "Start" to collect data';
  String progressMessage = 'Collecting the data...';
  int currentPageIndex = 0; // Track the selected index
  String gyroscopeImgPath = 'lib/Assets/gyroscope.png';
  String accelerationImgPath = 'lib/Assets/speedometer.png';
  bool isButtonTapped = false;
  String textInsideCircle = 'Start';
  Timer? accCallTimer;
  String message = '';
  String requestLocationMessage = '';
  late SQLDatabaseHelper localDatabase = SQLDatabaseHelper();
  late ScrollController scrollController;
  TextEditingController filenameController = TextEditingController();
  bool showReposeSheet = false;
  int selectedIndex = 0;
  String locationErrorMessage =
      "Sorry, we couldn't find your device location. Please press the start button and try again";

  @override
  void dispose() async {
    accCallTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getAccStream();
    getGyroStream();
    getPositionStream();
    requestLocationPermission();
    requestStoragePermission();
    localDatabase.initDB();
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ListView(
        controller: scrollController,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
              child: CircleWidget(
                  label: showStartButton ? "Start" : "End",
                  onPressed: () async {
                    updateAcceleration();
                    isRecordingData = true;
                    if (showStartButton) {
                      await requestLocationPermission();
                      getPositionStream();
                      await localDatabase.deleteAlltables();
                      if (devicePosition.latitude == 0) {
                        if (requestLocationMessage == '') {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(locationErrorMessage));
                          }
                        } else if (requestLocationMessage != '') {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(requestLocationMessage));
                          }
                        }
                      } else {
                        isRecordingData = true;
                        scrollToTop();
                        accDataList.clear();
                        gyroDataList.clear();
                        updateAcceleration();
                        showStartButton = false;
                        if (kDebugMode) {
                          print('isRecordingData : $isRecordingData');
                        }
                      }
                    } else {
                      accCallTimer?.cancel();
                      isRecordingData = false;
                      showReposeSheet = true;
                      updateAcceleration();
                      setState(() {});
                      if (kDebugMode) {
                        print('isRecordingData : $isRecordingData');
                      }
                      Future.delayed(const Duration(milliseconds: 500), () {
                        showStartButton = true;
                        scrollToMax();
                      });
                    }
                    setState(() {});
                  })),
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
            child: Container(
              height: 200,
              width: 350,
              decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
          const Gap(20),
          showReposeSheet ? responsheeet() : const SizedBox(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.green.shade200,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Maps',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  void updateAcceleration() {
    if (isRecordingData) {
      accCallTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
        setState(() {});
      });
    }
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
    await localDatabase.deleteAlltables();
    await localDatabase.insertData(accDataList, gyroDataList);
    if (mounted) Navigator.of(context).pop();
    message = await localDatabase.exportToCSV(fileName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(customSnackBar(message));
    }
    setState(() {});
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
                              showReposeSheet = false;
                              scrollToTop();
                              setState(() {});
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
                          const Gap(50),
                          TextButton(
                            onPressed: () {
                              selectedIndex = 1;
                              setState(() {});
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
                              filenameController.clear();
                              setState(() {
                                showReposeSheet = false;
                                scrollToTop();
                                selectedIndex = 0;
                              });
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
                              filenameController.clear();
                              setState(() {
                                showReposeSheet = false;
                                scrollToTop();
                                selectedIndex = 0;
                              });
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
