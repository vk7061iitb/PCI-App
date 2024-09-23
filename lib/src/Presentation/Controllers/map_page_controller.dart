import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Models/pci_data.dart';
import '../../Models/stats_data.dart';

class MapPageController extends GetxController {
  final RxBool _isDrrpLayerVisible = false.obs;
  final RxSet<Polyline> _polylines = <Polyline>{}.obs;
  final RxList<Road> _roads = <Road>[].obs;
  Rx<GoogleMapController>? _googleMapController;
  final RxList<Map<String, dynamic>> _roadOutputDataQuery =
      <Map<String, dynamic>>[].obs;

  // getters
  bool get getIsDrrpLayerVisible => _isDrrpLayerVisible.value;
  Set<Polyline> get getPolylines => _polylines.toSet();
  List<Road> get getRoads => _roads;
  GoogleMapController? get getGoogleMapController =>
      _googleMapController?.value;
  List<Map<String, dynamic>> get getRoadOutputDataQuery => _roadOutputDataQuery;

  // setters
  set setIsDrrpLayerVisible(bool value) => _isDrrpLayerVisible.value = value;
  set setPolylines(Set<Polyline> value) => _polylines.addAll(value);
  set setRoads(List<Road> value) => _roads.addAll(value);
  set setGoogleMapController(GoogleMapController? value) =>
      _googleMapController?.value = value!;
  set setRoadOutputDataQuery(List<Map<String, dynamic>> value) =>
      _roadOutputDataQuery.addAll(value);

  void plotRoadData() {
    for (var road in _roadOutputDataQuery) {
      String roadName = road["roadName"];
      List<dynamic> labels = jsonDecode(road["labels"]);
      dynamic roadStats = jsonDecode(road["stats"]);
      List<RoadPCIdata> roadPciData = [];
      List<RoadStats> roadStatsList = [];

      for (int i = 1; i <= 5; i++) {
        String key = "$i";
        roadStatsList.add(RoadStats(
          pci: roadStats[roadStats[key]],
          avgVelocity: roadStats[key]['avg_velocity'],
          distanceTravelled: roadStats[key]['distance_travelled'],
          numberOfSegments: roadStats[key]['number_of_segments'],
        ));
      }

      for (int i = 1; i < labels.length; i++) {
        double avgVelocity =
            (labels[i]['velocity'] + labels[i - 1]['velocity']) / 2;
        double prediction = max(
            double.parse(labels[i]['prediction'].toString()),
            double.parse(labels[i - 1]['prediction'].toString()));

        roadPciData.add(RoadPCIdata(
          latitude: labels[i]['latitude'],
          longitude: labels[i]['longitude'],
          velocity: avgVelocity,
          prediction: prediction,
        ));

        _roads.add(Road(
          roadName: roadName,
          roadPciData: roadPciData,
          roadStats: roadStatsList,
        ));
      }
    }
  }
}
