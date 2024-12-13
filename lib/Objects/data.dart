import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:pci_app/Utils/datetime_format.dart';
import 'package:pci_app/Utils/assets.dart';
import '../src/Database/sqlite_db_helper.dart';
import '../Utils/routes.dart';
import '../src/Presentation/Controllers/user_data_controller.dart';

MyRoutes myRoutes = MyRoutes();
const List<String> mapType = [
  'Normal',
  'Satellite',
  'Hybrid',
  'Teraain',
  'None'
];
const List<MapType> googlemapType = [
  MapType.normal,
  MapType.satellite,
  MapType.hybrid,
  MapType.terrain,
  MapType.none
];
MapType googleMapType = MapType.normal;
String locationErrorMessage =
    "Sorry, we couldn't find your device location. Please press the start button and try again";
const List<String> vehicleType = <String>[
  'Bike',
  'Car',
  'Auto',
  'Bus',
  'Others'
];

AssetsPath assetsPath = AssetsPath();
UserDataController userDataController = UserDataController();
final user = userDataController.storage.read('user');
// Settings Page Data
LocationAccuracy geolocatorLocationAccuracy = LocationAccuracy.best;
SQLDatabaseHelper localDatabase = SQLDatabaseHelper();
DateTimeParser dateTimeParser = DateTimeParser();
// logger
var logger = Logger(
  filter: null,
  printer: PrettyPrinter(
    printEmojis: true,
  ),
  output: null,
);

Color backgroundColor = const Color(0xFFF1F3F4);
Color textColor = Color(0xFF202124);
Color white = Color(0xFFFFFFFF);
Color activeColor = Color(0xFF1A73E8);
Color inactiveColor = Color(0xFF757575);
