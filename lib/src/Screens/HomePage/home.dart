import 'package:flutter/material.dart';
import 'package:pci_app/src/Screens/MapsPage/maps_page.dart';
import '../SensorPage/sensor_page.dart';
import '../OutputData/output_data.dart';
import '../SavedFile/saved_files_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    SensorPage(),
    MapPage(),
    HistoryDataPage(),
    OutputDataPage(),
  ];

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 500),
        height: 0.18 * MediaQuery.of(context).size.width,
        onDestinationSelected: _onTapped,
        indicatorColor: Colors.blue.shade100,
        selectedIndex: _selectedIndex,
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
      ),
    );
  }
}
