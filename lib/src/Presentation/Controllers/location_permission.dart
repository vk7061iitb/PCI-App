import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationController extends GetxController {
  final RxBool _serviceEnabled = false.obs;
  final Rx<LocationPermission> _permission = LocationPermission.denied.obs;

  final _textStyle = GoogleFonts.inter(
    color: Colors.blue,
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

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

    if (!serviceEnabled || permission != LocationPermission.always) {
      showLocationDialog();
    }
  }

  // Check if GPS service is enabled
  Future<void> checkLocationService() async {
    _serviceEnabled.value = await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  Future<void> checkLocationPermission() async {
    _permission.value = await Geolocator.checkPermission();
  }

  // Show a single dialog based on the current status
  void showLocationDialog() {
    String title;
    String content;

    if (!serviceEnabled) {
      title = 'Enable Location Services';
      content =
          'To use this app, you need to enable location services on your device.';
    } else if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      title = 'Grant Location Permission';
      content = 'Please grant location access to this app to continue.';
    } else {
      title = 'Grant All Time Location Access';
      content =
          'Please grant "Allow all the Time" location access for better app performance.';
    }

    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.inter(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        actions: _buildDialogActions(),
      ),
    );
  }

  // Build dialog actions based on the current status
  List<Widget> _buildDialogActions() {
    List<Widget> actions = [];

    if (!serviceEnabled) {
      actions.add(
        TextButton(
          onPressed: () {
            Geolocator.openLocationSettings();
            Get.back();
          },
          child: Text('Enable Location', style: _textStyle),
        ),
      );
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      actions.add(
        TextButton(
          onPressed: () async {
            await Geolocator.requestPermission();
            Get.back();
            checkAndRequestLocation(); // Re-check the status after requesting
          },
          child: Text('Grant Permission', style: _textStyle),
        ),
      );
    }

    if (permission != LocationPermission.always) {
      actions.add(
        TextButton(
          onPressed: () async {
            await Geolocator.requestPermission();
            Get.back();
            checkAndRequestLocation(); // Re-check the status after requesting
          },
          child: Text('Grant All Time Access', style: _textStyle),
        ),
      );
      actions.add(
        TextButton(
          onPressed: () {
            Geolocator.openAppSettings();
            Get.back();
          },
          child: Text(
            'Go to Settings',
            style: _textStyle,
          ),
        ),
      );
    }
    return actions;
  }
}
