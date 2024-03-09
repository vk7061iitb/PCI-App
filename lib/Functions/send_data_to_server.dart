import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void sendDataToServer() async {
var url = 'http://127.0.0.1:3000/data'; // URL of your Node.js server

  // Sample JSON data to be sent to the server
  var data = {'name': 'John', 'age': 30};

  // Encoding JSON data
  var body = jsonEncode(data);

  // Sending POST request to the server
  var response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  // Printing server response
  if (kDebugMode) {
    print('Response status: ${response.statusCode}');
  }
  if (kDebugMode) {
    print('Response body: ${response.body}');
  }
}