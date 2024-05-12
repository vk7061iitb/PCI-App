import 'dart:convert';
import 'package:pci_app/Objects/data.dart';
import 'package:web_socket_channel/io.dart';

Future<void> sendData() async {
  List<Map<String, dynamic>> jsonList =
      accDataList.map((data) => data.toJson()).toList();
  String jsonString = jsonEncode(jsonList);
  final channel = IOWebSocketChannel.connect('ws://192.168.173.142:5000');
  channel.sink.add(jsonString);
}
