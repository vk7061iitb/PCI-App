import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

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
    if (kDebugMode) {
      print('Location permission granted');
    }
  }
}
