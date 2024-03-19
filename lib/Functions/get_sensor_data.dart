import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pci_app/Objects/data.dart';

Future<void> getPositionStream() async {
  try {
    Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        distanceFilter: 0,
        accuracy: LocationAccuracy.best,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          enableWakeLock: true,
          notificationTitle: 'Location',
          notificationText: 'PCI App is using Location',
        ),
      ),
    ).listen(
      (Position currentPosition) {
        devicePosition = currentPosition;
        if (kDebugMode) {
          print('Latitude :${devicePosition.latitude}, Longitude :${devicePosition.longitude}');
        }
      },
    );
  } catch (e) {
    // Handle any errors that occur during stream listening
    if (kDebugMode) {
      print('Error occurred while listening to position stream: $e');
    }
  }
}
