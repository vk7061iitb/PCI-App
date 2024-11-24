import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pci_app/src/Models/user_data.dart';
import '../../../Objects/data.dart';

class UserDataController extends GetxController {
  final Rx<UserData> _userData = UserData(
    userID: 'null',
    email: 'null',
    userRole: 'null',
    phoneNumber: 'null',
  ).obs;

  // getter
  UserData get userData => _userData.value;
  // setter
  set userData(UserData value) => _userData.value = value;

  Future<void> getUserData() async {
    _userData.value = await localDatabase.queryUserData();
  }

  @override
  void onInit() async {
    try {
      _userData.value = await localDatabase.queryUserData();
    } catch (e) {
      debugPrint('Error: $e');
    }
    super.onInit();
  }
}
