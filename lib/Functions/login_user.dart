import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../src/Models/user_data.dart';

Future<Map<String, dynamic>> loginUser(UserData user) async {
  debugPrint('Logging in user...');
  const String url = 'http://3.109.203.37/login';
  Map<String, dynamic> data = {};
  try {
    final http.Response response = await http
        .post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'Email_Id': user.email,
        'Phone_num': user.phoneNumber,
      }),
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        return http.Response('Server took too long to respond', 408);
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      data = responseData;
      return data;
    } else {
      debugPrint(response.body);
      return data;
    }
  } catch (e) {
    debugPrint(e.toString());
    return data;
  }
}
