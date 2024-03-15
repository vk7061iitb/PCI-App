import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylinObj {
  Polyline polyline;
  int polylineIndex;
  Properties properties;

  PolylinObj(
      {required this.polyline,
      required this.polylineIndex,
      required this.properties});
}

class Properties {
  List<String> keyList;
  List<dynamic> valuesList;

  Properties({required this.keyList, required this.valuesList});
}
