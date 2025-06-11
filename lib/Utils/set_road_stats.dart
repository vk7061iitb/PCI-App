import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pciapp/Utils/get_surface_type.dart';
import 'package:pciapp/Utils/vel_to_pci.dart';
import '../Objects/data.dart';
import '../src/Models/stats_data.dart';
import '../Functions/avg.dart';
import 'format_chainage.dart';

// compute the road statistics using the journey data (JSON direlctly got from local db)
List<dynamic> setRoadStatistics({
  required Map<String, dynamic> journeyData,
  required String filename,
}) {
  if (journeyData.isEmpty) {
    return [];
  }

  List<RoadStatsOverall> roadOverallStats = [];
  List<RoadStatsChainage> roadSegmentStats = [];

  // passed by ref and updated in the stats calculating function
  List<RoadChainageStatistics> chainageStatsPredictionBased = [];
  List<RoadChainageStatistics> chainageStatsVelocityBased = [];

  String roadName = journeyData["roadName"];
  roadOverallStats.add(
    RoadStatsOverall(
      roadName: roadName,
      overallStatsPredictionBased: _calculatePredictionBasedStats(
          journeyData, chainageStatsPredictionBased, filename, roadName),
      overallStatsVelocityBased: _calculateVelocityBasedStats(
          journeyData, chainageStatsVelocityBased, filename, roadName),
    ),
  );

  roadSegmentStats.add(
    RoadStatsChainage(
      chainageStatsPredictionBased: chainageStatsPredictionBased,
      chainageStatsVelocityBased: chainageStatsVelocityBased,
    ),
  );
  return [roadOverallStats, roadSegmentStats];
}

