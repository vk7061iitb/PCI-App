import 'package:get_storage/get_storage.dart';

class UserDataController {
  final storage = GetStorage();
  Map<String, dynamic> user = {
    "ID": "",
    "email": "",
    "phone": "",
    "role": "",
    "isLoggedIn": false,
  };

  Future<Map<String, dynamic>> getUserData() async {
    user = storage.read("user") ?? {};
    return user;
  }
}
