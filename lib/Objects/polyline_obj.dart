import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylinObj {
  Polyline polyline;
  int polylineIndex;
  List<Properties> properties;

  PolylinObj(
      {required this.polyline,
      required this.polylineIndex,
      required this.properties});
}

class Properties {
  String key;
  String value;

  Properties({required this.key, required this.value});
}
