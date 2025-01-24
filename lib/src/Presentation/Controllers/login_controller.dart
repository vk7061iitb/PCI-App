/* 
  This file contains the controller for the login screen
  It contains the logic for the login screen
  It is responsible for handling the user input and sending it to the server
  It also updates the local database with the user data
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/src/API/auth_service.dart';
import 'package:pciapp/src/Models/user_data.dart';
import 'package:pciapp/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';

class LoginController extends GetxController {
  UserAuthenticationService userAuthenticationService =
      UserAuthenticationService();
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoggingIn = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final RxString _userRole = "Admin".obs;
  UserDataController userDataController = UserDataController();

  // Getters
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoggingIn => _isLoggingIn.value;
  String get userRole => _userRole.value;
  // Setters
  set isLoggedIn(bool value) => _isLoggedIn.value = value;
  set isLoggingIn(bool value) => _isLoggingIn.value = value;
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

    try {
      if (serverMessage['Message'] == 'User exists') {
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
      }
      return {
        "val": 1,
        "Message": serverMessage['Message'].toString(),
      };
    } catch (e) {
      logger.e(e.toString());
      return {
        "val": 2,
        "Message": e.toString(),
      };
    }
  }

  void onLoginTapped() async {
    if (!loginFormKey.currentState!.validate()) {
      Get.showSnackbar(
        customGetSnackBar(
          "Invalid Details",
          "Please enter valid details",
          Icons.error_outline,
        ),
      );
      return;
    }

    _isLoggingIn.value = true;

    try {
      final result = await loginUser();

      if (result['val'] == 0) {
        // Login successful
        _isLoggedIn.value = true;
        Get.showSnackbar(
          customGetSnackBar(
            "Login Successful",
            "You've been successfully logged in",
            Icons.check_circle_outline,
          ),
        );

        // Navigate to home and reset logging in state when navigation is complete
        await Get.offNamed(myRoutes.homeRoute);
      } else {
        // Login failed
        _isLoggedIn.value = false;
        Get.showSnackbar(
          customGetSnackBar(
            "Login Failed",
            result['Message'] ?? "User does not exist",
            Icons.error_outline,
          ),
        );
      }
    } catch (error) {
      // Handle any unexpected errors
      _isLoggedIn.value = false;
      logger.e(error.toString());
      Get.showSnackbar(
        customGetSnackBar(
          "Login Error",
          error.toString(),
          Icons.error_outline,
        ),
      );
    } finally {
      // Ensure logging in state is reset
      _isLoggingIn.value = false;
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
