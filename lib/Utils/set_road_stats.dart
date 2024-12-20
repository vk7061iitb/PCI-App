import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Utils/vel_to_pci.dart';
import '../Objects/data.dart';
import '../src/Models/stats_data.dart';
import '../Functions/avg.dart';

List<dynamic> setRoadStatistics({
  required List<Map<String, dynamic>> journeyData,
  required String filename,
}) {
  if (journeyData.isEmpty) {
    return [];
  }
  List<RoadStats> roadStatistics = [];
  List<SegStats> segStats = [];
  List<SegmentStats> predSegStats = [];
  List<SegmentStats> velSegStats = [];
  for (var road in journeyData) {
    String roadName = road["roadName"];
    roadStatistics.add(RoadStats(
      roadName: roadName,
      predStats: _predStats(road, predSegStats, filename, roadName),
      velStats: _velStats(road, velSegStats, filename, roadName),
    ));
  }
  logger.i(predSegStats.length);
  logger.i(velSegStats.length);
  segStats
      .add(SegStats(predictedStats: predSegStats, velocityStats: velSegStats));
  return [roadStatistics, segStats];
}

String formatChainage(double distanceInMeters) {
  // Round to nearest integer to avoid floating-point issues
  int totalMeters = (distanceInMeters).round();

  // Calculate kilometers and remaining meters
  int kilometers = totalMeters ~/ 1000; // Integer division for kilometers
  int meters = totalMeters % 1000; // Remainder for meters
  String chainageTo = '$kilometers/${meters.toString().padLeft(3, '0')}';
  return chainageTo;
}

