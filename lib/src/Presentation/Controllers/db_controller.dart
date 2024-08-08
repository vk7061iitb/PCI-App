import 'package:get/get.dart';

class DataBaseController extends GetxController {
  final Rx<String> _dbMessage = ''.obs;

  // Getters
  String get dbMessage => _dbMessage.value;
}
