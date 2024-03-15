import 'package:flutter/material.dart';
import 'package:pci_app/Functions/request_storage_permission.dart';
import 'package:pci_app/Presentation/Screens/maps_page.dart';
import 'package:pci_app/Presentation/Screens/sensor_page.dart';

import '../../Functions/request_location_permission.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[SensorPage(), MapPage()];

    @override
  void initState() {
    super.initState();
    requestLocationPermission();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        height: 0.16 * MediaQuery.of(context).size.width,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Colors.blue.shade100,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: Colors.blueAccent,),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.map,color: Colors.blueAccent ),
            icon: Icon(Icons.map_outlined),
            label: 'Maps',
          ),
        ],
      ),
    );
  }
}
