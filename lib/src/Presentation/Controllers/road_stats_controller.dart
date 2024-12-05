import 'package:get/get.dart';

class RoadStatsController extends GetxController {
  final RxBool _showPredPCI = false.obs;

  bool get showPredPCI => _showPredPCI.value;
  set showPredPCI(bool value) => _showPredPCI.value = value;
}
