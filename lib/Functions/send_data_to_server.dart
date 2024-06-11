import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Objects/pci_object.dart';
import 'package:share_plus/share_plus.dart';
import '../Objects/data_points.dart';

Future<String> sendDataToServer(List<AccData> accData) async {
  String message = "Data sent successfully";
  const String url = 'http://13.201.2.105/track_labeler';

  List<Map<String, dynamic>> data =
      accData.map((data) => data.toJson()).toList();

  final String jsonData = json.encode(data);

  List<Map<String, dynamic>> pciData = [];

  List<PciData2> outputData = [];

  if (kDebugMode) {
    getDownloadsDirectory().then((Directory? directory) async {
      final File file = File('${directory?.path}/data.json');
      await file.writeAsString(jsonData);
      XFile fileToShare = XFile(file.path);
      Share.shareXFiles([fileToShare]);
    });
  }

  try {
    if (kDebugMode) {
      print('Sending data to server...');
    }
    final http.Response response = await http
        .post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    )
        .timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        message = "Server took too long to respond";
        return http.Response('Server took too long to respond', 408);
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      pciData = List<Map<String, dynamic>>.from(responseData);

      int outuputDataID =
          await localDatabase.insertOutputData("Output Data", dropdownValue);

      for (var data in pciData) {
        outputData.add(PciData2(
            outuputDataID: outuputDataID,
            latitude: data['latitude'],
            longitude: data['longitude'],
            velocity: data['velocity'],
            prediction: data['prediction']));
      }
      await localDatabase.insertPciData(outputData);
      return message;
    } else {
      if (kDebugMode) {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
      message = 'Failed to send data. Status code: ${response.statusCode}';
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }
      return message;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
    return e.toString();
  }
}
