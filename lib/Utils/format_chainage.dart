String formatChainage(double distanceInMeters) {
  // Round to nearest integer to avoid floating-point issues
  int totalMeters = (distanceInMeters).round();

  // Calculate kilometers and remaining meters
  int kilometers = totalMeters ~/ 1000; // Integer division for kilometers
  int meters = totalMeters % 1000; // Remainder for meters
  String chainageTo = '$kilometers/${meters.toString().padLeft(3, '0')}';
  return chainageTo;
}

double chainageToLegth(String chainage) {
  String distance = "";
  for (int i = 0; i < chainage.length; i++) {
    var c = chainage[i];
    if (chainage[i] == '/') {
      c = '.';
    }
    distance += c;
  }
  return double.parse(distance);
}
