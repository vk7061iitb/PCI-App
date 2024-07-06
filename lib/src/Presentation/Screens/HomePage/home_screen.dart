import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pci_app/src/Presentation/Controllers/location_permission.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/MapsPage/maps_page.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/sensor_screen.dart';
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
    const MapPage(),
    const HistoryDataPage(),
    const OutputDataPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.home,
                color: Colors.blueAccent,
              ),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.map, color: Colors.blueAccent),
              icon: Icon(Icons.map_outlined),
              label: 'Maps',
            ),
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.file_present_rounded, color: Colors.blueAccent),
              icon: Icon(Icons.file_present_outlined),
              label: 'Saved Files',
            ),
            NavigationDestination(
              selectedIcon:
                  Icon(Icons.data_array_rounded, color: Colors.blueAccent),
              icon: Icon(Icons.data_array_outlined),
              label: 'Output Files',
            ),
          ],
        );
      }),
    );
  }
}
