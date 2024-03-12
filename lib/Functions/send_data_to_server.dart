import 'dart:convert';

import 'package:pci_app/Objects/data.dart';
import 'package:web_socket_channel/io.dart';

import '../Objects/data_points.dart';

sendData() async {
  List<AccData> accDataList = [];
  accDataList.add(AccData(
      xAcc: -0.345,
      yAcc: -0.345,
      zAcc: -0.345,
      devicePosition: devicePosition,
      accTime: DateTime.now()));
  List<Map<String, dynamic>> jsonList =
      accDataList.map((accData) => accData.toJson()).toList();
  String jsonString = jsonEncode(jsonList);

  final channel = IOWebSocketChannel.connect('ws://10.96.24.203:3000/');
  channel.sink.add(jsonString);
}
