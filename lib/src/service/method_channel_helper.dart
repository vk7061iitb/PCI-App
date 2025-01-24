import 'package:flutter/services.dart';
import 'package:pciapp/Objects/data.dart';

class PciMethodsCalls {
  static const platform = MethodChannel("pciapp/notification");

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

  Future<void> startSending() async {
    try {
      var methodName = "startSending";
      await platform.invokeMethod(methodName);
    } on PlatformException catch (e, stackTrace) {
      logger.e(e.toString());
      logger.e(stackTrace.toString());
    }
  }

  Future<void> stopSending() async {
    try {
      var methodName = "stopSending";
      await platform.invokeMethod(methodName);
      logger.i("Stopped sending data");
    } on PlatformException catch (e, stackTrace) {
      logger.e(e.toString());
      logger.e(stackTrace.toString());
    }
  }
}
