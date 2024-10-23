import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pci_app/src/Presentation/Controllers/location_permission.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/sensor_screen.dart';
import '../../../../Utils/assets.dart';
import '../../Controllers/bottom_navbar_controller.dart';
import '../OutputData/output_data.dart';
import '../SavedFile/saved_files_page.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final BottomNavController bottomNavController =
      Get.put(BottomNavController());
  final AccDataController accDataController = Get.find();
  final LocationController locationController = Get.find<LocationController>();

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
    return Scaffold(
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
    );
  }
}
