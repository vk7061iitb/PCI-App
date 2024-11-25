// This file contains the code for the user authentication service(Backend API)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/config/config.dart';
import '../Models/user_data.dart';

class UserAuthenticationService {
  final String authURL;
  UserAuthenticationService() : authURL = Config.getAuthBaseURL();

  Future<Map<String, dynamic>> loginUser({required UserData user}) async {
    logger.d('Logging in user...');
    String loginURL = "$authURL${Config.loginEndPoint}";
    Map<String, dynamic> data = {};
    try {
      final http.Response response = await http
          .post(
        Uri.parse(loginURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'Email_Id': user.email,
            'Phone_num': user.phoneNumber,
          },
        ),
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
        logger.d(response.body);
        return data;
      }
    } catch (e) {
      logger.e(e.toString());
      return data;
    }
  }

  // Sign up user
  Future<Map<String, dynamic>> signUp(
      {required String name,
      required String email,
      required String phone}) async {
    String signUpURL = "$authURL${Config.signUpEndpoint}";
    Map<String, dynamic> data = {
      'Name': name,
      'Email_Id': email,
      'Phone_num': phone,
    };
    Map<String, dynamic> responseData = {};
    try {
      final http.Response response = await http
          .post(
        Uri.parse(signUpURL),
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
}
