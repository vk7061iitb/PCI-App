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

class LoginController extends GetxController {
  UserAuthenticationService userAuthenticationService =
      UserAuthenticationService();
  final RxBool _isLoggedIn = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  Rx<UserData> currUser =
      UserData(phoneNumber: " ", email: " ", userRole: " ").obs;
  final RxString _userRole = "Admin".obs;

  // Getters
  bool get isLoggedIn => _isLoggedIn.value;
  String get userRole => _userRole.value;
  // Setters
  set isLoggedIn(bool value) => _isLoggedIn.value = value;
  set userRole(String value) => _userRole.value = value;

  Future<void> loginUser() async {
    // Send the user data to the server
    if (!loginFormKey.currentState!.validate()) return;
    Map<String, dynamic> serverMessage =
        await userAuthenticationService.loginUser(
      user: UserData(
        email: emailController.text,
        phoneNumber: phoneController.text,
        userRole: _userRole.value,
      ),
    );

    // Update the current user data
    if (serverMessage['Message'] == 'User exists') {
      _isLoggedIn.value = true;
      currUser.value = UserData(
        email: emailController.text,
        phoneNumber: phoneController.text,
        userID: serverMessage['User_Id'].toString(),
        userRole: _userRole.value,
      );

      debugPrint(serverMessage.toString());
      Future.wait([
        localDatabase.deleteUserData(),
        localDatabase.insertUserData(
          currUser.value,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    debugPrint("Disposing Login Controller");
    emailController.dispose();
    phoneController.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}
