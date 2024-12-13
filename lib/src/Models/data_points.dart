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
  final int roadType;
  final int bnb; // Break-NoBreak = 0-> NO, 1-> YES
  final DateTime accTime;

  AccData(
      {required this.xAcc,
      required this.yAcc,
      required this.zAcc,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.roadType,
      required this.bnb,
      required this.accTime});

// Convert the data points to a JSON format.
// (Used to convert the object to json for sending the data to the server.)
  Map<String, dynamic> toJson() {
    return {
      'x_acc': double.parse(xAcc.toStringAsFixed(4)),
      'y_acc': double.parse(yAcc.toStringAsFixed(4)),
      'z_acc': double.parse(zAcc.toStringAsFixed(4)),
      'Latitude': latitude,
      'Longitude': longitude,
      'Velocity': double.parse(speed.toStringAsFixed(4)),
      'RoadType': roadType,
      'bnb': bnb,
      'Time': DateFormat('yyyy-MM-dd HH:mm:ss:S').format(accTime),
    };
  }
}
