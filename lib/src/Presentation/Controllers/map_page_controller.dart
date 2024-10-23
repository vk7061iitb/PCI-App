import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Functions/get_road_color.dart';
import 'package:pci_app/Objects/data.dart';
import '../../Models/stats_data.dart';

class MapPageController extends GetxController {
  final RxBool _isDrrpLayerVisible = false.obs;
  Set<Polyline> polylines = <Polyline>{};
  final Set<Polyline> _pciPolylines = <Polyline>{};
  List<Road> roads = <Road>[];
  GoogleMapController? _googleMapController;
  List<Map<String, dynamic>> roadOutputDataQuery = <Map<String, dynamic>>[];
  LatLng _minLat = const LatLng(0, 0);
  LatLng _maxLat = const LatLng(0, 0);
  List<RoadStats> roadStats = <RoadStats>[];
  final Rx<MapType> _backgroundMapType = MapType.normal.obs;
  RxList<String> mapType =
      ['Normal', 'Satellite', 'Hybrid', 'Teraain', 'None'].obs;
  final RxList<MapType> _googlemapType = [
    MapType.normal,
    MapType.satellite,
    MapType.hybrid,
    MapType.terrain,
    MapType.none
  ].obs;
  RxString dropdownValue = 'Normal'.obs;
  final RxBool _showCircularProgress = false.obs;

  // Getters
  bool get isDrrpLayerVisible => _isDrrpLayerVisible.value;
  RxSet<Polyline> get getPolylines => polylines.obs;
  RxSet<Polyline> get pciPolylines => _pciPolylines.obs;
  LatLng get getMinLat => _minLat;
  LatLng get getMaxLat => _maxLat;
  List<Road> get getRoads => roads;
  List<RoadStats> get getRoadStats => roadStats;
  GoogleMapController? get getGoogleMapController => _googleMapController;
  List<Map<String, dynamic>> get getRoadOutputDataQuery => roadOutputDataQuery;
  List<MapType> get googlemapType => _googlemapType.toList();
  List<String> get getMapType => mapType;
  MapType get backgroundMapType => _backgroundMapType.value;
  String get dropdownvalue => dropdownValue.value;
  bool get showProgress => _showCircularProgress.value;

  // Setters
  set isDrrpLayerVisible(bool value) => _isDrrpLayerVisible.value = value;
  set setPolylines(Set<Polyline> value) => polylines.addAll(value);
  set pciPolylines(Set<Polyline> value) => _pciPolylines.addAll(value);
  set setRoads(List<Road> value) => roads.addAll(value);
  set setGoogleMapController(GoogleMapController? value) =>
      _googleMapController = value;
  set setRoadOutputDataQuery(List<Map<String, dynamic>> value) =>
      roadOutputDataQuery = value;
  set setMapType(List<String> value) => mapType.addAll(value);
  set googlemapType(List<MapType> value) => _googlemapType.addAll(value);
  set backgroundMapType(MapType value) => _backgroundMapType.value = value;
  set dropdownvalue(String value) => dropdownValue.value = value;
  set showProgress(bool value) => _showCircularProgress.value = value;

  // fuction to plot the road data on the map
  void plotRoadData() {
    debugPrint("plotting road data...");
    roadStats.clear();
    for (var road in roadOutputDataQuery) {
      String roadName = road["roadName"];
      List<dynamic> labels = jsonDecode(road["labels"]);
      dynamic roadStatistics = jsonDecode(road["stats"]);

      _minLat = (_minLat.latitude == 0)
          ? LatLng(labels[0]['latitude'], labels[0]['longitude'])
          : _minLat;

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
      for (int i = 1; i < labels.length; i++) {
        _maxLat = LatLng(labels[i]['latitude'], labels[i]['longitude']);
        double avgVelocity =
            (labels[i]['velocity'] + labels[i - 1]['velocity']) / 2;
        double prediction = max(
            double.parse(labels[i]['prediction'].toString()),
            double.parse(labels[i - 1]['prediction'].toString()));
        // Add the polyline
        Polyline tempPolylne = Polyline(
          consumeTapEvents: true,
          polylineId: PolylineId("$roadName$i"),
          color: getRoadColor(prediction),
          width: 5,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
          points: [
            LatLng(labels[i - 1]['latitude'], labels[i - 1]['longitude']),
            LatLng(labels[i]['latitude'], labels[i]['longitude']),
          ],
          onTap: () {
            debugPrint('Polyline $i tapped!');
            Get.bottomSheet(
              clipBehavior: Clip.antiAlias,
              backgroundColor: Colors.white,
              Container(
                padding: const EdgeInsets.all(10),
                width: Get.width,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Features",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Text(
                          roadName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Text(
                          "PCI",
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          prediction.toString(),
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(5),
                        Expanded(
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: prediction / 5,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.black87,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Text(
                          "Avg Speed",
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${avgVelocity.toStringAsFixed(2)} kmph",
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                  ],
                ),
              ),
            );
          },
        );

        _pciPolylines.add(tempPolylne);
      }
    }
    polylines.clear();
    polylines.addAll(_pciPolylines);
  }

  // Function to animate the camera to the location of the polylines
  Future<void> animateToLocation(LatLng min, LatLng max) async {
    double minLat = min.latitude;
    double minLng = min.longitude;
    double maxLat = max.latitude;
    double maxLng = max.longitude;

    if (minLat > maxLat) {
      double temp = minLat;
      minLat = maxLat;
      maxLat = temp;
    }

    if (minLng > maxLng) {
      double temp = minLng;
      minLng = maxLng;
      maxLng = temp;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _googleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 11));
  }

  // This function is used to plot the DRRP layer on the map. It reads the geojson file containing the DRRP data and plots the polylines on the map.
  Future<void> plotDRRPLayer() async {
    _showCircularProgress.value = true;
    String geoJsonString = await rootBundle.loadString(assetsPath.roadDRRP);
    jsonData = jsonDecode(geoJsonString);
    features = jsonData['features'];

    // Clear the polylines then add DRRP + PCI polylines
    polylines.clear();

    for (int i = 0; i < features.length; i++) {
      List<LatLng> points = [];
      Map<String, dynamic> feature = features[i];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      for (var data in coordinates) {
        points.add(
          LatLng(data[1], data[0]),
        );
      }

      Polyline temporaryPolyline = Polyline(
        polylineId: PolylineId('drrp_polyline$i'),
        color: Colors.black,
        width: 5,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
        points: points,
        patterns: [
          PatternItem.dash(10),
          PatternItem.gap(10),
        ],
      );

      polylines.add(temporaryPolyline);
    }
    polylines.addAll(_pciPolylines);
    _showCircularProgress.value = false;
    jsonData = {};
  }
}
