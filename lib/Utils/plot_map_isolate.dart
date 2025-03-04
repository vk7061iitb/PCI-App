import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'get_road_color.dart';
import 'set_road_stats.dart';
import 'vel_to_pci.dart';
import '../Objects/data.dart';
import '../src/Models/stats_data.dart';
import '../src/Presentation/Screens/MapsPage/widget/polyline_bottom_sheet.dart';
import '../Functions/avg.dart';

/// Plots a map in an isolate with the given data.
Future<void> plotMapIsolate(Map<String, dynamic> isolateData) async {
  logger.d('Isolate started');
  final SendPort sendPort = isolateData['sendPort'];
  final List<List<Map<String, dynamic>>> roadOutputData =
      isolateData['roadOutputData'];
  final bool showPCIlabel = isolateData['showPCIlabel'];

  final Set<Polyline> pciPolylines = <Polyline>{};
  final Set<Polyline> drrpPolylines =
      isolateData['drrpPolylines'] as Set<Polyline>;
  final List<Map<String, dynamic>> selectedRoads = isolateData['selectedRoads'];
  final List<List<RoadStats>> roadStats = [];
  final List<List<SegStats>> segStats = [];
  double minimumLat = 0, minimumLon = 0, maximumLat = 0, maximumLon = 0;

  try {
    /// Process each selected journey
    for (int i = 0; i < roadOutputData.length; i++) {
      var roadQuery = roadOutputData[i];
      var currJourney = selectedRoads[i];
      List<RoadStats> rs = [];
      List<SegStats> ss = [];

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
        List<LatLng> points = [];
        List<double> velocities = [];
        double firstPointPCI = 0.0;
        double secondPointPCI = 0.0;
        double distance = 0.0;
        double time = 0.0;
        double totalD = 0.0;
        double disP = 0.0;
        // points to map the end of a segment
        LatLng point2 = LatLng(labels[0]['latitude'], labels[0]['longitude']);
        LatLng point1 = LatLng(0, 0);
        // Process road segments
        for (int k = 0; k < labels.length - 1; k++) {
          if (k == 0) {
            minimumLat = labels[0]['latitude'];
            minimumLon = labels[0]['longitude'];
            maximumLat = labels[0]['latitude'];
            maximumLon = labels[0]['longitude'];
          }
          minimumLat = min(minimumLat, labels[k]['latitude']);
          minimumLon = min(minimumLon, labels[k]['longitude']);
          maximumLat = max(maximumLat, labels[k]['latitude']);
          maximumLon = max(maximumLon, labels[k]['longitude']);

          var firstLabel = labels[k];
          var secondLabel = labels[k + 1];

          LatLng firstPoint =
              LatLng(firstLabel['latitude'], firstLabel['longitude']);
          LatLng secondPoint =
              LatLng(secondLabel['latitude'], secondLabel['longitude']);
          double firstValue = (firstLabel['prediction'] as num).toDouble();
          double secondValue = (secondLabel['prediction'] as num).toDouble();
          double velPredPCI = min(
              velocityToPCI(velocityKmph: 3.6 * secondLabel['velocity']),
              velocityToPCI(velocityKmph: 3.6 * firstLabel['velocity']));
          // Calculate distance between points
          double d = Geolocator.distanceBetween(
            firstPoint.latitude,
            firstPoint.longitude,
            secondPoint.latitude,
            secondPoint.longitude,
          ); // in meters
          // calculate the time
          double t = (d /
              avg([
                double.parse(firstLabel['velocity'].toString()),
                double.parse(secondLabel['velocity'].toString())
              ]));
          firstPointPCI = secondPointPCI;
          secondPointPCI = showPCIlabel
              ? min(firstValue, secondValue)
              : velPredPCI.toDouble();
          velocities.add(double.parse(firstLabel['velocity'].toString()));
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
              'avg_vel': 3.6 * (distance / time),
              'distance': distance / 1000,
              'start': (totalD - distance) / 1000,
              'end': totalD / 1000,
              'latlngs': [point1, point2],
              'remarks': firstLabel['remarks']
            };
            pciPolylines.add(
              createPolyline(
                  pci: firstPointPCI,
                  points: points,
                  polylineID: "Polyline$i$j$k",
                  polylineOnTapData: polylineOnTapData),
            );
            // Reset for next segment
            points = [firstPoint];
            velocities = [firstLabel['velocity']];
            distance = 0;
            time = 0;
          }
          distance += d;
          time += t;
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
            'avg_vel': 3.6 * (distance / time),
            'distance': distance / 1000,
            'start': (totalD - distance) / 1000,
            'end': totalD / 1000,
            'latlngs': [point1, point2]
          };
          pciPolylines.add(
            createPolyline(
                pci: secondPointPCI,
                points: points,
                polylineID: "Polyline$i$j${labels.length - 1}",
                polylineOnTapData: polylineOnTapData),
          );
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
            'avg_vel': 3.6 * (distance / time),
            'distance': distance / 1000,
            'start': (totalD - distance) / 1000,
            'end': totalD / 1000,
            'latlngs': [point1, point2]
          };
          pciPolylines.add(
            createPolyline(
                pci: secondPointPCI,
                points: points,
                polylineID: "Polyline$i$j${labels.length - 1}",
                polylineOnTapData: polylineOnTapData),
          );
        }
        logger.i("Distance(Polylines): $disP");
        final completeStats = setRoadStatistics(
          journeyData: road,
          filename: currJourney['filename'],
        );
        for (var stats in completeStats[0]) {
          rs.add(stats);
        }
        for (var stats in completeStats[1]) {
          ss.add(stats);
        }
      }

      roadStats.add(rs);
      segStats.add(ss);
    }
    LatLng southwest = LatLng(minimumLat, minimumLon);
    LatLng northeast = LatLng(maximumLat, maximumLon);
    pciPolylines.addAll(drrpPolylines);
    sendPort.send({
      'roadStats': roadStats,
      'segStats': segStats,
      'pciPolylines': pciPolylines,
      'southwest': southwest,
      'northeast': northeast,
    });
  } catch (e, stackTrace) {
    logger.e(e.toString());
    logger.d(stackTrace);
  }
  logger.d('Isolate ended');
}

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
