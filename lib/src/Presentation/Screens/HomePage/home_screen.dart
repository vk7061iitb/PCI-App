import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/location_permission.dart';
import '../SensorPage/sensor_screen.dart';
import '../SavedFile/saved_files_page.dart';
import '../../../../Utils/assets.dart';
import '../../Controllers/bottom_navbar_controller.dart';
import '../OutputData/output_data.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final BottomNavController bottomNavController =
      Get.put(BottomNavController());
  final LocationController locationController = Get.find();

  final List<Widget> _widgetOptions = <Widget>[
    const SensorScreen(),
    const HistoryDataPage(),
    const OutputDataPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final iconWidth = MediaQuery.sizeOf(context).height * 0.03;
    final AssetsPath assetsPath = AssetsPath();
    Color iconActive = Color(0xFF1A73E8);
    Color iconInactive = Color(0xFF757575);

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
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Obx(() {
            return _widgetOptions
                .elementAt(bottomNavController.selectedIndex.value);
          }),
        ),
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
            onTap: (index) {
              bottomNavController.selectedIndex.value = index;
            },
            currentIndex: bottomNavController.selectedIndex.value,
            selectedItemColor: iconActive,
            unselectedItemColor: iconInactive,
            selectedLabelStyle: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              color: inactiveColor,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            type: BottomNavigationBarType.fixed,
            backgroundColor: backgroundColor,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  size: iconWidth,
                  color: iconInactive,
                ),
                activeIcon: Icon(
                  Icons.home,
                  size: iconWidth,
                  color: iconActive,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.file_present_outlined,
                  size: iconWidth,
                  color: iconInactive,
                ),
                activeIcon: Icon(
                  Icons.file_present_rounded,
                  size: iconWidth,
                  color: iconActive,
                ),
                label: "Saved Files",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  assetsPath.journeyHistory,
                  width: iconWidth,
                  height: iconWidth,
                  colorFilter: ColorFilter.mode(
                    inactiveColor,
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  assetsPath.journeyHistorySelected,
                  width: iconWidth,
                  height: iconWidth,
                  colorFilter: ColorFilter.mode(
                    iconActive,
                    BlendMode.srcIn,
                  ),
                ),
                label: "Past Trips",
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
              Get.back(result: false);
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
              Get.back(result: true);
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
