import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Functions/get_road_color.dart';
import 'package:pci_app/Functions/vel_to_pci.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Models/stats_data.dart';
import '../src/Presentation/Screens/MapsPage/widget/polyline_bottom_sheet.dart';

/// Plots a map in an isolate with the given data.
///
/// This function runs asynchronously and performs the map plotting
/// operation in a separate isolate to avoid blocking the main thread.
///
Future<void> plotMapIsolate(Map<String, dynamic> isolateData) async {
  logger.d('Isolate started');
  final SendPort sendPort = isolateData['sendPort'];
  final List<List<Map<String, dynamic>>> roadOutputData =
      isolateData['roadOutputData'];
  final bool showPCIlabel = isolateData['showPCIlabel'];
  final List<RoadStats> roadStats = [];
  final Set<Polyline> pciPolylines = <Polyline>{};
  final Set<Polyline> drrpPolylines =
      isolateData['drrpPolylines'] as Set<Polyline>;
  final List<Map<String, dynamic>> selectedRoads = isolateData['selectedRoads'];
  var maxLat = const LatLng(0, 0);
  var minLat = const LatLng(0, 0);

  try {
    // for each seleced journey
    for (int i = 0; i < roadOutputData.length; i++) {
      var roadQuery = roadOutputData[i];
      // for each road in a journey
      for (int j = 0; j < roadQuery.length; j++) {
        var road = roadQuery[j];
        String roadName = road["roadName"];
        List<dynamic> labels = jsonDecode(road["labels"]);
        dynamic roadStatistics = jsonDecode(road["stats"]);

        minLat = (minLat.latitude == 0)
            ? LatLng(labels[0]['latitude'], labels[0]['longitude'])
            : minLat;

        Map<String, dynamic> stats = {};
        var lastVelPredPCI = 0.0;
        var velPredPCI = -1.0;

        /// Add the labels and polylines
        for (int k = 1; k < labels.length; k++) {
          maxLat = LatLng(labels[k]['latitude'], labels[k]['longitude']);
          double avgVelocity =
              (labels[k]['velocity'] + labels[k - 1]['velocity']) / 2;
          avgVelocity *= 3.6; // convert m/s to kmph
          double prediction = max(
            double.parse(labels[k]['prediction'].toString()),
            double.parse(labels[k - 1]['prediction'].toString()),
          );
          double velocityPCI = velocityToPCI(avgVelocity);
          var currentRoad = selectedRoads[i];

          /// vel pred statistics
          lastVelPredPCI = velPredPCI;
          velPredPCI = velocityToPCI(avgVelocity);
          double dist = Geolocator.distanceBetween(
            labels[k - 1]['latitude'],
            labels[k - 1]['longitude'],
            labels[k]['latitude'],
            labels[k]['longitude'],
          );
          // Check if the key exists in the stats map, if not, initialize it
          if (!stats.containsKey(velPredPCI.toString())) {
            stats[velPredPCI.toString()] = {
              'avg_velocity': 0.0,
              'distance_travelled': 0.0,
              'number_of_segments': 0,
            };
          }
          stats[velPredPCI.toString()]['avg_velocity'] = (((avgVelocity / 3.6) +
                  stats[velPredPCI.toString()]['avg_velocity']) /
              2);
          stats[velPredPCI.toString()]['distance_travelled'] += dist;
          if ((velPredPCI != lastVelPredPCI)) {
            stats[velPredPCI.toString()]['number_of_segments'] += 1;
          }

          ///
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

        // Adding the statistictics - both prediction based and velocity based
        List<RoadStatsData> velStatsList = [];
        for (var key in stats.keys) {
          // add to velPredList
          velStatsList.add(
            RoadStatsData(
              pci: double.parse(key).toStringAsFixed(0),
              avgVelocity: stats[key]['avg_velocity'].toString(),
              distanceTravelled: stats[key]['distance_travelled'].toString(),
              numberOfSegments: stats[key]['number_of_segments'].toString(),
            ),
          );
        }
        List<RoadStatsData> predStatsList = [];
        for (int i = 1; i <= 5; i++) {
          // Key represents each PCI value in the stats, which are only 1-5
          String key = "$i";
          predStatsList.add(
            RoadStatsData(
              pci: double.parse(key).toStringAsFixed(0),
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
            predStats: predStatsList,
            velStats: velStatsList,
          ),
        );
        logger.d(stats.toString());
      }
    }
    pciPolylines.addAll(drrpPolylines);
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
