import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:pci_app/Objects/data.dart';
import '../Models/data_points.dart';
import '../Models/stats_data.dart';
import '../config/config.dart';
import 'package:http/http.dart' as http;

class SendDataToServer {
  SendDataToServer() : sendBaseURL = Config.getAuthBaseURL();

  final String sendBaseURL;
  int statusCode = 0;
  Future<String> sendData(
      {required List<AccData> accData,
      required String userID,
      required filename}) async {
    String message = "Data Submitted Successfully";
    String url = "$sendBaseURL${Config.sendDataEndPoint}";
    join(sendBaseURL, Config.sendDataEndPoint);
    List<Map<String, dynamic>> sensorData =
        accData.map((datapoint) => datapoint.toJson()).toList();
    List<RoadOutputData> roadOutputData = [];

    try {
      final http.Response response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Userid': userID,
          'vehicle_type': dropdownValue,
          'Roadname': filename,
        },
        body: jsonEncode(sensorData),
      )
          .timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          message = "Server took too long to respond";
          return http.Response('Server took too long to respond', 408);
        },
      );
      // Get the status code
      statusCode = response.statusCode;

      if (response.statusCode == 200) {
        String geoJsonString = response.body;
        final responseData = jsonDecode(geoJsonString);

        int outuputDataID =
            await localDatabase.insertJourneyData(filename, dropdownValue);

        // Extract the road data
        List<dynamic> roads = responseData['roads_covered'];
        // Insert the each road data
        for (var road in roads) {
          RoadData roadData = RoadData(
            roadName: road,
            labels: (responseData[road]['labels'] as List<dynamic>)
                .map((item) => item as Map<String, dynamic>)
                .toList(),
            stats: responseData[road]['stats'],
          );

          // Add the journey data to the roadOutputData
          roadOutputData.add(
            RoadOutputData(
              outputDataID: outuputDataID,
              roadData: roadData,
            ),
          );
        }

        await localDatabase.insertToRoadOutputData(
            roadOutputData: roadOutputData);
        return message;
      } else {
        debugPrint('Failed to send data. Status code: ${response.statusCode}');
        message = 'Failed to send data. Status code: ${response.statusCode}';
        debugPrint('Response body: ${response.body}');
        return message;
      }
    } catch (e) {
      // Error in building the connection to the server
      // Save that file to the local database and send it later

      debugPrint('Error: $e');
      return e.toString();
    }
  }
}
