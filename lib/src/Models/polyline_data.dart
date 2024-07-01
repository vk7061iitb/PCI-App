// This class is used to store the polyline that'll be plotted on the map.(Output of the ML model)

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineData {
  Polyline polyline;
  int polylineIndex;
  Properties polylineAttributes;

  PolylineData(
      {required this.polyline,
      required this.polylineIndex,
      required this.polylineAttributes});
}

class Properties {
  List<String> attributeKeys;
  List<dynamic> attributeValues;

  Properties({required this.attributeKeys, required this.attributeValues});
}
