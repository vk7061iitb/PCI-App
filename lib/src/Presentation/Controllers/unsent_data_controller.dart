import 'package:get/get.dart';
import '../../../Objects/data.dart';

class UnsentDataController extends GetxController {
  late final Rx<Future<List<Map<String, dynamic>>>> _unsentData;
  final RxBool _isEmpty = true.obs;

  // Getter
  Future<List<Map<String, dynamic>>> get unsentData => _unsentData.value;
  bool get isEmpty => _isEmpty.value;

  Future<List<Map<String, dynamic>>> getUnsentData() async {
    return localDatabase.queryTable('unsendDataInfo');
  }

  @override
  void onInit() {
    super.onInit();
    _unsentData.value = getUnsentData();
  }
}
