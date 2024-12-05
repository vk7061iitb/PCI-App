import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Functions/vel_to_pci.dart';

import '../Objects/data.dart';
import '../src/Models/stats_data.dart';
import 'avg.dart';

RoadStats setRoadStatistics({required List<Map<String, dynamic>> journeyData}) {
  if (journeyData.isEmpty) {
    return RoadStats(roadName: "No Data", predStats: [], velStats: []);
  }
  RoadStats? roadStatistics;
  for (var road in journeyData) {
    String roadName = road["roadName"];

    // Add Prediction Based Stats
    dynamic predBasedStats = jsonDecode(road["stats"]);
    List<RoadStatsData> predStatsList = [];
    for (int i = 1; i <= 5; i++) {
      String key =
          "$i"; // PCI values are from 1 to 5, so we are using them as keys
      predStatsList.add(
        RoadStatsData(
          pci: key,
          avgVelocity: predBasedStats[key]['avg_velocity'].toString(),
          distanceTravelled:
              predBasedStats[key]['distance_travelled'].toString(),
          numberOfSegments:
              predBasedStats[key]['number_of_segments'].toString(),
        ),
      );
    }
    try {
      // Add velocity Based Stats
      List<dynamic> labels = jsonDecode(road["labels"]);
      var firstLabel = labels[0];
      Map<String, dynamic> stats = {};
      List<double> velocities = [];
      double currVelPCI = 0.0;
      double nxtVelPCI = velocityToPCI(3.6 * firstLabel['velocity']);
      double distance = 0.0;
      for (int k = 0; k < labels.length - 1; k++) {
        var currLabel = labels[k];
        var nxtLabel = labels[k + 1];
        currVelPCI = nxtVelPCI;
        nxtVelPCI = velocityToPCI(
            3.6 * avg([nxtLabel['velocity'], currLabel['velocity']]));
        LatLng currPoint =
            LatLng(currLabel['latitude'], currLabel['longitude']);
        LatLng nxtPoint = LatLng(nxtLabel['latitude'], nxtLabel['longitude']);

        // Calculate distance between points
        double d = Geolocator.distanceBetween(
          currPoint.latitude,
          currPoint.longitude,
          nxtPoint.latitude,
          nxtPoint.longitude,
        );
        velocities.add(currLabel['velocity']);

        if (!stats.containsKey(nxtVelPCI.toString())) {
          stats[nxtVelPCI.toString()] = {
            'avg_velocity': 0.0,
            'distance_travelled': 0.0,
            'number_of_segments': 0.0,
          };
        }

        if (nxtVelPCI != currVelPCI) {
          stats[currVelPCI.toString()]['number_of_segments'] += 1;
          double n = stats[currVelPCI.toString()]['number_of_segments'];
          stats[currVelPCI.toString()]['avg_velocity'] =
              (stats[currVelPCI.toString()]['avg_velocity'] * (n - 1) +
                      avg(velocities)) /
                  n;
          stats[currVelPCI.toString()]['distance_travelled'] += d;

          // reset the data
          velocities = [currLabel['velocity']];
        }
        distance += d;
      }
      if (velocities.length == 1) {
        stats[nxtVelPCI.toString()]['number_of_segments'] += 1;
        double n = stats[nxtVelPCI.toString()]['number_of_segments'];
        stats[nxtVelPCI.toString()]['avg_velocity'] =
            (stats[nxtVelPCI.toString()]['avg_velocity'] * (n - 1) +
                    avg(velocities)) /
                n;
        stats[nxtVelPCI.toString()]['distance_travelled'] += distance;
      } else {
        velocities.add(labels.last['velocity']);
        stats[currVelPCI.toString()]['number_of_segments'] += 1;
        double n = stats[currVelPCI.toString()]['number_of_segments'];
        stats[currVelPCI.toString()]['avg_velocity'] =
            (stats[currVelPCI.toString()]['avg_velocity'] * (n - 1) +
                    avg(velocities)) /
                n;
        stats[currVelPCI.toString()]['distance_travelled'] += distance;
      }

      List<RoadStatsData> velStatsList = [];
      for (var key in stats.keys) {
        velStatsList.add(
          RoadStatsData(
            pci: double.parse(key).toStringAsFixed(0),
            avgVelocity: stats[key]['avg_velocity'].toString(),
            distanceTravelled: stats[key]['distance_travelled'].toString(),
            numberOfSegments: stats[key]['number_of_segments'].toString(),
          ),
        );
      }
      roadStatistics = RoadStats(
        roadName: roadName,
        predStats: predStatsList,
        velStats: velStatsList,
      );
      logger.i("velocity Based Stats:");
      logger.i(stats);
    } catch (e, stackTrace) {
      logger.e(e.toString());
      logger.e(stackTrace.toString());
    }
  }

  return roadStatistics!;
}
