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
