import 'package:intl/intl.dart';

class AccData {
  final double xAcc;
  final double yAcc;
  final double zAcc;
  final double latitude;
  final double longitude;
  final double speed;
  DateTime accTime;

  AccData(
      {required this.xAcc,
      required this.yAcc,
      required this.zAcc,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.accTime});

  Map<String, dynamic> toJson() {
    return {
      'x_acc': xAcc,
      'y_acc': yAcc,
      'z_acc': zAcc,
      'Latitude': latitude,
      'Longitude': longitude,
      'speed': speed,
      'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(accTime),
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
