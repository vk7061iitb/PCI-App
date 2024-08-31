/*
 * This function is used to request storage permission from the user.
 * It uses the permission_handler package to request the permission.
 * If the permission is granted, it prints 'Storage permission granted'.
 * If the permission is denied, it prints 'Storage permission denied' and if the permission is permanently denied,
 * it prints 'Storage permission permanently denied' and opens the app settings.
 */

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.request();
  if (status.isGranted) {
    if (kDebugMode) {
      print('Storage permission granted');
    }
  } else if (status.isDenied) {
    if (kDebugMode) {
      print('Storage permission denied');
    }
  } else if (status.isPermanentlyDenied) {
    if (kDebugMode) {
      print('Storage permission permanently denied');
    }
    openAppSettings();
  }
}
