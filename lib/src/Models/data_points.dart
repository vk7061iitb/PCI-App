/*
  This file contains the data models for the accelerometer and gyroscope data points.
  The data points are stored in the respective classes and converted to JSON format
  for sending the data to the server.
*/

import 'package:intl/intl.dart';

class AccData {
  final double xAcc;
  final double yAcc;
  final double zAcc;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime accTime;

  AccData(
      {required this.xAcc,
      required this.yAcc,
      required this.zAcc,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.accTime});

// Convert the data points to a JSON format.
// (Used to convert the object to json for sending the data to the server.)
  Map<String, dynamic> toJson() {
    return {
      'x_acc': xAcc,
      'y_acc': yAcc,
      'z_acc': zAcc,
      'Latitude': latitude,
      'Longitude': longitude,
      'Velocity': speed,
      'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(accTime),
    };
  }
}

// Not used in the current implementation.
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
