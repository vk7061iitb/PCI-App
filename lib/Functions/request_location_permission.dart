import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

Future<String> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  String message = '';
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    if (kDebugMode) {
      print('Location permission denied');
    }
  } else {
    message = 'Location permission granted';
    if (kDebugMode) {
      print('Location permission granted');
    }
  }

  return message;
}
