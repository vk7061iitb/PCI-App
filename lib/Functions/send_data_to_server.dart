import 'dart:convert';
import 'package:pci_app/Objects/data.dart';
import 'package:web_socket_channel/io.dart';

sendData() async {
  List<Map<String, dynamic>> jsonList =
      accDataList.map((accData) => accData.toJson()).toList();
  String jsonString = jsonEncode(jsonList);

  final channel = IOWebSocketChannel.connect('ws://192.168.137.1:3000/');
  channel.sink.add(jsonString);
  channel.sink.close();
}