List<RoadStatsData> _velStats(Map<String, dynamic> road,
    List<SegmentStats> velSegStats, String filename, String roadName) {
  try {
    // Add velocity Based Stats
    List<dynamic> labels = jsonDecode(road["labels"]);
    Map<String, dynamic> stats = {};
    // initialize the stats
    for (double i = 0; i <= 5; i++) {
      stats[i.toString()] = {
        'avg_velocity': 0.0,
        'distance_travelled': 0.0,
        'number_of_segments': 0.0,
      };
    }
    List<double> velocities = [];
    double firstPointPCI = 0.0;
    double secondPointPCI = 0.0;
    double distance = 0.0;
    double td = 0.0;
    int totalSegments = 0;
    Map<String, dynamic> firstLabel = {};
    Map<String, dynamic> secondLabel = {};
    for (int k = 0; k < labels.length - 1; k++) {
      firstLabel = labels[k];
      secondLabel = labels[k + 1];
      LatLng firstPoint =
          LatLng(firstLabel['latitude'], firstLabel['longitude']);
      LatLng secondPoint =
          LatLng(secondLabel['latitude'], secondLabel['longitude']);

      firstPointPCI = secondPointPCI;
      double velPredPCI = min(velocityToPCI(3.6 * secondLabel['velocity']),
          velocityToPCI(3.6 * firstLabel['velocity']));
      secondPointPCI = velPredPCI.toDouble();

      // Calculate distance between points
      double d = Geolocator.distanceBetween(
        firstPoint.latitude,
        firstPoint.longitude,
        secondPoint.latitude,
        secondPoint.longitude,
      ); // in meters

      velocities.add(firstLabel['velocity']);

      if (secondPointPCI != firstPointPCI) {
        stats[firstPointPCI.toString()]['number_of_segments'] += 1;
        double n = stats[firstPointPCI.toString()]['number_of_segments'];
        stats[firstPointPCI.toString()]['avg_velocity'] =
            (stats[firstPointPCI.toString()]['avg_velocity'] * (n - 1) +
                    avg(velocities)) /
                n;
        stats[firstPointPCI.toString()]['distance_travelled'] += distance;
        if (firstPointPCI != 0) {
          // add the segment to the list
          totalSegments += 1;
          velSegStats.add(
            SegmentStats(
                name: filename,
                roadNo: roadName,
                segmentNo: totalSegments.toString(),
                from: formatChainage(td - distance),
                to: formatChainage(td),
                distance: (distance.round() / 1000).toStringAsFixed(4),
                pci: firstPointPCI.toStringAsFixed(0),
                remarks: remarks(firstLabel['road_type'] ?? -1)),
          );
        }
        // reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
      }
      td += d;
      distance += d;
    }
    if (velocities.length == 1) {
      // there is last segment which has different PCI than the previous one,
      // so we need to add it to the stats
      stats[secondPointPCI.toString()]['number_of_segments'] += 1;
      double n = stats[secondPointPCI.toString()]['number_of_segments'];
      stats[secondPointPCI.toString()]['avg_velocity'] =
          (stats[secondPointPCI.toString()]['avg_velocity'] * (n - 1) +
                  avg(velocities)) /
              n;
      stats[secondPointPCI.toString()]['distance_travelled'] += distance;
      if (secondPointPCI != 0) {
        // add the segment to the list
        totalSegments += 1;
        velSegStats.add(
          SegmentStats(
              name: filename,
              roadNo: roadName,
              segmentNo: totalSegments.toString(),
              from: formatChainage(td - distance),
              to: formatChainage(td),
              distance: (distance.round() / 1000).toStringAsFixed(4),
              pci: secondPointPCI.toStringAsFixed(0),
              remarks: remarks(secondLabel['road_type'] ?? -1)),
        );
      }
    } else {
      // the last segment has the same PCI as the previous one, but the loop has ended before adding it to the stats,
      // so we need to add it now
      velocities.add(labels.last['velocity']);
      stats[firstPointPCI.toString()]['number_of_segments'] += 1;
      double n = stats[firstPointPCI.toString()]['number_of_segments'];
      stats[firstPointPCI.toString()]['avg_velocity'] =
          (stats[firstPointPCI.toString()]['avg_velocity'] * (n - 1) +
                  avg(velocities)) /
              n;
      stats[firstPointPCI.toString()]['distance_travelled'] += distance;
      if (secondPointPCI != 0) {
        // add the segment to the list
        totalSegments += 1;
        velSegStats.add(
          SegmentStats(
              name: filename,
              roadNo: roadName,
              segmentNo: totalSegments.toString(),
              from: formatChainage(td - distance),
              to: formatChainage(td),
              distance: (distance.round() / 1000).toStringAsFixed(4),
              pci: secondPointPCI.toStringAsFixed(0),
              remarks: remarks(secondLabel['road_type'] ?? -1)),
        );
      }
    }

    List<RoadStatsData> velStatsList = [];
    logger.i("Distance Travelled(Actual): $td");
    for (var key in stats.keys) {
      if (double.parse(key) == 0) {
        continue;
      }
      velStatsList.add(
        RoadStatsData(
          pci: double.parse(key).toStringAsFixed(0),
          avgVelocity: stats[key]['avg_velocity'].toString(),
          distanceTravelled: stats[key]['distance_travelled'].toString(),
          numberOfSegments: stats[key]['number_of_segments'].toStringAsFixed(0),
        ),
      );
    }
    return velStatsList;
  } catch (e, stackTrace) {
    logger.e('Error parsing labels: $e');
    logger.e(stackTrace.toString());
    return [];
  }
}

