import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Utils/get_road_color.dart';
import 'package:pci_app/Utils/set_road_stats.dart';
import 'package:pci_app/Utils/vel_to_pci.dart';
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
  final List<SegStats> segStats = [];
  final Set<Polyline> pciPolylines = <Polyline>{};
  final Set<Polyline> drrpPolylines =
      isolateData['drrpPolylines'] as Set<Polyline>;
  final List<Map<String, dynamic>> selectedRoads = isolateData['selectedRoads'];
  LatLng maxLat = const LatLng(0, 0);
  LatLng minLat = const LatLng(0, 0);
  logger.i(roadOutputData);
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
        double firstPointPCI = 0.0;
        double secondPointPCI = 0.0;
        double distance = 0.0;
        // Initialize first point and prediction
        double totalD = 0.0;
        double disP = 0.0;
        LatLng point2 = LatLng(labels[0]['latitude'], labels[0]['longitude']);
        LatLng point1 = LatLng(0, 0);
        // Process road segments
        for (int k = 0; k < labels.length - 1; k++) {
          maxLat =
              LatLng(labels[k + 1]['latitude'], labels[k + 1]['longitude']);
          var firstLabel = labels[k];
          var secondLabel = labels[k + 1];
          LatLng firstPoint =
              LatLng(firstLabel['latitude'], firstLabel['longitude']);
          LatLng secondPoint =
              LatLng(secondLabel['latitude'], secondLabel['longitude']);
          firstPointPCI = secondPointPCI;
          //
          double firstValue = (firstLabel['prediction'] as num).toDouble();
          double secondValue = (secondLabel['prediction'] as num).toDouble();
          double velPredPCI = min(velocityToPCI(3.6 * secondLabel['velocity']),
              velocityToPCI(3.6 * firstLabel['velocity']));
          secondPointPCI = showPCIlabel
              ? min(firstValue, secondValue)
              : velPredPCI.toDouble();

          // Calculate distance between points
          double d = Geolocator.distanceBetween(
            firstPoint.latitude,
            firstPoint.longitude,
            secondPoint.latitude,
            secondPoint.longitude,
          ); // in meters

          velocities.add(firstLabel['velocity']);
          points.add(firstPoint);
          totalD += d;

          // Create polyline when prediction changes
          if (firstPointPCI != secondPointPCI) {
            point1 = point2;
            point2 = firstPoint;
            disP += distance;
            Map<String, dynamic> polylineOnTapData = {
              'roadName': roadName,
              'filename': currJourney['filename'],
              'time': currJourney['time'],
              'pci': firstPointPCI,
              'avg_vel': 3.6 * avg(velocities),
              'distance': distance / 1000,
              'start': (totalD - distance) / 1000,
              'end': totalD / 1000,
              'latlngs': [point1, point2]
            };

            Polyline polyline = Polyline(
              consumeTapEvents: true,
              polylineId: PolylineId("Polyline$i$j$k"),
              color: getRoadColor(firstPointPCI),
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
            points = [firstPoint];
            velocities = [firstLabel['velocity']];
            distance = 0;
          }
          distance += d;
        }

        if (points.length == 1) {
          disP += distance;
          point1 = point2;
          point2 = LatLng(labels.last['latitude'], labels.last['longitude']);
          // create a polyline of last segment
          Map<String, dynamic> polylineOnTapData = {
            'roadName': roadName,
            'filename': currJourney['filename'],
            'time': currJourney['time'],
            'pci': secondPointPCI,
            'avg_vel': 3.6 * avg(velocities),
            'distance': distance / 1000,
            'start': (totalD - distance) / 1000,
            'end': totalD / 1000,
            'latlngs': [point1, point2]
          };
          Polyline polyline = Polyline(
            consumeTapEvents: true,
            polylineId: PolylineId("Polyline$i$j${labels.length - 1}"),
            color: getRoadColor(secondPointPCI),
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
          disP += distance;
          point1 = point2;
          point2 = LatLng(labels.last['latitude'], labels.last['longitude']);
          // add the last point in the points and create a new polyline
          points.add(LatLng(labels.last['latitude'], labels.last['longitude']));
          velocities.add(labels.last['velocity']);

          Map<String, dynamic> polylineOnTapData = {
            'roadName': roadName,
            'filename': currJourney['filename'],
            'time': currJourney['time'],
            'pci': secondPointPCI,
            'avg_vel': 3.6 * avg(velocities),
            'distance': distance / 1000,
            'start': (totalD - distance) / 1000,
            'end': totalD / 1000,
            'latlngs': [point1, point2]
          };
          Polyline polyline = Polyline(
            consumeTapEvents: true,
            polylineId: PolylineId("Polyline$i$j${labels.length - 1}"),
            color: getRoadColor(secondPointPCI),
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
        logger.i("Distance(Polylines): $disP");
      }

      /// Set road statistics
      final completeStats = setRoadStatistics(
        journeyData: roadQuery,
        filename: currJourney['filename'],
      );
      for (var stats in completeStats[0]) {
        roadStats.add(stats);
      }
      for (var stats in completeStats[1]) {
        segStats.add(stats);
      }
    }
    pciPolylines.addAll(drrpPolylines);
    sendPort.send({
      'roadStats': roadStats,
      'segStats': segStats,
      'pciPolylines': pciPolylines,
      'maxLat': maxLat,
      'minLat': minLat,
    });
  } catch (e, stackTrace) {
    logger.e(e.toString());
    logger.d(stackTrace);
  }
  logger.d('Isolate ended');
}
