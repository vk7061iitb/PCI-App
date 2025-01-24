import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/cal_map_bounds.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';
import '../../../Utils/plot_map_isolate.dart';
import '../../Models/stats_data.dart';

class MapPageController extends GetxController {
  final RxBool _isDrrpLayerVisible = false.obs; // used to toggle DRRP Layers
  final RxSet<Polyline> _pciPolylines =
      <Polyline>{}.obs; // polylines shown on the map page
  final Set<Polyline> _drrpPolylines = <Polyline>{};
  GoogleMapController? _googleMapController;
  List<List<Map<String, dynamic>>> roadOutputData = <List<
      Map<String,
          dynamic>>>[]; // contains the data of all selected journies in a list
  List<Map<String, dynamic>> selectedRoads =
      []; // used for multipe selection of jouurney data

  LatLng _southwest = const LatLng(0, 0);
  LatLng _northeast = const LatLng(0, 0);
  RxBool isPredPCICaptured = false.obs;
  RxBool isVelPCICaptured = false.obs;
  List<List<RoadStats>> roadStats = [];
  List<List<SegStats>> segStats = [];
  final Rx<MapType> _backgroundMapType = MapType.normal.obs;
  final RxList<MapType> _googlemapType = [
    MapType.normal,
    MapType.satellite,
    MapType.hybrid,
    MapType.terrain,
    MapType.none
  ].obs;

  final RxBool _showCircularProgress = false.obs;
  final RxBool _showPCIlabel = true.obs;
  RxBool showIndicator = false.obs;
  Rx<Offset> legendPos = Offset(10, 10).obs;
  Rx<bool> isMapCreated = false.obs;

  // Getters
  bool get isDrrpLayerVisible => _isDrrpLayerVisible.value;
  RxSet<Polyline> get pciPolylines => _pciPolylines.toSet().obs;
  LatLng get getMinLat => _southwest;
  LatLng get getMaxLat => _northeast;
  List<List<RoadStats>> get getRoadStats => roadStats;
  GoogleMapController? get getGoogleMapController => _googleMapController;
  List<MapType> get googlemapType => _googlemapType.toList();
  List<String> get getMapType => mapType;
  MapType get backgroundMapType => _backgroundMapType.value;
  bool get showProgress => _showCircularProgress.value;
  bool get showPCIlabel => _showPCIlabel.value;

  // Setters
  set isDrrpLayerVisible(bool value) => _isDrrpLayerVisible.value = value;
  set pciPolylines(Set<Polyline> value) => _pciPolylines.addAll(value);
  set setGoogleMapController(GoogleMapController? value) =>
      _googleMapController = value;
  set setMapType(List<String> value) => mapType.addAll(value);
  set googlemapType(List<MapType> value) => _googlemapType.addAll(value);
  set backgroundMapType(MapType value) => _backgroundMapType.value = value;
  set showProgress(bool value) => _showCircularProgress.value = value;
  set showPCIlabel(bool value) => _showPCIlabel.value = value;

  /// Clears the data stored in the controller.
  ///
  /// This method is used to reset or clear any data that the controller
  /// might be holding. It can be useful when you need to refresh the state
  /// or remove any temporary data.
  void clearData() {
    isMapCreated.value = false;
    roadStats.clear();
    segStats.clear();
    _pciPolylines.clear();
    roadOutputData.clear();
    selectedRoads.clear();

    _southwest = const LatLng(0, 0);
    _northeast = const LatLng(0, 0);
  }

  /// Plots road data on the map.
  ///
  /// This method fetches and displays road data on the map.
  /// It is an asynchronous operation and should be awaited.
  ///
  /// Throws:
  /// - `Exception` if there is an error while fetching or plotting the data.
  ///
  /// Usage:
  /// ```dart
  /// await plotRoadData();
  /// ```
  void takeSS() async {}

  Future<void> plotRoadData() async {
    _pciPolylines.clear();
    roadStats.clear();
    segStats.clear();
    isMapCreated.value = false;
    logger.d("plotting road data...");

    try {
      final receivePort = ReceivePort("plotRoadData(MapPageController)");
      final isoData = {
        'sendPort': receivePort.sendPort,
        'roadOutputData': roadOutputData,
        'showPCIlabel': _showPCIlabel.value,
        'selectedRoads': selectedRoads,
        'drrpPolylines': _drrpPolylines,
      };

      await Isolate.spawn(plotMapIsolate, isoData);
      final res = await receivePort.first as Map<String, dynamic>;
      roadStats = res['roadStats'];
      segStats = res['segStats'];
      _pciPolylines.addAll(res['pciPolylines']);
      _southwest = res['southwest'];
      _northeast = res['northeast'];
    } catch (e) {
      customGetSnackBar(
          "Plotting Error",
          "An error occurred while plotting the road data.",
          Icons.error_outline);
      logger.e(e.toString());
    }

    logger.i("No. of plolylines = ${_pciPolylines.length}");
  }

  // Function to animate the camera to the location of the polylines
  /// Animates the map view to the specified location bounds.
  ///
  /// This method takes two [LatLng] parameters, [min] and [max], which represent
  /// the minimum and maximum coordinates of the bounding box to which the map
  /// should be animated.
  ///
  /// The animation is performed asynchronously.
  ///
  /// - [min]: The minimum [LatLng] coordinate of the bounding box.
  /// - [max]: The maximum [LatLng] coordinate of the bounding box.
  ///
  /// Returns a [Future] that completes when the animation is finished.
  Future<void> animateToLocation(LatLng min, LatLng max) async {
    LatLngBounds bounds = calculateBounds(min, max);
    _googleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20));
  }

  // This function is used to plot the DRRP layer on the map.
  // It reads the geojson file containing the DRRP data and plots the polylines on the map.
  Future<void> plotDRRPLayer() async {
    Map<String, dynamic> jsonData = {};
    List<dynamic> features = [];
    String geoJsonString = await rootBundle.loadString(assetsPath.roadDRRP);

    jsonData = jsonDecode(geoJsonString);
    features = jsonData['features'];

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
        width: 2,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
        points: points,
      );
      _drrpPolylines.add(tempPolyline);
    }
    _pciPolylines.addAll(_drrpPolylines);
  }

// This function is used to remove the DRRP layer from the map.
  Future<void> removeDRRPLayer() async {
    for (Polyline polyline in _drrpPolylines) {
      _pciPolylines.remove(polyline);
    }
    _drrpPolylines.clear();
  }
}
