import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:web_socket_channel/io.dart';

import 'package:http/http.dart' as http;

sendData() async {
  List<Map<String, dynamic>> jsonList =
      accDataList.map((accData) => accData.toJson()).toList();
  String jsonString = jsonEncode(jsonList);

  final channel = IOWebSocketChannel.connect('ws://10.96.6.13:5000/');
  channel.sink.add(jsonString);
}

Future<void> sendDataToServer() async {
  String url = 'http://192.168.58.247:5000';
  List<Map<String, dynamic>> jsonList =
      accDataList.map((accData) => accData.toJson()).toList();
  String jsonString = jsonEncode(jsonList);
  dynamic data = jsonString;
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    if (kDebugMode) {
      print('Data sent successfully');
    }
  } else {
    throw Exception('Failed to send data');
  }
}
