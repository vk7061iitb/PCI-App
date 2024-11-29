/* 
  This controller is responsible for handling the signup process.
  It contains the following:
  - TextEditingControllers for the name, email, and phone number fields.
  - FocusNodes for the name, email, and phone number fields.
  - A GlobalKey for the signup form.
  - A RxBool to check if the user has signed up successfully.
  - A function to sign up the user.
*/

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pci_app/src/Presentation/Controllers/user_data_controller.dart';
import '../../../Objects/data.dart';
import '../../API/auth_service.dart';

class SignupController extends GetxController {
  UserAuthenticationService userAuthenticationService =
      UserAuthenticationService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final RxBool _isSignedUp = false.obs;
  final RxString _userRole = "Admin".obs;
  final UserDataController _userDataController = Get.find<UserDataController>();
  // Getters
  bool get isSignedUp => _isSignedUp.value;
  String get userRole => _userRole.value;
  // Setters
  set isSignedUp(bool value) => _isSignedUp.value = value;
  set userRole(String value) => _userRole.value = value;

  Future<void> signUp() async {
    // Validate the form
    if (!signupFormKey.currentState!.validate()) return;

    // Unfocus all the text fields
    nameFocusNode.unfocus();
    phoneFocusNode.unfocus();
    emailFocusNode.unfocus();

    // Send the user data to the server
    Map<String, dynamic> serverMessage = await userAuthenticationService.signUp(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
    );
    logger.i(serverMessage.toString());
    if (serverMessage.isEmpty) {
      _isSignedUp.value = false;
    } else {
      // successfull signup
      final user = {
        "ID": serverMessage['User_Id'].toString(),
        "email": emailController.text,
        "phone": phoneController.text,
        "role": _userRole.value,
        "isLoggedIn": true,
      };
      _userDataController.storage.write("user", user);
      _userDataController.user = user;
      _isSignedUp.value = true;
      nameController.clear();
      emailController.clear();
      phoneController.clear();
    }
  }
}
