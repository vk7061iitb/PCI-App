import '../Objects/data_points.dart';

List<AccData> correctSamplingRate(List<AccData> accData) {
  List<AccData> correctedAccData = [];
  correctedAccData.add(accData[0]);

  for (int i = 1; i < accData.length; i++) {
    double timeDifference = accData[i]
        .accTime
        .difference(correctedAccData.last.accTime)
        .inMilliseconds
        .toDouble();

    if (timeDifference >= 15) {
      correctedAccData.add(accData[i]);
    }
  }

  return correctedAccData;
}
