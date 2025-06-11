import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:file_picker/file_picker.dart';
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
  final RxString backgroundMapLayerName =
      "".obs; // currently plotted background layer (local file)
  final RxSet<Polyline> _pciPolylines =
      <Polyline>{}.obs; // polylines shown on the map page
  final Set<Polyline> _backgroundPolylines = <Polyline>{};
  GoogleMapController? _googleMapController;
  List<List<Map<String, dynamic>>> roadOutputData = <List<
      Map<String,
          dynamic>>>[]; // contains the pci data for seleceted file(s) to be plotte
  List<Map<String, dynamic>> selectedRoads =
      []; // contains the metadat for selected file(s) to be plotted

  LatLng _southwest = const LatLng(0, 0);
  LatLng _northeast = const LatLng(0, 0);
  RxBool isPredPCICaptured = false.obs;
  RxBool isVelPCICaptured = false.obs;
  List<List<RoadStatsOverall>> roadStats = [];
  List<List<RoadStatsChainage>> segStats = [];
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
  List<List<RoadStatsOverall>> get getRoadStats => roadStats;
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
    _isDrrpLayerVisible.value = false;
    backgroundMapLayerName.value = "";
    showIndicator.value = false;
    showPCIlabel = true;
    _backgroundMapType.value = MapType.normal;
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
    // reset the data
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
        'drrpPolylines': _backgroundPolylines,
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

    // logger.i("No. of plolylines = ${_pciPolylines.length}");
  }

  // Function to animate the camera to the location of the polylines
  /// Animates the map view to the specified location bounds.
  Future<void> animateToLocation(LatLng min, LatLng max) async {
    LatLngBounds bounds = calculateBounds(min, max);
    _googleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20));
  }

// This function is used to remove the background layer from the map.
  void removeBackgroundLayer() async {
    for (Polyline polyline in _backgroundPolylines) {
      _pciPolylines.remove(polyline);
    }
    _backgroundPolylines.clear();
  }

  // plot background layer
  void plotMapBackground({
    bool plotDRRPLayer = true,
    bool removeAllBackgroundLayer = false,
  }) async {
    try {
      if (removeAllBackgroundLayer) {
        removeBackgroundLayer();
        _isDrrpLayerVisible.value = false;
        backgroundMapLayerName.value = "";
        return;
      }

      // if drrp is already plotted and plotdrrp is true
      if (plotDRRPLayer && _isDrrpLayerVisible.value) {
        return;
      }

      String geoJsonString;

      if (plotDRRPLayer) {
        geoJsonString = await rootBundle.loadString(assetsPath.roadDRRP);
      } else {
        // open the file
        dynamic fileRes = await openFile();
        File file = fileRes[0];
        String filePath = fileRes[1];

        removeBackgroundLayer();

        // received the file
        geoJsonString = await file.readAsString();
        backgroundMapLayerName.value = filePath;
        logger.i(backgroundMapLayerName.value);
      }

      // make polyline and plot it
      Map<String, dynamic> jsonData = jsonDecode(geoJsonString);
      List<dynamic> features = jsonData["features"];
      for (int i = 0; i < features.length; i++) {
        List<LatLng> points = [];
        Map<String, dynamic> feature = features[i];

        /// polyline feature type can be "LineString" or "MultiLineString"
        if (feature["geometry"]["type"].toString() == "LineString") {
          // insert
          List<dynamic> coordinates = feature['geometry']['coordinates'];
          for (var data in coordinates) {
            points.add(
              LatLng(data[1], data[0]),
            );
          }
          // all the polyline
          Polyline tempPolyline = Polyline(
            polylineId: PolylineId('b_layer$i'),
            color: Colors.black,
            width: 2,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            jointType: JointType.round,
            points: points,
          );
          _backgroundPolylines.add(tempPolyline);

          /// insert the multilinstring
        } else {
          // take care of coordinates
          List<dynamic> coordinateList = feature['geometry']['coordinates'];
          int j = 0;
          for (var coordinates in coordinateList) {
            // each coordinates => points of a single polyline
            for (var data in coordinates) {
              points.add(
                LatLng(data[1], data[0]),
              );
            }
            j++;
            // add the polyline
            Polyline tempPolyline = Polyline(
              polylineId: PolylineId('b_layer$i$j'),
              color: Colors.black,
              width: 2,
              endCap: Cap.roundCap,
              startCap: Cap.roundCap,
              jointType: JointType.round,
              points: points,
            );
            _backgroundPolylines.add(tempPolyline);
          }
        }
      }
      /// update the indicators
      if (plotDRRPLayer) {
        backgroundMapLayerName.value = "";
        _isDrrpLayerVisible.value = true;
      } else {
        _isDrrpLayerVisible.value = false;
      }

      _pciPolylines.addAll(_backgroundPolylines);
    } catch (e) {
      logger.i(e);
      customGetSnackBar("Error", e.toString(), Icons.error_outline);
    }
  }

  Future<List<dynamic>> openFile() async {
    File? file;
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      dialogTitle: 'Please select the background map layer file',
    );
    if (res != null) {
      file = File(res.files.single.path!);
    }
    if (file == null) {
      return [];
    }
    return [file, res!.files.single.name];
  }
}
