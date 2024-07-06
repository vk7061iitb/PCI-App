import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

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

    if (serviceEnabled) {
      await checkLocationPermission();
      if (permission != LocationPermission.always) {
        await requestAllTimeLocationPermission().then((_) {
          checkAndRequestLocation();
        });
      }
    }
  }

  // Check if GPS service is enabled
  Future<void> checkLocationService() async {
    _serviceEnabled.value = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled.value) {
      Get.dialog(
        AlertDialog(
          title: Text(
            'Location Services Required',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          content: Text(
            'To use this app, you need to enable location services on your device.',
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Geolocator.openLocationSettings();
                Get.back();
              },
              child: Text(
                'Enable Location',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
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
          title: Text(
            'Location Services Required',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          content: Text(
            'Please grant location access to this app to continue.',
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await Geolocator.requestPermission();
                Get.back();
                await checkLocationPermission(); // Re-check the permission after requesting
              },
              child: Text(
                'Grant Permission',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

// Request "All the Time" location permission
  Future<void> requestAllTimeLocationPermission() async {
    if (_permission.value == LocationPermission.always) {
      debugPrint('Location permission is already set to "All the Time".');
      return;
    } else {
      Get.dialog(
        AlertDialog(
          title: Text(
            'Please Grant All Time Location Access',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          content: Text(
            'Please grant "Allow all the Time" location access.',
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await Geolocator.requestPermission();
                Get.back();
                await checkLocationPermission(); // Re-check the permission after requesting
              },
              child: Text(
                'Grant All Time Access',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Get.back();
              },
              child: Text(
                'Go to Settings',
                style: GoogleFonts.inter(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
