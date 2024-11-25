import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Functions/get_road_color.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Screens/MapsPage/widget/polyline_bottom_sheet.dart';
import '../../../Functions/cal_map_bounds.dart';
import '../../../Functions/vel_to_pci.dart';
import '../../Models/stats_data.dart';

class MapPageController extends GetxController {
  final RxBool _isDrrpLayerVisible = false.obs;
  final RxSet<Polyline> _pciPolylines = <Polyline>{}.obs;
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
  final RxBool _showPCIlabel = true.obs;
  final RxBool _showIndicator = false.obs;

  // variables to store the currently open road's metadata
  Map<String, dynamic> currentRoad = <String, dynamic>{};

  // Getters
  bool get isDrrpLayerVisible => _isDrrpLayerVisible.value;
  RxSet<Polyline> get pciPolylines => _pciPolylines.toSet().obs;
  LatLng get getMinLat => _minLat;
  LatLng get getMaxLat => _maxLat;
  List<Road> get getRoads => roads;
  List<RoadStats> get getRoadStats => roadStats;
  GoogleMapController? get getGoogleMapController => _googleMapController;
  List<MapType> get googlemapType => _googlemapType.toList();
  List<String> get getMapType => mapType;
  MapType get backgroundMapType => _backgroundMapType.value;
  String get dropdownvalue => dropdownValue.value;
  bool get showProgress => _showCircularProgress.value;
  bool get showPCIlabel => _showPCIlabel.value;
  bool get showIndicator => _showIndicator.value;

  // Setters
  set isDrrpLayerVisible(bool value) => _isDrrpLayerVisible.value = value;
  set pciPolylines(Set<Polyline> value) => _pciPolylines.addAll(value);
  set setRoads(List<Road> value) => roads.addAll(value);
  set setGoogleMapController(GoogleMapController? value) =>
      _googleMapController = value;
  set setMapType(List<String> value) => mapType.addAll(value);
  set googlemapType(List<MapType> value) => _googlemapType.addAll(value);
  set backgroundMapType(MapType value) => _backgroundMapType.value = value;
  set dropdownvalue(String value) => dropdownValue.value = value;
  set showProgress(bool value) => _showCircularProgress.value = value;
  set showPCIlabel(bool value) => _showPCIlabel.value = value;
  set showIndicator(bool value) => _showIndicator.value = value;

  void clearPolylines() {
    _pciPolylines.clear();
  }

  void setRoadStatistics(List<Map<String, dynamic>> query) {
    if (query.isEmpty) {
      return;
    }
    if (roadStats.isNotEmpty) {
      roadStats.clear();
    }
    for (var road in query) {
      String roadName = road["roadName"];
      dynamic roadStatistics = jsonDecode(road["stats"]);
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
    }
  }

  // fuction to plot the road data on the map
  Future<void> plotRoadData() async {
    logger.d("plotting road data...");
    roadStats.clear();
    _pciPolylines.clear();
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
        avgVelocity *= 3.6; // convert m/s to kmph
        double prediction = max(
            double.parse(labels[i]['prediction'].toString()),
            double.parse(labels[i - 1]['prediction'].toString()));
        double velocityPCI = velocityToPCI(avgVelocity);
        // Add the polyline
        Polyline tempPolylne = Polyline(
          consumeTapEvents: true,
          polylineId: PolylineId("$roadName$i"),
          color: _showPCIlabel.value
              ? getRoadColor(prediction)
              : getVelocityColor(avgVelocity),
          width: 5,
          endCap: Cap.roundCap,
          startCap: Cap.roundCap,
          jointType: JointType.round,
          points: [
            LatLng(labels[i - 1]['latitude'], labels[i - 1]['longitude']),
            LatLng(labels[i]['latitude'], labels[i]['longitude']),
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
        _pciPolylines.add(tempPolylne);
      }
    }
  }

  // Function to animate the camera to the location of the polylines
  Future<void> animateToLocation(LatLng min, LatLng max) async {
    LatLngBounds bounds = calculateBounds(min, max);
    _googleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 11));
  }

  // This function is used to plot the DRRP layer on the map.
  // It reads the geojson file containing the DRRP data and plots the polylines on the map.
  Future<void> plotDRRPLayer() async {
    _showCircularProgress.value = true;
    Map<String, dynamic> jsonData = {};
    List<dynamic> features = [];
    String geoJsonString = await rootBundle.loadString(assetsPath.roadDRRP);

    jsonData = jsonDecode(geoJsonString);
    features = jsonData['features'];

    _pciPolylines.clear();

    for (int i = 0; i < features.length; i++) {
      List<LatLng> points = [];
      Map<String, dynamic> feature = features[i];
      List<dynamic> coordinates = feature['geometry']['coordinates'];
      for (var data in coordinates) {
        points.add(
          LatLng(data[1], data[0]),
        );
      }

      Polyline tempPolyline = Polyline(
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
      _pciPolylines.add(tempPolyline);
    }
    _showCircularProgress.value = false;
  }
}
