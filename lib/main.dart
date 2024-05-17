import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pci_app/firebase_options.dart';
import 'Functions/request_location_permission.dart';
import 'Functions/request_storage_permission.dart';
import 'Objects/data.dart';
import 'Presentation/Screens/maps_page.dart';
import 'Presentation/Screens/sensor_page.dart';
import 'Presentation/Screens/show_history.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    checkPermission();
    streamSubscriptions.add(
      Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
        forceLocationManager: false,
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        intervalDuration: const Duration(milliseconds: 250),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'PCI App',
          notificationText: 'Collecting Location Data',
          notificationChannelName: 'PCI App',
          setOngoing: true,
          enableWakeLock: true,
          color: Colors.blueAccent,
        ),
      )).listen(
        (event) {
          devicePosition = event;
        },
      ),
    );
  }

  void checkPermission() async {
    await requestLocationPermission();
    await requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Color(0xFFF3EDF5),
          systemNavigationBarIconBrightness: Brightness.dark),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
      ),
    );
  }
}
