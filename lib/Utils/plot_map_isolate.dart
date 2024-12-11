import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Utils/get_road_color.dart';
import 'package:pci_app/Utils/set_road_stats.dart';
import 'package:pci_app/Functions/vel_to_pci.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Models/stats_data.dart';
import '../src/Presentation/Screens/MapsPage/widget/polyline_bottom_sheet.dart';
import '../Functions/avg.dart';

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
  LatLng maxLat = const LatLng(0, 0);
  LatLng minLat = const LatLng(0, 0);

  try {
    /// Process each selected journey
    for (int i = 0; i < roadOutputData.length; i++) {
      var roadQuery = roadOutputData[i];
      var currJourney = selectedRoads[i];

      /// Process each road in a journey
      for (int j = 0; j < roadQuery.length; j++) {
        /// each journey can have multiple roads, therefore running loop for each road
        var road = roadQuery[j];
        List<dynamic> labels;
        String roadName = road["roadName"];
        try {
          labels = jsonDecode(road["labels"]);
          if (labels.isEmpty) continue;
        } catch (e) {
          logger.e('Error parsing labels: $e');
          continue;
        }
        minLat = (minLat.latitude == 0)
            ? LatLng(labels[0]['latitude'], labels[0]['longitude'])
            : minLat;

        List<LatLng> points = [];
        List<double> velocities = [];
        double distance = 0.0;

        // Initialize first point and prediction
        var firstLabel = labels[0];

        double nxtPred = showPCIlabel
            ? double.parse(firstLabel['prediction'].toString())
            : velocityToPCI(3.6 * firstLabel['velocity']);

        LatLng point2 = LatLng(labels[0]['latitude'], labels[0]['longitude']);
        LatLng point1 = LatLng(0, 0);
        // Process road segments
        for (int k = 0; k < labels.length - 1; k++) {
          maxLat =
              LatLng(labels[k + 1]['latitude'], labels[k + 1]['longitude']);

          var currLabel = labels[k];
          var nxtLabel = labels[k + 1];

          // Calculate current prediction
          double currPred = nxtPred;
          nxtPred = showPCIlabel
              ? min(double.parse(currLabel['prediction'].toString()),
                  double.parse(nxtLabel['prediction'].toString()))
              : velocityToPCI(
                  3.6 * avg([nxtLabel['velocity'], currLabel['velocity']]));

          // Calculate previous point and current point
          LatLng currPoint =
              LatLng(currLabel['latitude'], currLabel['longitude']);
          LatLng nxtPoint = LatLng(nxtLabel['latitude'], nxtLabel['longitude']);

          // Calculate distance between points
          double segmentDistance = Geolocator.distanceBetween(
              currPoint.latitude,
              currPoint.longitude,
              nxtPoint.latitude,
              nxtPoint.longitude);

          points.add(currPoint);
          velocities.add(currLabel['velocity']);

          // Create polyline when prediction changes
          if (currPred != nxtPred) {
            point1 = point2;
            point2 = currPoint;
            Map<String, dynamic> polylineOnTapData = {
              'roadName': roadName,
              'filename': currJourney['filename'],
              'time': currJourney['time'],
              'pci': currPred,
              'avg_vel': 3.6 * avg(velocities),
              'distance': distance / 1000,
              'latlngs': [point1, point2]
            };

            Polyline polyline = Polyline(
              consumeTapEvents: true,
              polylineId: PolylineId("Polyline$i$j$k"),
              color: getRoadColor(currPred),
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
            pciPolylines.add(polyline);
            // Reset for next segment
            points = [currPoint];
            velocities = [currLabel['velocity']];
          }
          distance += segmentDistance;
        }

        if (points.length == 1) {
          point1 = point2;
          point2 = LatLng(labels.last['latitude'], labels.last['longitude']);
          // create a polyline of last segment
          Map<String, dynamic> polylineOnTapData = {
            'roadName': roadName,
            'filename': currJourney['filename'],
            'time': currJourney['time'],
            'pci': nxtPred,
            'avg_vel': 3.6 * avg(velocities),
            'distance': distance / 1000,
            'latlngs': [point1, point2]
          };
          Polyline polyline = Polyline(
            consumeTapEvents: true,
            polylineId: PolylineId("Polyline$i$j${labels.length - 1}"),
            color: getRoadColor(nxtPred),
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
          pciPolylines.add(polyline);
        } else {
          point1 = point2;
          point2 = LatLng(labels.last['latitude'], labels.last['longitude']);
          // add the last point in the points and create a new polyline
          points.add(LatLng(labels.last['latitude'], labels.last['longitude']));
          velocities.add(labels.last['velocity']);

          Map<String, dynamic> polylineOnTapData = {
            'roadName': roadName,
            'filename': currJourney['filename'],
            'time': currJourney['time'],
            'pci': nxtPred,
            'avg_vel': 3.6 * avg(velocities),
            'distance': distance / 1000,
            'latlngs': [point1, point2]
          };
          Polyline polyline = Polyline(
            consumeTapEvents: true,
            polylineId: PolylineId("Polyline$i$j${labels.length - 1}"),
            color: getRoadColor(nxtPred),
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
          pciPolylines.add(polyline);
        }
      }

      /// Set road statistics
      for (var stats in setRoadStatistics(journeyData: roadQuery)) {
        roadStats.add(stats);
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
