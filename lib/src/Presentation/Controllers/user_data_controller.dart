import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserDataController extends GetxController {
  final storage = GetStorage();
  Map<String, dynamic> user = {
    "ID": "",
    "email": "",
    "phone": "",
    "role": "",
    "isLoggedIn": false,
  };

  Future<void> getUserData() async {
    user = storage.read("user") ?? {};
  }

  @override
  void onInit() {
    getUserData();
    super.onInit();
  }
}
