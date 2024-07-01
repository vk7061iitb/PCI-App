/*
The loadGeoJsonFromFile() is used to load the output file(csv or geojson) manually by the user.
The function uses the FilePicker plugin to allow the user to select a file from the device.
*/

import 'package:pci_app/src/Models/pci_object.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'pci_data.dart';
import 'dart:io';

Future<void> loadGeoJsonFromFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.any);

  if (result != null) {
    File file = File(result.files.single.path!);
    String filePath = result.files.single.path!;
    String fileType = filePath.split('.').last;
    String fileContent = await file.readAsString();

    if (fileType == 'geojson' || fileType == 'json') {
      jsonData = jsonDecode(fileContent);
    } else if (fileType == 'csv') {
      List<List<dynamic>> csvData =
          const CsvToListConverter().convert(fileContent);

      List<dynamic> headerList = csvData[0];
      for (var data in headerList) {
        debugPrint(data.toString());
      }

      List<PciData> pciDataList = [];
      for (int i = 1; i < csvData.length; i++) {
        PciData pciData = PciData(
          latitude: csvData[i][0],
          longitude: csvData[i][1],
          velocity: csvData[i][2],
          label: csvData[i][3],
          pci: csvData[i][4],
        );
        pciDataList.add(pciData);
      }
      jsonData = convertToGeoJsonFormat(pciDataList);
    }
  } else {
    if (kDebugMode) {
      print('User canceled the file picking');
    }
  }
}
