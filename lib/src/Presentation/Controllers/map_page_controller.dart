import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import '../../../Utils/cal_map_bounds.dart';
import '../../../Utils/plot_map_isolate.dart';
import '../../Models/stats_data.dart';

class MapPageController extends GetxController {
  final RxBool _isDrrpLayerVisible = false.obs;
  final RxSet<Polyline> _pciPolylines = <Polyline>{}.obs;
  final Set<Polyline> _drrpPolylines = <Polyline>{};
  GoogleMapController? _googleMapController;
  List<List<Map<String, dynamic>>> roadOutputData =
      <List<Map<String, dynamic>>>[];
  List<Map<String, dynamic>> selectedRoads = [];

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
  RxBool showIndicator = false.obs;

  Rx<Offset> legendPos = Offset(10, 10).obs;

  // Getters
  bool get isDrrpLayerVisible => _isDrrpLayerVisible.value;
  RxSet<Polyline> get pciPolylines => _pciPolylines.toSet().obs;
  LatLng get getMinLat => _minLat;
  LatLng get getMaxLat => _maxLat;
  List<RoadStats> get getRoadStats => roadStats;
  GoogleMapController? get getGoogleMapController => _googleMapController;
  List<MapType> get googlemapType => _googlemapType.toList();
  List<String> get getMapType => mapType;
  MapType get backgroundMapType => _backgroundMapType.value;
  String get dropdownvalue => dropdownValue.value;
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
  set dropdownvalue(String value) => dropdownValue.value = value;
  set showProgress(bool value) => _showCircularProgress.value = value;
  set showPCIlabel(bool value) => _showPCIlabel.value = value;

  /// Clears the data stored in the controller.
  ///
  /// This method is used to reset or clear any data that the controller
  /// might be holding. It can be useful when you need to refresh the state
  /// or remove any temporary data.
  void clearData() {
    roadStats.clear();
    _pciPolylines.clear();
    roadOutputData.clear();
    selectedRoads.clear();

    _minLat = const LatLng(0, 0);
    _maxLat = const LatLng(0, 0);
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
  Future<void> plotRoadData() async {
    _pciPolylines.clear();
    roadStats.clear();
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
      _pciPolylines.addAll(res['pciPolylines']);
      _minLat = res['minLat'];
      _maxLat = res['maxLat'];
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
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 11));
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
