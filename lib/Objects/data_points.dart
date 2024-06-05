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
      'xAcc': xAcc,
      'yAcc': yAcc,
      'zAcc': zAcc,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
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
