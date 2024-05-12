import 'package:geolocator/geolocator.dart';

class AccData {
  final double xAcc;
  final double yAcc;
  final double zAcc;
  Position devicePosition;
  DateTime accTime;

  AccData(
      {required this.xAcc,
      required this.yAcc,
      required this.zAcc,
      required this.devicePosition,
      required this.accTime});

  Map<String, dynamic> toJson() {
    return {
      'xAcc': xAcc,
      'yAcc': yAcc,
      'zAcc': zAcc,
      'latitude': devicePosition.latitude,
      'longitude': devicePosition.longitude,
      'accTime': accTime.toIso8601String()
    };
  }
}

class GyroData {
  final double xGyro;
  final double yGyro;
  final double zGyro;
  DateTime gyroTime;

  GyroData(
      {required this.xGyro,
      required this.yGyro,
      required this.zGyro,
      required this.gyroTime});
}
