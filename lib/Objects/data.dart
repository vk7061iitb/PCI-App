import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:pci_app/Functions/datetime_format.dart';
import 'package:pci_app/Utils/assets.dart';
import '../src/Database/sqlite_db_helper.dart';
import '../Utils/routes.dart';

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
