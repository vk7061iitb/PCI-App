import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:pci_app/Objects/data.dart';
import '../Models/data_points.dart';
import '../Models/pci_data.dart';
import '../Models/stats_data.dart';
import '../config/config.dart';
import 'package:http/http.dart' as http;

class SendDataToServer {
  final String sendBaseURL;
  SendDataToServer() : sendBaseURL = Config.getAuthBaseURL();

  Future<String> sendData(
      {required List<AccData> accData, required String userID}) async {
    String message = "Data sent successfully";
    String url = "$sendBaseURL${Config.sendDataEndPoint}";
    join(sendBaseURL, Config.sendDataEndPoint);
    List<Map<String, dynamic>> sensorData =
        accData.map((datapoint) => datapoint.toJson()).toList();

    List<PciData2> outputData = [];
    List<OutputStats> outputStats = [];

    /* if (kDebugMode) {
      getDownloadsDirectory().then(
        (Directory? directory) async {
          final File file = File('${directory?.path}/data.json');
          await file.writeAsString(jsonEncode(sensorData));
          XFile fileToShare = XFile(file.path);
          Share.shareXFiles([fileToShare]);
        },
      );
    } */

    try {
      final http.Response response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Userid': userID,
          'vehicle_type': dropdownValue,
        },
        body: jsonEncode(sensorData),
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
        int outuputDataID =
            await localDatabase.insertOutputData("Output Data", dropdownValue);

        for (var data in responseData['labels']) {
          outputData.add(
            PciData2(
              outuputDataID: outuputDataID,
              latitude: data['latitude'],
              longitude: data['longitude'],
              velocity: data['velocity'],
              prediction: data['prediction'],
            ),
          );
        }
        responseData['stats'].forEach(
          (key, value) {
            outputStats.add(
              OutputStats(
                outputDataID: outuputDataID,
                pci: key,
                avgVelocity: value['avg_velocity'].toString(),
                distanceTravelled: value['distance_travelled'].toString(),
                numberOfSegments: value['number_of_segments'].toString(),
              ),
            );
          },
        );
        await localDatabase.insertPciData(outputData);
        await localDatabase.insertStats(outputStats);
        return message;
      } else {
        debugPrint('Failed to send data. Status code: ${response.statusCode}');
        message = 'Failed to send data. Status code: ${response.statusCode}';
        debugPrint('Response body: ${response.body}');
        return message;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return e.toString();
    }
  }
}