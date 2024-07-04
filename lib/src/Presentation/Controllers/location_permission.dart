import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  final RxBool _serviceEnabled = false.obs;
  final Rx<LocationPermission> _permission = LocationPermission.denied.obs;

  // Getters
  bool get serviceEnabled => _serviceEnabled.value;
  LocationPermission get permission => _permission.value;

  // Setters
  set serviceEnabled(bool value) => _serviceEnabled.value = value;
  set permission(LocationPermission value) => _permission.value = value;

  @override
  void onInit() {
    super.onInit();
    checkAndRequestLocation();
  }

  // Check GPS service and permissions
  void checkAndRequestLocation() async {
    await checkLocationService();
    await checkLocationPermission();
    await requestAllTimeLocationPermission();
  }

  // Check if GPS service is enabled
  Future<void> checkLocationService() async {
    _serviceEnabled.value = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled.value) {
      Get.dialog(
        AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text('Please enable location services to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Get.back();
              },
              child: const Text('Enable Location'),
            ),
          ],
        ),
      );
    }
  }

  // Check location permission status
  Future<void> checkLocationPermission() async {
    _permission.value = await Geolocator.checkPermission();
    if (_permission.value == LocationPermission.denied ||
        _permission.value == LocationPermission.deniedForever) {
      Get.dialog(
        AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Please grant location access to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                _permission.value = await Geolocator.requestPermission();
                if (_permission.value == LocationPermission.denied ||
                    _permission.value == LocationPermission.deniedForever) {
                  giveLocationAccess();
                } else {
                  await requestAllTimeLocationPermission();
                }
                Get.back();
              },
              child: const Text('Grant Permission'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Get.back();
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      );
    } else {
      await requestAllTimeLocationPermission();
    }
  }

  // Request "All the Time" location permission
  Future<void> requestAllTimeLocationPermission() async {
    if (_permission.value == LocationPermission.always) {
      debugPrint('Location permission is already set to "All the Time".');
      return;
    }

    if (_permission.value == LocationPermission.whileInUse) {
      Get.dialog(
        AlertDialog(
          title: const Text('All Time Location Access Required'),
          content: const Text(
              'Please grant "All the Time" location access for better app functionality.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                _permission.value = await Geolocator.requestPermission();
                if (_permission.value == LocationPermission.always) {
                  debugPrint('Location permission set to "All the Time".');
                } else {
                  giveAllTimeLocationAccess();
                }
                Get.back();
              },
              child: const Text('Grant All Time Access'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Get.back();
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      );
    } else {
      _permission.value = await Geolocator.requestPermission();
      if (_permission.value == LocationPermission.always) {
        debugPrint('Location permission set to "All the Time".');
      } else {
        giveAllTimeLocationAccess();
      }
    }
  }

  // Dialog for location permission access
  void giveLocationAccess() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text('Please grant location access to continue.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Geolocator.openLocationSettings();
              Get.back();
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  // Dialog for "All the Time" location permission access
  void giveAllTimeLocationAccess() {
    Get.dialog(
      AlertDialog(
        title: const Text('All Time Location Access Required'),
        content: const Text(
            'Please grant "All the Time" location access for better app functionality.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Geolocator.openLocationSettings();
              Get.back();
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }
}
