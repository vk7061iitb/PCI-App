import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Functions/vel_to_pci.dart';
import 'package:share_plus/share_plus.dart';
import '../Objects/data.dart';
import '../src/Models/stats_data.dart';
import '../Functions/avg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

List<RoadStats> setRoadStatistics(
    {required List<Map<String, dynamic>> journeyData}) {
  if (journeyData.isEmpty) {
    return [];
  }
  List<RoadStats> roadStatistics = [];
  for (var road in journeyData) {
    String roadName = road["roadName"];
    roadStatistics.add(RoadStats(
      roadName: roadName,
      predStats: _predStats(road),
      velStats: _velStats(road),
    ));
  }

  return roadStatistics;
}

List<RoadStatsData> _velStats(Map<String, dynamic> road) {
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
    for (int k = 0; k < labels.length - 1; k++) {
      var firstLabel = labels[k];
      var secondLabel = labels[k + 1];
      LatLng firstPoint =
          LatLng(firstLabel['latitude'], firstLabel['longitude']);
      LatLng secondPoint =
          LatLng(secondLabel['latitude'], secondLabel['longitude']);

      firstPointPCI = secondPointPCI;
      secondPointPCI = min(velocityToPCI(3.6 * secondLabel['velocity']),
          velocityToPCI(3.6 * firstLabel['velocity']));

      // Calculate distance between points
      double d = Geolocator.distanceBetween(
        firstPoint.latitude,
        firstPoint.longitude,
        secondPoint.latitude,
        secondPoint.longitude,
      ); // in meters
      td += d;
      velocities.add(firstLabel['velocity']);

      if (secondPointPCI != firstPointPCI) {
        stats[firstPointPCI.toString()]['number_of_segments'] += 1;
        double n = stats[firstPointPCI.toString()]['number_of_segments'];
        stats[firstPointPCI.toString()]['avg_velocity'] =
            (stats[firstPointPCI.toString()]['avg_velocity'] * (n - 1) +
                    avg(velocities)) /
                n;
        stats[firstPointPCI.toString()]['distance_travelled'] += distance;

        // reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
      }
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
    }

    List<RoadStatsData> velStatsList = [];
    logger.i("Distance Travelled(Actual): $td");
    double td2 = 0.0;
    for (var key in stats.keys) {
      if (double.parse(key) == 0) {
        continue;
      }
      velStatsList.add(
        RoadStatsData(
          pci: double.parse(key).toStringAsFixed(0),
          avgVelocity: stats[key]['avg_velocity'].toString(),
          distanceTravelled: stats[key]['distance_travelled'].toString(),
          numberOfSegments: stats[key]['number_of_segments'].toString(),
        ),
      );
      td2 += stats[key]['distance_travelled'];
    }
    logger.i("Distance Travelled(Velocity): $td2");
    return velStatsList;
  } catch (e, stackTrace) {
    logger.e('Error parsing labels: $e');
    logger.e(stackTrace.toString());
    return [];
  }
}

///
List<RoadStatsData> _predStats(Map<String, dynamic> road) {
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
    for (int k = 0; k < labels.length - 1; k++) {
      var firstLabel = labels[k];
      var secondLabel = labels[k + 1];
      LatLng firstPoint =
          LatLng(firstLabel['latitude'], firstLabel['longitude']);
      LatLng secondPoint =
          LatLng(secondLabel['latitude'], secondLabel['longitude']);

      firstPointPCI = secondPointPCI;
      secondPointPCI = min(secondLabel['prediction'], firstLabel['prediction']);

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

        // reset the data
        velocities = [firstLabel['velocity']];
        distance = 0.0;
      }
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
    }

    List<RoadStatsData> predStatsList = [];
    double td2 = 0.0;
    for (var key in stats.keys) {
      if (double.parse(key) == 0) {
        continue;
      }
      predStatsList.add(
        RoadStatsData(
          pci: double.parse(key).toStringAsFixed(0),
          avgVelocity: stats[key]['avg_velocity'].toString(),
          distanceTravelled: stats[key]['distance_travelled'].toString(),
          numberOfSegments: stats[key]['number_of_segments'].toString(),
        ),
      );
      td2 += stats[key]['distance_travelled'];
    }
    logger.i("Distance Travelled(Prediction): $td2");
    return predStatsList;
  } catch (e, stackTrace) {
    logger.e('Error parsing labels: $e');
    logger.e(stackTrace.toString());
    return [];
  }
}

Future<void> generatePdf(Map<String, dynamic> jsonData) async {
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title
            pw.Text(
              "Summary",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),

            // Table
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              headers: [
                "Key",
                "Avg Velocity",
                "Distance Travelled",
                "Number of Segments"
              ],
              data: jsonData.entries.map((entry) {
                final key = entry.key;

                final avgVelocity = entry.value['avg_velocity'];
                final distanceTravelled = entry.value['distance_travelled'];
                final numberOfSegments = entry.value['number_of_segments'];

                return [
                  key,
                  avgVelocity.toStringAsFixed(3),
                  distanceTravelled.toStringAsFixed(3),
                  numberOfSegments.toStringAsFixed(1),
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  try {
    // Get temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/summary_table.pdf');

    // Write PDF
    await file.writeAsBytes(await pdf.save());

    // Share the PDF
    await Share.shareXFiles([XFile(file.path)]);
  } catch (e) {
    logger.i('Error generating/sharing PDF: $e');
  }
}
