import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Objects/data.dart';
import 'get_road_color.dart';
import 'dart:convert';

Future<void> plotDRRPLayer() async {
  String jsonString =
      await rootBundle.loadString("lib/Assets/Roads/road_drrp.geojson");
  jsonData = jsonDecode(jsonString);
  features = jsonData['features'];
  List<Polyline> polylinesToAdd = [];
  for (var element in polylines) {
    if (element.polylineId.value.contains("plotted_polyline")) {
      polylinesToAdd.add(element);
    }
  }
  polylines.clear();

  for (int i = 0; i < features.length; i++) {
    List<LatLng> points = [];
    Map<String, dynamic> feature = features[i];
    List<dynamic> coordinates = feature['geometry']['coordinates'];
    for (var data in coordinates) {
      points.add(
        LatLng(data[1], data[0]),
      );
    }

    Polyline temporaryPolyline = Polyline(
      polylineId: PolylineId('drrp_polyline$i'),
      color: getRoadColor(feature['properties']['PCI'].toString()),
      width: 5,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
      jointType: JointType.round,
      points: points,
      patterns: [
        PatternItem.dash(10),
        PatternItem.gap(10),
      ],
    );

    polylines.add(temporaryPolyline);
    polylines.addAll(polylinesToAdd);
  }
  jsonData = {};
}
