import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLngBounds calculateBounds(LatLng min, LatLng max) {
  double minLat = min.latitude;
  double minLng = min.longitude;
  double maxLat = max.latitude;
  double maxLng = max.longitude;

  if (minLat > maxLat) {
    double temp = minLat;
    minLat = maxLat;
    maxLat = temp;
  }

  if (minLng > maxLng) {
    double temp = minLng;
    minLng = maxLng;
    maxLng = temp;
  }

  LatLngBounds bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
  return bounds;
}
