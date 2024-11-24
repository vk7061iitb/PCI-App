/* This controller is responsible for fetching the unsent data 
from the local database and updating the UI accordingly. */

import 'package:get/get.dart';
import '../../../Objects/data.dart';

class UnsentDataController extends GetxController {
  final RxBool _isEmpty = true.obs;
  final RxBool _refresh = false.obs;

  bool get isEmpty => _isEmpty.value;
  bool get reFresh => _refresh.value;

  // Setter
  set isEmpty(bool value) => _isEmpty.value = value;
  set reFresh(bool value) => _refresh.value = value;

  Future<List<Map<String, dynamic>>> getUnsentData() async {
    return localDatabase.queryTable('unsendDataInfo');
  }
}
