import 'package:flutter/services.dart';
import 'package:pci_app/Objects/data.dart';

class PciMethodsCalls {
  static const platform = MethodChannel("pci_app/notification");

  Future<void> startNotification() async {
    try {
      var methodName = "startNotification";
      await platform.invokeMethod(methodName);
    } on PlatformException catch (e, stackTrace) {
      logger.e(e.toString());
      logger.e(stackTrace.toString());
    }
  }

  Future<void> stopNotification() async {
    try {
      var methodName = "stopNotification";
      await platform.invokeMethod(methodName);
    } on PlatformException catch (e, stackTrace) {
      logger.e(e.toString());
      logger.e(stackTrace.toString());
    }
  }
}
