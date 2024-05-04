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

var xAcceleration = 0.0;
var yAcceleration = 0.0;
var zAcceleration = 0.0;

var xGyroscope = 0.0;
var yGyroscope = 0.0;
var zGyroscope = 0.0;

bool isRecordingData = false;
bool showStartButton = true;

// Map Page Data
String geoJsonData = ''; // String reperesentation of selected file
Map<String, dynamic> jsonData =
    {}; // A map obtained from jsonDecode of geoJsonData
List<dynamic> features = []; // Extracts the features of the jsonData
List<dynamic> coordinates = []; // Stores the cooedinate of features(a list)
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