/// calculate the stats based on velocity 
/// (this is considered as evaluating paramenter for road PCI not the one predicted by model)
List<RoadPCIStatistics> _calculateVelocityBasedStats(
    Map<String, dynamic> road,
    List<RoadChainageStatistics> velSegStats,
    String filename,
    String roadName) {
  try {
    // Add velocity Based Stats
    List<dynamic> labels = jsonDecode(road["labels"]);

    Map<int, dynamic> overallStats = {};
    // initialize the overall stats (velocity based)
    for (int i = 0; i <= 5; i++) {
      overallStats[i] = {
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
      double t = (d /
          avg([
            double.parse(firstLabel['velocity'].toString()),
            double.parse(secondLabel['velocity'].toString())
          ]));
      velocities.add(double.parse(firstLabel['velocity'].toString()));
      if (secondPointPCI != firstPointPCI) {
        /// add overall stats of the road
        overallStats[firstPointPCI.toInt()]['number_of_segments'] += 1;
        overallStats[firstPointPCI.toInt()]['total_time'] += time;
        overallStats[firstPointPCI.toInt()]['distance_travelled'] += distance;

        /// add the segment to the list
        totalSegments += 1;
        velSegStats.add(
          RoadChainageStatistics(
            name: filename,
            roadNo: roadName,
            segmentNo: totalSegments.toString(),
            from: formatChainage(td - distance),
            to: formatChainage(td),
            distance: (distance.round() / 1000).toStringAsFixed(4),
            pci: firstPointPCI.toInt(),
            velocityPCI:
                velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
            remarks: getSurfaceType(firstLabel['road_type'] ?? -1),
            surfaceType: 'surfaceType',
          ),
        );

        /// reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
        time = 0.0;
      }
      td += d;
      distance += d;
      time += t;
    }
    if (velocities.length == 1) {
      /// there is last segment which has different PCI than the previous one,
      /// so we need to add it to the stats
      overallStats[secondPointPCI.toInt()]['number_of_segments'] += 1;
      overallStats[secondPointPCI.toInt()]['total_time'] += time;
      overallStats[secondPointPCI.toInt()]['distance_travelled'] += distance;
      if (secondPointPCI != 0) {
        /// add the segment to the list
        totalSegments += 1;
        velSegStats.add(
          RoadChainageStatistics(
            name: filename,
            roadNo: roadName,
            segmentNo: totalSegments.toString(),
            from: formatChainage(td - distance),
            to: formatChainage(td),
            distance: (distance.round() / 1000).toStringAsFixed(4),
            pci: secondPointPCI.toInt(),
            velocityPCI:
                velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
            remarks: getSurfaceType(secondLabel['road_type'] ?? -1),
            surfaceType: 'surfaceType',
          ),
        );
      }
    } else {
      // the last segment has the same PCI as the previous one, but the loop has ended before adding it to the stats,
      // so we need to add it now
      velocities.add(labels.last['velocity']);
      overallStats[firstPointPCI.toInt()]['number_of_segments'] += 1;
      overallStats[firstPointPCI.toInt()]['total_time'] += time;
      overallStats[firstPointPCI.toInt()]['distance_travelled'] += distance;
      if (secondPointPCI != 0) {
        // add the segment to the list
        totalSegments += 1;
        velSegStats.add(
          RoadChainageStatistics(
            name: filename,
            roadNo: roadName,
            segmentNo: totalSegments.toString(),
            from: formatChainage(td - distance),
            to: formatChainage(td),
            distance: (distance.round() / 1000).toStringAsFixed(4),
            pci: secondPointPCI.toInt(),
            velocityPCI:
                velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
            remarks: getSurfaceType(secondLabel['road_type'] ?? -1),
            surfaceType: 'surfaceType',
          ),
        );
      }
    }

    List<RoadPCIStatistics> velStatsList = [];
    for (var key in overallStats.keys) {
      if (key == 0) {
        continue;
      }
      velStatsList.add(
        RoadPCIStatistics(
          pci: key.toString(),
          avgVelocity: overallStats[key]['number_of_segments'] == 0
              ? '0'
              : (overallStats[key]['distance_travelled'] / overallStats[key]['total_time'])
                  .toString(),
          distanceTravelled: overallStats[key]['distance_travelled'].toString(),
          numberOfSegments: overallStats[key]['number_of_segments'].toStringAsFixed(0),
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

List<RoadPCIStatistics> _calculatePredictionBasedStats(
    Map<String, dynamic> road,
    List<RoadChainageStatistics> predSegStats,
    String filename,
    String roadName) {
  try {
    // Add velocity Based Stats
    List<dynamic> labels = jsonDecode(road["labels"]);

    Map<int, dynamic> stats = {};
    for (int i = -2; i <= 5; i++) {
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

      // Instead, use the current point's prediction directly
      firstPointPCI = (firstLabel['prediction'] as num).toDouble();
      secondPointPCI = (secondLabel['prediction'] as num).toDouble();
      // Calculate distance between points
      double d = Geolocator.distanceBetween(
        firstPoint.latitude,
        firstPoint.longitude,
        secondPoint.latitude,
        secondPoint.longitude,
      ); // in meters

      double t = (d /
          avg([
            double.parse(firstLabel['velocity'].toString()),
            double.parse(secondLabel['velocity'].toString())
          ]));
      velocities.add(double.parse(firstLabel['velocity'].toString()));

      if (secondPointPCI != firstPointPCI) {
        stats[firstPointPCI.toInt()]['number_of_segments'] += 1;
        stats[firstPointPCI.toInt()]['total_time'] += time;
        stats[firstPointPCI.toInt()]['distance_travelled'] += distance;
        // add the segment to the list
        totalSegments += 1;
        predSegStats.add(
          RoadChainageStatistics(
            name: filename,
            roadNo: roadName,
            segmentNo: totalSegments.toString(),
            from: formatChainage(td - distance),
            to: formatChainage(td),
            distance: (distance.round() / 1000).toStringAsFixed(4),
            pci: firstPointPCI.toInt(),
            velocityPCI:
                velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
            remarks: firstLabel['remarks'] ?? "--",
            surfaceType: getSurfaceType(firstLabel['road_type']),
          ),
        );

        // reset the data
        velocities = [double.parse(firstLabel['velocity'].toString())];
        distance = 0.0;
        time = 0.0;
      }
      td += d;
      distance += d;
      time += t;
    }
    if (velocities.length == 1) {
      if (firstLabel['prediction'] < 0) {
        logger.d(firstLabel['remarks']);
      }
      // there is last segment which has different PCI than the previous one,
      // so we need to add it to the stats
      stats[secondPointPCI.toInt()]['number_of_segments'] += 1;
      stats[secondPointPCI.toInt()]['total_time'] += time;
      stats[secondPointPCI.toInt()]['distance_travelled'] += distance;

      // add the segment to the list
      totalSegments += 1;
      predSegStats.add(
        RoadChainageStatistics(
          name: filename,
          roadNo: roadName,
          segmentNo: totalSegments.toStringAsFixed(0),
          from: formatChainage(td - distance),
          to: formatChainage(td),
          distance: (distance.round() / 1000).toStringAsFixed(4),
          pci: secondPointPCI.toInt(),
          velocityPCI:
              velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
          remarks: secondLabel['remarks'] ?? "--",
          surfaceType: getSurfaceType(secondLabel['road_type']),
        ),
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
        RoadChainageStatistics(
          name: filename,
          roadNo: roadName,
          segmentNo: totalSegments.toStringAsFixed(0),
          from: formatChainage(td - distance),
          to: formatChainage(td),
          distance: (distance.round() / 1000).toStringAsFixed(4),
          pci: secondPointPCI.toInt(),
          velocityPCI:
              velocityToPCI(velocityKmph: 3.6 * (distance / time)).toInt(),
          remarks: secondLabel['remarks'] ?? "--",
          surfaceType: getSurfaceType(secondLabel['road_type']),
        ),
      );
    }

    List<RoadPCIStatistics> predStatsList = [];
    for (var key in stats.keys) {
      if (key == 0) {
        continue;
      }
      predStatsList.add(
        RoadPCIStatistics(
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


