import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Functions/get_road_color.dart';
import 'package:pci_app/Functions/vel_to_pci.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Models/stats_data.dart';
import '../src/Presentation/Screens/MapsPage/widget/polyline_bottom_sheet.dart';

void plotMapIsolate(Map<String, dynamic> data) async {
  logger.d('Isolate started');
  final SendPort sendPort = data['sendPort'];
  final List<List<Map<String, dynamic>>> roadOutputData =
      data['roadOutputData'];
  final bool showPCIlabel = data['showPCIlabel'];
  final List<RoadStats> roadStats = [];
  final Set<Polyline> pciPolylines = <Polyline>{};
  final List<Map<String, dynamic>> selectedRoads = data['selectedRoads'];
  var maxLat = const LatLng(0, 0);
  var minLat = const LatLng(0, 0);

  try {
    for (int i = 0; i < roadOutputData.length; i++) {
      var roadQuery = roadOutputData[i];
      for (int j = 0; j < roadQuery.length; j++) {
        var road = roadQuery[j];
        String roadName = road["roadName"];
        List<dynamic> labels = jsonDecode(road["labels"]);
        dynamic roadStatistics = jsonDecode(road["stats"]);

        minLat = (minLat.latitude == 0)
            ? LatLng(labels[0]['latitude'], labels[0]['longitude'])
            : minLat;

        // Adding the stats
        List<RoadStatsData> roadStatsList = [];
        for (int i = 1; i <= 5; i++) {
          // Key represents each PCI value in the stats, which are only 1-5
          String key = "$i";
          roadStatsList.add(
            RoadStatsData(
              pci: key,
              avgVelocity: roadStatistics[key]['avg_velocity'].toString(),
              distanceTravelled:
                  roadStatistics[key]['distance_travelled'].toString(),
              numberOfSegments:
                  roadStatistics[key]['number_of_segments'].toString(),
            ),
          );
        }
        roadStats.add(
          RoadStats(
            roadName: roadName,
            roadStatsData: roadStatsList,
          ),
        );
        // Adding the labels and polylines
        for (int k = 1; k < labels.length; k++) {
          maxLat = LatLng(labels[k]['latitude'], labels[k]['longitude']);
          double avgVelocity =
              (labels[k]['velocity'] + labels[k - 1]['velocity']) / 2;
          avgVelocity *= 3.6; // convert m/s to kmph
          double prediction = max(
              double.parse(labels[k]['prediction'].toString()),
              double.parse(labels[k - 1]['prediction'].toString()));
          double velocityPCI = velocityToPCI(avgVelocity);
          var currentRoad = selectedRoads[i];
          // Add the polyline
          Polyline tempPolylne = Polyline(
            consumeTapEvents: true,
            polylineId: PolylineId("$roadName$i$j$k"),
            color: showPCIlabel
                ? getRoadColor(prediction)
                : getVelocityColor(avgVelocity),
            width: 5,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            jointType: JointType.round,
            points: [
              LatLng(labels[k - 1]['latitude'], labels[k - 1]['longitude']),
              LatLng(labels[k]['latitude'], labels[k]['longitude']),
            ],
            onTap: () {
              Map<String, dynamic> polylineOnTapData = {
                'roadName': roadName,
                'filename': currentRoad['filename'],
                'time': currentRoad['time'],
                'pci_pred': prediction,
                'vel_pred': velocityPCI,
                'avg_vel': avgVelocity,
              };
              Get.bottomSheet(
                clipBehavior: Clip.antiAlias,
                backgroundColor: Colors.white,
                PolylineBottomSheet(data: polylineOnTapData),
              );
            },
          );
          pciPolylines.add(tempPolylne);
        }
      }
    }
    sendPort.send({
      'roadStats': roadStats,
      'pciPolylines': pciPolylines,
      'maxLat': maxLat,
      'minLat': minLat,
    });
  } catch (e) {
    logger.e(e.toString());
  }
  logger.d('Isolate ended');
}
