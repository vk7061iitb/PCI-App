import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pciapp/Utils/get_road_color.dart';

import '../src/Presentation/Screens/MapsPage/widget/polyline_bottom_sheet.dart';

Polyline createPolyline(
    {required double pci,
    required List<LatLng> points,
    required String polylineID,
    required Map<String, dynamic> polylineOnTapData}) {
  return Polyline(
    consumeTapEvents: true,
    polylineId: PolylineId(polylineID),
    color: getRoadColor(pci),
    width: 5,
    endCap: Cap.roundCap,
    startCap: Cap.roundCap,
    jointType: JointType.round,
    points: List.from(points),
    onTap: () {
      Get.bottomSheet(
        clipBehavior: Clip.antiAlias,
        backgroundColor: Colors.white,
        PolylineBottomSheet(data: polylineOnTapData),
      );
    },
  );
}
