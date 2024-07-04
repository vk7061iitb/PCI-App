import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Objects/data.dart';
import '../../Models/data_points.dart';

class ResponseController extends GetxController {
  final RxString _dbMessage = ''.obs;
  final RxString _dropdownValue = vehicleType.first.obs;
  final Rx<TextEditingController> _fileNameController =
      TextEditingController().obs;
  final Rx<GlobalKey<FormState>> _formKey = GlobalKey<FormState>().obs;
  final RxBool _isSaveLocally = true.obs;
  final RxBool _savingData = false.obs;
  final RxString _serverMessage = ''.obs;

  String get dropdownValue => _dropdownValue.value;
  String get dbMessage => _dbMessage.value;
  String get serverMessage => _serverMessage.value;
  bool get isSaveLocally => _isSaveLocally.value;
  bool get savingData => _savingData.value;
  GlobalKey<FormState> get formKey => _formKey.value;
  TextEditingController get fileNameController => _fileNameController.value;

  set dropdownValue(String value) => _dropdownValue.value = value;
  set isSaveLocally(bool value) => _isSaveLocally.value = value;
  set savingData(bool value) => _savingData.value = value;
  set dbMessage(String value) => _dbMessage.value = value;
  set serverMessage(String value) => _serverMessage.value = value;

  Future<void> saveData(List<AccData> accData) async {
    if (_isSaveLocally.isTrue) {
      await localDatabase.exportToCSV(
          _fileNameController.value.text, _dropdownValue.value);
    }
  }
}
