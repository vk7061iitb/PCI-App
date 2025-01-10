import 'dart:convert';
import 'package:path/path.dart';
import 'package:pci_app/Objects/data.dart';
import '../Models/stats_data.dart';
import '../config/config.dart';
import 'package:http/http.dart' as http;

class SendDataToServer {
  SendDataToServer() : sendBaseURL = Config.getAuthBaseURL();

  final String sendBaseURL;
  int statusCode = 0;
  Future<String> sendData({
    required List<Map<String, dynamic>> accData,
    required String userID,
    required String filename,
    required String vehicleType,
    required DateTime time,
    required String planned,
  }) async {
    ///
    String message = "Data Submitted Successfully";
    String url = "$sendBaseURL${Config.sendDataEndPoint}";
    join(sendBaseURL, Config.sendDataEndPoint);
    List<RoadOutputData> roadOutputData = [];
    logger.i("Planned/Unplanned : $planned");
    try {
      final http.Response response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Userid': userID,
          'vehicle_type': vehicleType,
          'Roadname': filename,
          'Roadtype': "roadType"
        },
        body: jsonEncode(accData),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          message = "Server took too long to respond";

          return http.Response('Server took too long to respond', 408);
        },
      ).onError((error, stackTrace) {
        logger.e(error.toString());
        logger.e(stackTrace.toString());
        return http.Response('Error: $error', 500);
      });
      // Get the status code
      statusCode = response.statusCode;

      if (response.statusCode == 200) {
        String geoJsonString = response.body;
        final responseData = jsonDecode(geoJsonString);
        int outuputDataID = await localDatabase.insertJourneyData(
          filename: filename,
          vehicleType: vehicleType,
          time: time,
          planned: planned,
        );

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
          roadOutputData: roadOutputData,
        );
        return message;
      } else {
        logger.f('Failed to send data. Status code: ${response.statusCode}');
        message = 'Failed to send data. ${response.body}';
        logger.d('Response body: ${response.body}');
        return message;
      }
    } catch (e, stacktrace) {
      logger.f('Error: $e');
      logger.f('stack trace : $stacktrace');
      return e.toString();
    }
  }
}
