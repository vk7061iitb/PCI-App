import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../API/auth_service.dart';
import '../../Models/user_data.dart';

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
  Rx<UserData> currUser = UserData(phoneNumber: " ", email: " ").obs;
  final RxBool _isSignedUp = false.obs;

  // Getters
  bool get isSignedUp => _isSignedUp.value;

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
    if (serverMessage.isEmpty) {
      _isSignedUp.value = false;
    } else {
      _isSignedUp.value = true;
      nameController.clear();
      emailController.clear();
      phoneController.clear();
    }
  }
}
