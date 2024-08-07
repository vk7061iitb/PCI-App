/*
  This file contains the code for the map page. The map page contains the Google Map widget, 
  which displays the output road's data. The road data is plotted as polylines on the map. 
  It contains buttons to zoom in on the map, clear the map, and view road statistics. 
  The map page also contains a button to toggle the DRRP layer on and off. 
  The DRRP layer is plotted on the map as dashed lines. The map page also contains a dropdown to 
  select the map type (satellite, terrain, etc.).
 */

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import '../../../../Functions/get_road_color.dart';
import '../../../../Functions/plot_drrp_layer.dart';
import '../../../../Objects/data.dart';
import '../../../Models/polyline_data.dart';
import 'widget/path_feature.dart';
import 'widget/maptype_dropdown.dart';
import 'widget/road_stats.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isDrrpLayerVisible = false;
  final AccDataController _accDataController = Get.find();
  late GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    plotMap(jsonData);
  }

  @override
  void dispose() {
    super.dispose();
    jsonData = {};
    outputStats.clear();
    polylines.clear();
    polylineObj.clear();
  }

  // Function to plot the map with Poly-lines
  void plotMap(Map<String, dynamic> jsonData) async {
    if (jsonData.isEmpty) {
      return;
    }
    debugPrint("Plotting map...");
    features = jsonData['geoJsonFeatures'];
    for (int i = 0; i < features.length; i++) {
      List<LatLng> points = [];
      Map<String, dynamic> feature = features[i];
      List<dynamic> coordinates = feature['geometry']['polylineCoordinates'];
      Map<String, dynamic> myMap = feature['polylineProperties'];
      for (var data in coordinates) {
        points.add(
          LatLng(data[1], data[0]),
        );
      }
      Polyline temporaryPolyline = Polyline(
        consumeTapEvents: true,
        polylineId: PolylineId('plotted_polyline$i'),
        color: getRoadColor(feature['polylineProperties']['PCI'].toString()[0]),
        width: 10,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
        points: points,
        onTap: () {
          if (kDebugMode) {
            print('Polyline$i tapped!');
          }
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return PolylineFeature(
                polylineIndex: i,
              );
            },
          );
          setState(() {});
        },
      );

      Properties featureProperties = Properties(
        attributeKeys: myMap.keys.toList(),
        attributeValues: myMap.values.toList(),
      );

      polylineObj.add(
        PolylineData(
          polyline: temporaryPolyline,
          polylineIndex: i,
          polylineAttributes: featureProperties,
        ),
      );
      polylines.add(temporaryPolyline);
    }
    debugPrint("Map plotted!");
    // Zoom the map
    await animateToLocation();
  }

  // Function to animate the camera to the location of the polylines
  Future<void> animateToLocation() async {
    double minLat = features[0]['geometry']['polylineCoordinates'][0][1];
    double minLng = features[0]['geometry']['polylineCoordinates'][0][0];
    double maxLat =
        features[features.length - 1]['geometry']['polylineCoordinates'][0][1];
    double maxLng =
        features[features.length - 1]['geometry']['polylineCoordinates'][0][0];

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

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 11));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SizedBox(
                child: SizedBox(
                  child: GoogleMap(
                    mapType: googleMapType,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_accDataController.devicePosition.latitude,
                          _accDataController.devicePosition.longitude),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    polylines: polylines,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isDrrpLayerVisible ? Colors.blue : Colors.black38,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: InkWell(
                    onTap: () async {
                      isDrrpLayerVisible = !isDrrpLayerVisible;
                      if (isDrrpLayerVisible) {
                        await plotDRRPLayer();
                        setState(() {});
                      } else {
                        List<Polyline> polylinesToAdd = [];
                        for (var element in polylines) {
                          if (element.polylineId.value
                              .contains("plotted_polyline")) {
                            polylinesToAdd.add(element);
                          }
                        }
                        polylines.clear();
                        polylines.addAll(polylinesToAdd);
                        setState(() {});
                      }
                    },
                    child: Row(
                      children: [
                        const Gap(10),
                        Icon(
                          Icons.layers_outlined,
                          size: MediaQuery.textScalerOf(context).scale(20),
                          color:
                              isDrrpLayerVisible ? Colors.blue : Colors.black,
                        ),
                        const Gap(5),
                        Text(
                          "DRRP Layer",
                          style: GoogleFonts.inter(
                            color:
                                isDrrpLayerVisible ? Colors.blue : Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(18),
                          ),
                        ),
                        const Gap(10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              // Row containing the buttons to zoom, clear, change map type and view road statistics
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Gap(10),
                  // Zoom to Fit Button //
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        plotMap(jsonData);
                        Future.delayed(const Duration(milliseconds: 500)).then(
                          (value) => animateToLocation(),
                        );
                        setState(() {});
                      },
                      tooltip: 'Zoom to Fit',
                      icon: const Icon(
                        Icons.zoom_out_map,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                  const Gap(20),
                  // Clear Map Button //
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        polylines.clear();
                        polylineObj.clear();
                        setState(() {});
                      },
                      tooltip: 'Clear Map',
                      icon: Icon(
                        Icons.clear_all_rounded,
                        color: Colors.black,
                        size: MediaQuery.textScalerOf(context).scale(30),
                      ),
                    ),
                  ),
                  const Gap(20),
                  // Map Type Dropdown //
                  MapTypeDropdown(
                    onChanged: (p0) => setState(() {}),
                  ),
                  const Gap(20),
                  // Road Statistics Button //
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return RoadStats(
                              outputStats: outputStats,
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        color: Colors.black,
                        Icons.bar_chart_rounded,
                        size: 30,
                      ),
                      tooltip: 'Road Statistics',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
