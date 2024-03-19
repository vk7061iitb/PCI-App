import 'dart:math';

import 'package:flutter/foundation.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const int radius = 6371; // Radius of the earth in km
  double dLat = _degToRad(lat2 - lat1); // deg2rad below
  double dLon = _degToRad(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = radius * c; // Distance in km
  if (kDebugMode) {
    print('$distance');
  }
  return distance;
}

double _degToRad(double deg) {
  return deg * (pi / 180);
}
