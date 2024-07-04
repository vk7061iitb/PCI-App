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
  Rx<UserData> currUser = UserData(phoneNumber: " ", email: " ").obs;

  // Getters
  bool get isLoggedIn => _isLoggedIn.value;

  // Setters
  set isLoggedIn(bool value) => _isLoggedIn.value = value;

  Future<void> loginUser() async {
    // Send the user data to the server
    if (!loginFormKey.currentState!.validate()) return;
    Map<String, dynamic> serverMessage =
        await userAuthenticationService.loginUser(
      user: UserData(
        email: emailController.text,
        phoneNumber: phoneController.text,
      ),
    );

    // Update the current user data
    if (serverMessage['Message'] == 'User exists') {
      _isLoggedIn.value = true;
      currUser.value = UserData(
        email: emailController.text,
        phoneNumber: phoneController.text,
        userID: serverMessage['User_Id'].toString(),
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
