/* 
  This file contains the controller for the login screen
  It contains the logic for the login screen
  It is responsible for handling the user input and sending it to the server
  It also updates the local database with the user data
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/API/auth_service.dart';
import 'package:pci_app/src/Models/user_data.dart';
import 'package:pci_app/src/Presentation/Controllers/user_data_controller.dart';

class LoginController extends GetxController {
  UserAuthenticationService userAuthenticationService =
      UserAuthenticationService();
  final RxBool _isLoggedIn = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final RxString _userRole = "Admin".obs;
  UserDataController userDataController = UserDataController();

  // Getters
  bool get isLoggedIn => _isLoggedIn.value;
  String get userRole => _userRole.value;
  // Setters
  set isLoggedIn(bool value) => _isLoggedIn.value = value;
  set userRole(String value) => _userRole.value = value;

  Future<Map<String, dynamic>> loginUser() async {
    // Send the user data to the server
    if (!loginFormKey.currentState!.validate()) {
      return {
        "val": -1,
        "Message": "Form not validated",
      };
    }
    Map<String, dynamic> serverMessage =
        await userAuthenticationService.loginUser(
      user: UserData(
        email: emailController.text,
        phoneNumber: phoneController.text,
        userRole: _userRole.value,
      ),
    );
    logger.i(serverMessage.toString());

    try {
      if (serverMessage['Message'] == 'User exists') {
        _isLoggedIn.value = true;
        final user = {
          "ID": serverMessage['User_Id'].toString(),
          "email": emailController.text,
          "phone": phoneController.text,
          "role": _userRole.value,
          "isLoggedIn": true,
        };
        userDataController.storage.write("user", user);
        userDataController.user = user;
        return {
          "val": 0,
          "Message": serverMessage['Message'],
        };
      } else {
        return {
          "val": 1,
          "Message": serverMessage['Message'].toString(),
        };
      }
    } catch (e) {
      logger.e(e.toString());
      return {
        "val": 2,
        "Message": e.toString(),
      };
    }
  }

  @override
  void dispose() {
    logger.d("Disposing Login Controller");
    emailController.dispose();
    phoneController.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}
