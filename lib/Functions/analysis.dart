import '../Objects/data_points.dart';

AccData average(AccData accData1, AccData accData2) {
  AccData avgAccData;
  avgAccData = AccData(
      xAcc: (accData1.xAcc + accData2.xAcc) / 2.0,
      yAcc: (accData1.yAcc + accData2.yAcc) / 2.0,
      zAcc: (accData1.zAcc + accData2.zAcc) / 2.0,
      latitude: accData2.latitude,
      longitude: accData2.longitude,
      speed: accData2.speed,
      accTime: accData2.accTime);
  return avgAccData;
}

AccData linInterpolate(AccData before, AccData after, DateTime curr) {
  double fraction = (curr.difference(before.accTime).inMicroseconds) /
      (after.accTime.difference(before.accTime).inMicroseconds).toDouble();
  double interpolatedX = before.xAcc + (after.xAcc - before.xAcc) * fraction;
  double interpolatedY = before.yAcc + (after.yAcc - before.yAcc) * fraction;
  double interpolatedZ = before.zAcc + (after.zAcc - before.zAcc) * fraction;

  AccData interpolatedData = AccData(
      xAcc: interpolatedX,
      yAcc: interpolatedY,
      zAcc: interpolatedZ,
      latitude: before.latitude,
      longitude: before.longitude,
      speed: before.speed,
      accTime: curr);

  return interpolatedData;
}

List<AccData> downsampleTo50Hz(List<AccData> accDataList) {
  List<AccData> downsampledList = [];
  if (accDataList.isEmpty) return downsampledList;

  DateTime startTime = accDataList.first.accTime;
  DateTime currentTime = startTime.add(
    const Duration(microseconds: 20000),
  );
  int interval = 20000; // in microseconds

  downsampledList.add(accDataList[0]);

  for (int i = 1; i < accDataList.length - 1; i++) {
    AccData before = accDataList[0];
    AccData after;

    if (accDataList[i].accTime.isBefore(currentTime) ||
        accDataList[i].accTime.isAtSameMomentAs(currentTime)) {
      before = average(accDataList[i], accDataList[i - 1]);
    }
    if (accDataList[i + 1].accTime.isAfter(currentTime) ||
        accDataList[i + 1].accTime.isAtSameMomentAs(currentTime)) {
      after = accDataList[i + 1];

      if (accDataList[i].accTime.isAfter(currentTime) &&
          accDataList[i + 1].accTime.isAfter(currentTime)) {
        AccData genData =
            linInterpolate(downsampledList.last, after, currentTime);
        downsampledList.add(
          genData,
        );
      } else {
        // Finding the interpolated data
        AccData interPolatedAccData =
            linInterpolate(before, after, currentTime);
        downsampledList.add(interPolatedAccData);
      }

      currentTime = currentTime.add(Duration(microseconds: interval));
    }
  }

  return downsampledList;
}
