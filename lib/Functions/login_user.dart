import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Objects/user_data.dart';

Future<Map<String, dynamic>> loginUser(UserData user) async {
  if (kDebugMode) {
    print('Logging in...');
  }
  const String url = 'http://13.201.2.105/login';
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
      if (kDebugMode) {
        print(response.body);
      }
      return data;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return data;
  }
}

Future<Map<String, dynamic>> signUp(
    String name, String email, String phone) async {
  const String url = 'http://13.201.2.105/signup';
  Map<String, dynamic> data = {
    'Name': name,
    'Email_Id': email,
    'Phone_num': phone,
  };
  Map<String, dynamic> responseData = {};
  try {
    final http.Response response = await http
        .post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    )
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        return http.Response('Server took too long to respond', 408);
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (kDebugMode) {
        print(responseData);
      }
      return responseData;
    } else {
      if (kDebugMode) {
        print('Failed to send data, Status code: ${response.statusCode}');
      }
      return responseData;
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return responseData;
  }
}
