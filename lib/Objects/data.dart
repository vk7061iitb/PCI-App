import 'package:geolocator/geolocator.dart';
import 'package:pci_app/Objects/data_points.dart';

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
