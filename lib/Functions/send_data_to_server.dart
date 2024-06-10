import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import '../Objects/data_points.dart';

Future<void> sendData(List<AccData> accData) async {
  List<Map<String, dynamic>> jsonList =
      accData.map((data) => data.toJson()).toList();
  String jsonString = jsonEncode(jsonList);
  final channel = IOWebSocketChannel.connect('ws://13.201.2.105/track_labeler');
  channel.sink.add(jsonString);
}

Future<void> sendDataToServer(List<AccData> accData) async {
  const String url = 'http://13.201.2.105/track_labeler';

  List<Map<String, dynamic>> data =
      accData.map((data) => data.toJson()).toList();

  final String jsonData = json.encode(data);

  List<Map<String, dynamic>> pciData = [];

/*   if (kDebugMode) {
    getApplicationDocumentsDirectory().then((Directory directory) async {
      final File file = File('${directory.path}/data.json');
      await file.writeAsString(jsonData);

      XFile fileToShare = XFile(file.path);
      Share.shareXFiles([fileToShare]);
    });
  } */

  try {
    if (kDebugMode) {
      print('Sending data to server...');
    }
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      pciData = List<Map<String, dynamic>>.from(responseData);
      if (kDebugMode) {
        print("${pciData.length} data points received from server.");
      }
    } else {
      if (kDebugMode) {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}
