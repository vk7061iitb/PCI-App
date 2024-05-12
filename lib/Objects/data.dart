import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Objects/data_points.dart';
import 'polyline_obj.dart';

Position devicePosition = Position(
  latitude: 0.0,
  longitude: 0.0,
  altitude: 0.0,
  accuracy: 0.0,
  timestamp: DateTime.now(),
  altitudeAccuracy: 0.0,
  heading: 0.0,
  headingAccuracy: 0.0,
  speed: 0,
  speedAccuracy: 0,
);

List<AccData> accDataList = [];
List<GyroData> gyroDataList = [];

List<double> accData = [0, 0, 0];
List<double> gyroData = [0, 0, 0];

bool isRecordingData = false;
bool showStartButton = true;

// Map Page Data
String geoJsonData = '';
Map<String, dynamic> jsonData = {};
List<dynamic> features = [];
List<dynamic> coordinates = [];
Set<Polyline> polylines = {};
List<PolylinObj> polylineObj = [];
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

// Sensor Page Data
Timer? accCallTimer;
Timer? locationCallTimer;
String message = '';
String requestLocationMessage = '';
String gyroscopeImgPath = 'lib/Assets/gyroscope.png';
String accelerationImgPath = 'lib/Assets/speedometer.png';
String startMessage = 'Tap "Start" to collect data';
String progressMessage = 'Collecting the data...';
String locationErrorMessage =
    "Sorry, we couldn't find your device location. Please press the start button and try again";
const List<String> vehicleType = <String>[
  'Bike',
  'Car',
  'Auto',
  'Bus',
  'Others'
];

String dropdownValue = vehicleType.first;
final streamSubscriptions = <StreamSubscription<dynamic>>[];

// Settings Page Data
LocationAccuracy geolocatorLocationAccuracy = LocationAccuracy.best;
