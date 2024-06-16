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
