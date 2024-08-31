/*
  Function to initialize the download folder
  This function is used to create a folder in the external storage of the device
  where the data will be stored.
*/

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> initializeDirectory() async {
  String rawData = "Acceleration Data";
  Directory? appExternalStorageDir = await getExternalStorageDirectory();
  Directory path = await Directory(join(appExternalStorageDir!.path, rawData))
      .create(recursive: true);
  return path.path;
}
