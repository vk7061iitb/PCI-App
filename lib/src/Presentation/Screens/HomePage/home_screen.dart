import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Controllers/location_permission.dart';
import '../../Controllers/sensor_controller.dart';
import '../../Controllers/user_data_controller.dart';
import '../SensorPage/sensor_screen.dart';
import '../SavedFile/saved_files_page.dart';
import '../../../../Utils/assets.dart';
import '../../Controllers/bottom_navbar_controller.dart';
import '../OutputData/output_data.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final BottomNavController bottomNavController =
      Get.put(BottomNavController());
  final AccDataController accDataController = Get.find<AccDataController>();
  final LocationController locationController = Get.find<LocationController>();
  final UserDataController userDataController = Get.find<UserDataController>();

  final List<Widget> _widgetOptions = <Widget>[
    const SensorScreen(),
    // const MapPage(),
    const HistoryDataPage(),
    const OutputDataPage(),
  ];

  @override
  Widget build(BuildContext context) {
    const iconWidth = 25.0;
    final AssetsPath assetsPath = AssetsPath();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, FormData? result) async {
        if (didPop) {
          return;
        }
        if (bottomNavController.selectedIndex.value != 0) {
          bottomNavController.onTapped(0);
          return;
        }
        final bool shouldPop = await _showAlert(context) ?? false;
        if (shouldPop && context.mounted) {
          exit(0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3EDF5),
        body: SafeArea(
          child: Obx(() {
            return _widgetOptions
                .elementAt(bottomNavController.selectedIndex.value);
          }),
        ),
        bottomNavigationBar: Obx(() {
          return NavigationBar(
            animationDuration: const Duration(milliseconds: 500),
            height: 0.18 * MediaQuery.of(context).size.width,
            onDestinationSelected: bottomNavController.onTapped,
            indicatorColor: Colors.blue.shade100,
            selectedIndex: bottomNavController.selectedIndex.value,
            destinations: <Widget>[
              const NavigationDestination(
                selectedIcon: Icon(
                  Icons.home,
                  color: Colors.black,
                  size: iconWidth,
                ),
                icon: Icon(
                  Icons.home_outlined,
                  size: iconWidth,
                  color: Colors.black,
                ),
                label: 'Home',
              ),
              const NavigationDestination(
                selectedIcon: Icon(Icons.file_present_rounded,
                    color: Colors.black, size: iconWidth),
                icon: Icon(
                  Icons.file_present_outlined,
                  size: iconWidth,
                  color: Colors.black,
                ),
                label: 'Saved Files',
              ),
              NavigationDestination(
                selectedIcon: SvgPicture.asset(
                  assetsPath.journeyHistorySelected,
                  width: 25,
                  height: 25,
                ),
                icon: SvgPicture.asset(
                  assetsPath.journeyHistory,
                  width: 25,
                  height: 25,
                ),
                label: 'Past Trips',
              ),
            ],
          );
        }),
      ),
    );
  }
}

Future<bool?> _showAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Exit Application?'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content: const Text('Are you sure you want to close the application?'),
        contentTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              'Yes',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    },
  );
}
