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

  /// Requests location permission from the user.
  ///
  /// Returns a [Future] that completes with a boolean value indicating
  /// whether the location permission was granted (`true`) or denied (`false`).
  ///
  /// This method should be called before attempting to access the device's
  /// location to ensure that the necessary permissions are in place.

  Future<bool> locationPermission() async {
    final locationService = await Permission.location.serviceStatus.isEnabled;
    List<Permission> permissions = [
      Permission.location,
      Permission.locationWhenInUse,
    ];
    // check gps is enabled
    if (!locationService) {
      Get.dialog(
        AlertDialog(
          title: const Text('Location Disabled'),
          content: const Text(
              'Location is disabled, please enable location to get the current location'),
          actions: [
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings().then((_) {
                  Get.back();
                });
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
    }
    // check each location permission
    for (var permission in permissions) {
      PermissionStatus status = await permission.status;

      if (status.isGranted) {
        continue;
      }
      await permission.request().then((res) {
        if (!res.isGranted) {
          // show dialog
          Get.dialog(
            AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                  'Location permission is required to get the current location'),
              actions: [
                TextButton(
                  onPressed: () {
                    openAppSettings().then((_) {
                      Get.back();
                      locationPermission();
                    });
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      });
    }
    notificationPermission();
    return true;
  }

  Future<bool> notificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }
    await Permission.notification.request().then((PermissionStatus result) {
      if (result.isDenied) {
        return false;
      }
      return true;
    });
    return true;
  }
}