///
List<RoadStatsData> _predStats(Map<String, dynamic> road,
    List<SegmentStats> predSegStats, String filename, String roadName) {
  try {
    // Add velocity Based Stats
    List<dynamic> labels = jsonDecode(road["labels"]);
    Map<String, dynamic> stats = {};
    for (double i = 0; i <= 5; i++) {
      stats[i.toString()] = {
        'avg_velocity': 0.0,
        'distance_travelled': 0.0,
        'number_of_segments': 0.0,
      };
    }
    List<double> velocities = [];
    double firstPointPCI = 0.0;
    double secondPointPCI = 0.0;
    double distance = 0.0;
    double td = 0.0;
    int totalSegments = 0;
    Map<String, dynamic> firstLabel = {};
    Map<String, dynamic> secondLabel = {};
    for (int k = 0; k < labels.length - 1; k++) {
      firstLabel = labels[k];
      secondLabel = labels[k + 1];
      LatLng firstPoint =
          LatLng(firstLabel['latitude'], firstLabel['longitude']);
      LatLng secondPoint =
          LatLng(secondLabel['latitude'], secondLabel['longitude']);

      firstPointPCI = secondPointPCI;
      double firstValue = (firstLabel['prediction'] as num).toDouble();
      double secondValue = (secondLabel['prediction'] as num).toDouble();
      secondPointPCI = min(firstValue, secondValue);

      // Calculate distance between points
      double d = Geolocator.distanceBetween(
        firstPoint.latitude,
        firstPoint.longitude,
        secondPoint.latitude,
        secondPoint.longitude,
      ); // in meters
      velocities.add(firstLabel['velocity']);

      if (secondPointPCI != firstPointPCI) {
        stats[firstPointPCI.toString()]['number_of_segments'] += 1;
        double n = stats[firstPointPCI.toString()]['number_of_segments'];
        stats[firstPointPCI.toString()]['avg_velocity'] =
            (stats[firstPointPCI.toString()]['avg_velocity'] * (n - 1) +
                    avg(velocities)) /
                n;
        stats[firstPointPCI.toString()]['distance_travelled'] += distance;
        // add the segment to the list
        if (firstPointPCI != 0) {
          totalSegments += 1;
          predSegStats.add(
            SegmentStats(
                name: filename,
                roadNo: roadName,
                segmentNo: totalSegments.toString(),
                from: formatChainage(td - distance),
                to: formatChainage(td),
                distance: (distance.round() / 1000).toStringAsFixed(4),
                pci: firstPointPCI.toStringAsFixed(0),
                remarks: remarks(firstLabel['road_type'] ?? -1)),
          );
        }
        // reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
      }
      td += d;
      distance += d;
    }
    if (velocities.length == 1) {
      // there is last segment which has different PCI than the previous one,
      // so we need to add it to the stats
      stats[secondPointPCI.toString()]['number_of_segments'] += 1;
      double n = stats[secondPointPCI.toString()]['number_of_segments'];
      stats[secondPointPCI.toString()]['avg_velocity'] =
          (stats[secondPointPCI.toString()]['avg_velocity'] * (n - 1) +
                  avg(velocities)) /
              n;
      stats[secondPointPCI.toString()]['distance_travelled'] += distance;
      if (secondPointPCI != 0) {
        // add the segment to the list
        totalSegments += 1;
        predSegStats.add(
          SegmentStats(
              name: filename,
              roadNo: roadName,
              segmentNo: totalSegments.toStringAsFixed(0),
              from: formatChainage(td - distance),
              to: formatChainage(td),
              distance: (distance.round() / 1000).toStringAsFixed(4),
              pci: secondPointPCI.toStringAsFixed(0),
              remarks: remarks(secondLabel['road_type'] ?? -1)),
        );
      }
    } else {
      // the last segment has the same PCI as the previous one,
      // but the loop has ended before adding it to the stats,
      // so we need to add it now
      velocities.add(labels.last['velocity']);
      stats[firstPointPCI.toString()]['number_of_segments'] += 1;
      double n = stats[firstPointPCI.toString()]['number_of_segments'];
      stats[firstPointPCI.toString()]['avg_velocity'] =
          (stats[firstPointPCI.toString()]['avg_velocity'] * (n - 1) +
                  avg(velocities)) /
              n;
      stats[firstPointPCI.toString()]['distance_travelled'] += distance;
      if (secondPointPCI != 0) {
        // add the segment to the list
        totalSegments += 1;
        predSegStats.add(
          SegmentStats(
              name: filename,
              roadNo: roadName,
              segmentNo: totalSegments.toStringAsFixed(0),
              from: formatChainage(td - distance),
              to: formatChainage(td),
              distance: (distance.round() / 1000).toStringAsFixed(4),
              pci: secondPointPCI.toStringAsFixed(0),
              remarks: remarks(secondLabel['road_type'] ?? -1)),
        );
      }
    }

    List<RoadStatsData> predStatsList = [];
    for (var key in stats.keys) {
      if (double.parse(key) == 0) {
        continue;
      }
      predStatsList.add(
        RoadStatsData(
          pci: double.parse(key).toStringAsFixed(0),
          avgVelocity: stats[key]['avg_velocity'].toString(),
          distanceTravelled: stats[key]['distance_travelled'].toString(),
          numberOfSegments: stats[key]['number_of_segments'].toStringAsFixed(0),
        ),
      );
    }
    return predStatsList;
  } catch (e, stackTrace) {
    logger.e('Error parsing labels: $e');
    logger.e(stackTrace.toString());
    return [];
  }
}

String remarks(int roadType) {
  String res;
  switch (roadType) {
    case 0:
      res = "Paved";
      break;
    case 1:
      res = "Un-Paved";
      break;
    case 2:
      res = "Pedestrian";
      break;
    default:
      res = "No Remarks";
  }
  return res;
}
