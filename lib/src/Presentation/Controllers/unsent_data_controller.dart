import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';
import 'package:pci_app/src/service/method_channel_helper.dart';
import '../../../Objects/data.dart';
import '../Widgets/snackbar.dart';

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

  Future<void> resubmitData(int id, Map<String, dynamic> info) async {
    PciMethodsCalls pciMethodsCalls = PciMethodsCalls();
    ResponseController responseController = Get.find();
    try {
      List<Map<String, dynamic>> unsentData =
          await localDatabase.queryUnsentData(id);
      await pciMethodsCalls.startSending();
      int res = await responseController.reSendData(
        unsentData: unsentData,
        filename: info['filename'],
        roadType: info['roadType'],
        vehicleType: info['vehicleType'],
        time: info['time'],
      );
      logger.i('Response Code: $res');
      if (res == 200) {
        Get.showSnackbar(
          customGetSnackBar(
            "Submission Successful",
            "Data sent successfully",
            Icons.check_circle_outline,
          ),
        );
        await Future.wait([
          localDatabase.deleteUnsentData(id),
          localDatabase.deleteUnsentDataInfo(id),
        ]);
      } else {
        Get.showSnackbar(
          customGetSnackBar(
            "Submission Failed",
            "Failed to send data",
            Icons.error_outline,
          ),
        );
      }
    } catch (e) {
      logger.e(e.toString());
      Get.showSnackbar(
        customGetSnackBar(
          "Error",
          e.toString(),
          Icons.error_outline,
        ),
      );
    } finally {
      await pciMethodsCalls.stopSending();
    }
  }
}
