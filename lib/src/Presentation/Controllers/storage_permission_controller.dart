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
