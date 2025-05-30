import '../src/Models/data_points.dart';

/// Downsamples a list of accelerometer data to 50Hz.
///
/// This function takes a list of `AccData` objects and returns a new list
/// of `AccData` objects downsampled to 50Hz. This is achieved by selecting
/// data points at 20ms intervals (corresponding to 50Hz) starting from the
/// first data point in the provided list.
///
/// - Parameters:
///   - accDataList: A list of `AccData` objects representing the accelerometer data.
/// - Returns: A list of `AccData` objects downsampled to 50Hz.

List<AccData> downsampleTo50Hz(List<AccData> accDataList) {
  List<AccData> downsampledList = [];
  if (accDataList.isEmpty) return downsampledList;
  DateTime startTime = accDataList.first.accTime;
  DateTime nextSampleTime = startTime.add(
    const Duration(microseconds: 20000),
  );
  int interval = 20000; // in microseconds

  downsampledList.add(accDataList[0]);

  for (int i = 1; i < accDataList.length - 1; i++) {
    AccData before = accDataList[0];
    AccData after;
    if (accDataList[i].accTime.isBefore(nextSampleTime) ||
        accDataList[i].accTime.isAtSameMomentAs(nextSampleTime)) {
      before = average(accDataList[i], accDataList[i - 1]);
    }
    if (accDataList[i + 1].accTime.isAfter(nextSampleTime) ||
        accDataList[i + 1].accTime.isAtSameMomentAs(nextSampleTime)) {
      after = accDataList[i + 1];

      if (accDataList[i].accTime.isAfter(nextSampleTime) &&
          accDataList[i + 1].accTime.isAfter(nextSampleTime)) {
        AccData genData =
            linInterpolate(downsampledList.last, after, nextSampleTime);
        downsampledList.add(
          genData,
        );
      } else {
        // Finding the interpolated data
        AccData interPolatedAccData =
            linInterpolate(before, after, nextSampleTime);
        downsampledList.add(interPolatedAccData);
      }
      nextSampleTime = nextSampleTime.add(Duration(microseconds: interval));
    }
  }
  return downsampledList;
}

/// Averages two `AccData` objects.
/// - Parameters:
///  - accData1: The first `AccData` object.
/// - accData2: The second `AccData` object.
/// - Returns: An `AccData` object representing the average of the two input objects.
/// - Note: The `latitude`, `longitude`, `speed`, and `accTime` fields of the returned object are taken from `accData2`.
/// - Note: The `xAcc`, `yAcc`, and `zAcc` fields of the returned object are the average of the corresponding fields in `accData1` and `accData2`.
AccData average(AccData accData1, AccData accData2) {
  AccData avgAccData;
  double avgX = (accData1.xAcc + accData2.xAcc) / 2.0;
  double avgY = (accData1.yAcc + accData2.yAcc) / 2.0;
  double avgZ = (accData1.zAcc + accData2.zAcc) / 2.0;
  double speed = accData2.speed;
  // round them to 4 decimal places
  avgX = double.parse(avgX.toStringAsFixed(4));
  avgY = double.parse(avgY.toStringAsFixed(4));
  avgZ = double.parse(avgZ.toStringAsFixed(4));
  speed = double.parse(speed.toStringAsFixed(4));
  String remarks = "";
  if (accData1.remarks.isNotEmpty) {
    remarks = accData1.remarks;
  } else if (accData2.remarks.isNotEmpty) {
    remarks = accData2.remarks;
  }
  avgAccData = AccData(
    xAcc: avgX,
    yAcc: avgY,
    zAcc: avgZ,
    latitude: accData2.latitude,
    longitude: accData2.longitude,
    speed: speed,
    roadType: accData2.roadType,
    remarks: remarks,
    accTime: accData2.accTime,
  );
  return avgAccData;
}

/// Linearly interpolates between two `AccData` objects.
/// - Parameters:
///  - before: The `AccData` object before the interpolation point.
/// - after: The `AccData` object after the interpolation point.
/// - curr: The interpolation point. This is a `DateTime` object.
/// - Returns: An `AccData` object representing the interpolated data at the interpolation point.
/// - Note: The `latitude`, `longitude`, `speed`, and `accTime` fields of the returned object are taken from `after`.
AccData linInterpolate(AccData before, AccData after, DateTime curr) {
  double fraction = (curr.difference(before.accTime).inMicroseconds) /
      (after.accTime.difference(before.accTime).inMicroseconds).toDouble();
  double interpolatedX = before.xAcc + (after.xAcc - before.xAcc) * fraction;
  double interpolatedY = before.yAcc + (after.yAcc - before.yAcc) * fraction;
  double interpolatedZ = before.zAcc + (after.zAcc - before.zAcc) * fraction;
  double speed = after.speed;
  // round them to 4 decimal places
  interpolatedX = double.parse(interpolatedX.toStringAsFixed(4));
  interpolatedY = double.parse(interpolatedY.toStringAsFixed(4));
  interpolatedZ = double.parse(interpolatedZ.toStringAsFixed(4));
  speed = double.parse(speed.toStringAsFixed(4));
  String remarks = "";
  if (before.remarks.isNotEmpty) {
    remarks = before.remarks;
  } else if (after.remarks.isNotEmpty) {
    remarks = after.remarks;
  }
  AccData interpolatedData = AccData(
    xAcc: interpolatedX,
    yAcc: interpolatedY,
    zAcc: interpolatedZ,
    latitude: after.latitude,
    longitude: after.longitude,
    speed: speed,
    roadType: after.roadType,
    remarks: remarks,
    accTime: curr,
  );

  return interpolatedData;
}
