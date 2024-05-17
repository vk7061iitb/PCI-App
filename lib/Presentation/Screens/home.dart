import 'package:flutter/material.dart';
import 'package:pci_app/Presentation/Screens/maps_page.dart';
import 'package:pci_app/Presentation/Screens/sensor_page.dart';
import '../../Objects/data.dart';
import 'show_history.dart';

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
  ];

  @override
  void dispose() {
    for (final subscription in streamSubscriptions) {
      subscription.cancel();
      super.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 500),
        height: 0.18 * MediaQuery.of(context).size.width,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
        ],
      ),
    );
  }
}
