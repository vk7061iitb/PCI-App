import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pciapp/Utils/vel_to_pci.dart';
import '../Objects/data.dart';
import '../src/Models/stats_data.dart';
import '../Functions/avg.dart';
import 'format_chainage.dart';

List<dynamic> setRoadStatistics({
  required Map<String, dynamic> journeyData,
  required String filename,
}) {
  if (journeyData.isEmpty) {
    return [];
  }
  List<RoadStats> roadStatistics = [];
  List<SegStats> segStats = [];
  List<SegmentStats> predSegStats = [];
  List<SegmentStats> velSegStats = [];

  String roadName = journeyData["roadName"];
  roadStatistics.add(
    RoadStats(
      roadName: roadName,
      predStats: _predStats(journeyData, predSegStats, filename, roadName),
      velStats: _velStats(journeyData, velSegStats, filename, roadName),
    ),
  );

  segStats
      .add(SegStats(predictedStats: predSegStats, velocityStats: velSegStats));
  return [roadStatistics, segStats];
}

List<RoadStatsData> _velStats(Map<String, dynamic> road,
    List<SegmentStats> velSegStats, String filename, String roadName) {
  try {
    // Add velocity Based Stats
    List<dynamic> labels = jsonDecode(road["labels"]);
    Map<int, dynamic> stats = {};
    // initialize the stats
    for (int i = 0; i <= 5; i++) {
      stats[i] = {
        'avg_velocity': 0.0,
        'distance_travelled': 0.0,
        'number_of_segments': 0.0,
        'total_time': 0.0,
      };
    }
    List<double> velocities = [];
    double firstPointPCI = 0.0;
    double secondPointPCI = 0.0;
    double distance = 0.0;
    double td = 0.0;
    double time = 0.0;
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
      double velPredPCI = min(
          velocityToPCI(velocityKmph: 3.6 * secondLabel['velocity']),
          velocityToPCI(velocityKmph: 3.6 * firstLabel['velocity']));
      secondPointPCI = velPredPCI.toDouble();

      // Calculate distance between points
      double d = Geolocator.distanceBetween(
        firstPoint.latitude,
        firstPoint.longitude,
        secondPoint.latitude,
        secondPoint.longitude,
      ); // in meters
      double t = (d / avg([firstLabel['velocity'], secondLabel['velocity']]));
      velocities.add(firstLabel['velocity']);
      if (secondPointPCI != firstPointPCI) {
        /// add overall stats
        stats[firstPointPCI.toInt()]['number_of_segments'] += 1;
        stats[firstPointPCI.toInt()]['total_time'] += time;
        stats[firstPointPCI.toInt()]['distance_travelled'] += distance;

        /// add the segment to the list
        totalSegments += 1;
        velSegStats.add(
          SegmentStats(
              name: filename,
              roadNo: roadName,
              segmentNo: totalSegments.toString(),
              from: formatChainage(td - distance),
              to: formatChainage(td),
              distance: (distance.round() / 1000).toStringAsFixed(4),
              pci: firstPointPCI.toInt(),
              velocityPCI:
                  velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
              remarks: remarks(firstLabel['road_type'] ?? -1)),
        );
        // reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
        time = 0.0;
      }
      td += d;
      distance += d;
      time += t;
    }
    if (velocities.length == 1) {
      // there is last segment which has different PCI than the previous one,
      // so we need to add it to the stats
      stats[secondPointPCI.toInt()]['number_of_segments'] += 1;
      stats[secondPointPCI.toInt()]['total_time'] += time;
      stats[secondPointPCI.toInt()]['distance_travelled'] += distance;
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
              pci: secondPointPCI.toInt(),
              velocityPCI:
                  velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
              remarks: remarks(secondLabel['road_type'] ?? -1)),
        );
      }
    } else {
      // the last segment has the same PCI as the previous one, but the loop has ended before adding it to the stats,
      // so we need to add it now
      velocities.add(labels.last['velocity']);
      stats[firstPointPCI.toInt()]['number_of_segments'] += 1;
      stats[firstPointPCI.toInt()]['total_time'] += time;
      stats[firstPointPCI.toInt()]['distance_travelled'] += distance;
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
              pci: secondPointPCI.toInt(),
              velocityPCI:
                  velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
              remarks: remarks(secondLabel['road_type'] ?? -1)),
        );
      }
    }

    List<RoadStatsData> velStatsList = [];
    for (var key in stats.keys) {
      if (key == 0) {
        continue;
      }
      velStatsList.add(
        RoadStatsData(
          pci: key.toString(),
          avgVelocity: stats[key]['number_of_segments'] == 0
              ? '0'
              : (stats[key]['distance_travelled'] / stats[key]['total_time'])
                  .toString(),
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

List<RoadStatsData> _predStats(Map<String, dynamic> road,
    List<SegmentStats> predSegStats, String filename, String roadName) {
  try {
    // Add velocity Based Stats
    List<dynamic> labels = jsonDecode(road["labels"]);
    Map<int, dynamic> stats = {};
    for (int i = 0; i <= 5; i++) {
      stats[i] = {
        'avg_velocity': 0.0,
        'distance_travelled': 0.0,
        'number_of_segments': 0.0,
        'total_time': 0.0,
      };
    }
    List<double> velocities = [];
    double firstPointPCI = 0.0;
    double secondPointPCI = 0.0;
    double distance = 0.0;
    double td = 0.0;
    double time = 0.0;
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
      double t = (d / avg([firstLabel['velocity'], secondLabel['velocity']]));
      velocities.add(firstLabel['velocity']);
      if (secondPointPCI != firstPointPCI) {
        stats[firstPointPCI.toInt()]['number_of_segments'] += 1;
        stats[firstPointPCI.toInt()]['total_time'] += time;
        stats[firstPointPCI.toInt()]['distance_travelled'] += distance;
        // add the segment to the list

        totalSegments += 1;
        predSegStats.add(
          SegmentStats(
              name: filename,
              roadNo: roadName,
              segmentNo: totalSegments.toString(),
              from: formatChainage(td - distance),
              to: formatChainage(td),
              distance: (distance.round() / 1000).toStringAsFixed(4),
              pci: firstPointPCI.toInt(),
              velocityPCI:
                  velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
              remarks: remarks(firstLabel['road_type'] ?? -1)),
        );

        // reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
        time = 0.0;
      }
      td += d;
      distance += d;
      time += t;
    }
    if (velocities.length == 1) {
      // there is last segment which has different PCI than the previous one,
      // so we need to add it to the stats
      stats[secondPointPCI.toInt()]['number_of_segments'] += 1;
      stats[secondPointPCI.toInt()]['total_time'] += time;
      stats[secondPointPCI.toInt()]['distance_travelled'] += distance;

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
            pci: secondPointPCI.toInt(),
            velocityPCI:
                velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
            remarks: remarks(secondLabel['road_type'] ?? -1)),
      );
    } else {
      // the last segment has the same PCI as the previous one,
      // but the loop has ended before adding it to the stats,
      // so we need to add it now
      velocities.add(labels.last['velocity']);
      stats[firstPointPCI.toInt()]['number_of_segments'] += 1;
      stats[firstPointPCI.toInt()]['total_time'] += time;
      stats[firstPointPCI.toInt()]['distance_travelled'] += distance;
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
            pci: secondPointPCI.toInt(),
            velocityPCI:
                velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
            remarks: remarks(secondLabel['road_type'] ?? -1)),
      );
    }

    List<RoadStatsData> predStatsList = [];
    for (var key in stats.keys) {
      if (key == 0) {
        continue;
      }
      predStatsList.add(
        RoadStatsData(
          pci: key.toString(),
          avgVelocity: stats[key]['number_of_segments'] == 0
              ? '0'
              : (stats[key]['distance_travelled'] / stats[key]['total_time'])
                  .toString(),
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
