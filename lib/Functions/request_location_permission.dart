import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

Future<String> requestLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  String message = '';

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    message = 'Location services are disabled.';
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
        Geolocator.openLocationSettings();
    if (kDebugMode) {
      print('Location permission denied');
      message = 'Location permission denied';
    }
  } else {
    message = 'Location permission granted';
  }
  return message;
}
