import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

Future<String> loadGeoJsonFromFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.any);

  if (result != null) {
    File file = File(result.files.single.path!);

    if (kDebugMode) {
      print('Picked file path: ${file.path}');
    }
    return await file.readAsString();
  } else {
    if (kDebugMode) {
      print('User canceled the file picking');
    }
    return '';
  }
}