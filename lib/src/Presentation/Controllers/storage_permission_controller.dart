/*
*  This controller is used to request storage permission
*  from the user. It uses the permission_handler package to request the permission.
*  If the permission is granted, it prints 'Storage permission granted'.
*  If the permission is denied, it prints 'Storage permission denied' and if the permission is permanently denied,
*  it prints 'Storage permission permanently denied' and opens the app settings.
 */

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePermission extends GetxController {
  Future<bool> requestPermission() async {
    final PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> checkPermission() async {
    bool isGranted = await requestPermission();
    if (isGranted) {
      debugPrint('Storage permission granted');
    } else {
      openAppSettings();
      debugPrint('Storage permission denied');
    }
  }
}
