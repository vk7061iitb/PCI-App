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
          return NavigationBar(
            backgroundColor: backgroundColor,
            animationDuration: const Duration(milliseconds: 500),
            height: 0.18 * MediaQuery.of(context).size.width,
            onDestinationSelected: bottomNavController.onTapped,
            indicatorColor: Colors.blue.shade100,
            selectedIndex: bottomNavController.selectedIndex.value,
            destinations: <Widget>[
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.home,
                  color: iconActive,
                  size: iconWidth,
                ),
                icon: Icon(
                  Icons.home_outlined,
                  size: iconWidth,
                  color: iconInactive,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.file_present_rounded,
                  color: iconActive,
                  size: iconWidth,
                ),
                icon: Icon(
                  Icons.file_present_outlined,
                  size: iconWidth,
                  color: iconInactive,
                ),
                label: 'Saved Files',
              ),
              NavigationDestination(
                selectedIcon: SvgPicture.asset(
                  assetsPath.journeyHistorySelected,
                  width: 25,
                  height: 25,
                  colorFilter: ColorFilter.mode(
                    iconActive,
                    BlendMode.srcIn,
                  ),
                ),
                icon: SvgPicture.asset(
                  assetsPath.journeyHistory,
                  width: 25,
                  height: 25,
                  colorFilter: ColorFilter.mode(
                    iconInactive,
                    BlendMode.srcIn,
                  ),
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
