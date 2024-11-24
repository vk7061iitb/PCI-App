import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationController extends GetxController {
  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationPermission();
    });
    super.onInit();
  }

  Future<void> locationPermission() async {
    final locationService = await Permission.location.serviceStatus.isEnabled;
    List<Permission> permissions = [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ];

    for (Permission permission in permissions) {
      final PermissionStatus status = await permission.status;
      if (!locationService) {
        await Geolocator.openLocationSettings();
        return;
      }
      if (status.isDenied) {
        final req = await permission.request();
        if (req.isDenied) {
          openAppSettings();
          return;
        }
        if (req.isPermanentlyDenied) {
          openAppSettings();
          return;
        }
      }
    }
  }
}
