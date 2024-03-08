import 'package:geolocator/geolocator.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Objects/data_points.dart';
import 'package:sensors_plus/sensors_plus.dart';

void getAccStream() {
  accelerometerEventStream().listen((event) {
    if (isRecordingData) {
      accDataList.add(
        AccData(
          xAcc: event.x,
          yAcc: event.y,
          zAcc: event.z,
          devicePosition: devicePosition,
          accTime: DateTime.now(),
        ),
      );

      xAcceleration = event.x;
      yAcceleration = event.y;
      zAcceleration = event.z;
    }
  });
}

void getGyroStream() {
  gyroscopeEventStream().listen((event) {
    if (isRecordingData) {
      gyroDataList.add(
        GyroData(
          xGyro: event.x,
          yGyro: event.y,
          zGyro: event.z,
          gyroTime: DateTime.now(),
        ),
      );

      xGyroscope = event.x;
      yGyroscope = event.y;
      zGyroscope = event.z;
    }
  });
}

void getPositionStream() {
  Geolocator.getPositionStream().listen((Position currentPosition) {
    devicePosition = currentPosition;
  });
}
