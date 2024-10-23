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
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'widget/maptype_dropdown.dart';
import 'widget/road_stats.dart';

class MapPage extends StatelessWidget {
  MapPage({super.key});

  final AccDataController _accDataController = Get.find();

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SizedBox(
                child: SizedBox(child: Obx(() {
                  return GoogleMap(
                    mapType: mapPageController.backgroundMapType,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_accDataController.devicePosition.latitude,
                          _accDataController.devicePosition.longitude),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      mapPageController.setGoogleMapController = controller;

                      mapPageController.animateToLocation(
                          mapPageController.getMinLat,
                          mapPageController.getMaxLat);
                    },
                    polylines: mapPageController.getPolylines,
                    zoomControlsEnabled: false,
                  );
                })),
              ),
            ),
            Positioned(
                top: 10,
                left: 10,
                child: Obx(
                  () {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: mapPageController.isDrrpLayerVisible
                              ? Colors.blue
                              : Colors.black38,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: InkWell(
                          onTap: () async {
                            try {
                              mapPageController.isDrrpLayerVisible =
                                  !mapPageController.isDrrpLayerVisible;
                              if (mapPageController.isDrrpLayerVisible) {
                                mapPageController.plotDRRPLayer();
                              } else {
                                mapPageController.polylines.clear();
                                mapPageController.polylines
                                    .addAll(mapPageController.pciPolylines);
                              }
                            } catch (e) {
                              // Handle any errors that occur during the onTap execution
                              debugPrint('Error toggling DRRP layer: $e');
                            }
                          },
                          child: Row(
                            children: [
                              const Gap(10),
                              Icon(
                                Icons.layers_outlined,
                                size:
                                    MediaQuery.textScalerOf(context).scale(20),
                                color: mapPageController.isDrrpLayerVisible
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                              const Gap(5),
                              Text(
                                "DRRP Layer",
                                style: GoogleFonts.inter(
                                  color: mapPageController.isDrrpLayerVisible
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(18),
                                ),
                              ),
                              const Gap(10),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
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
                        Future.delayed(const Duration(milliseconds: 500)).then(
                          (value) => mapPageController.animateToLocation(
                              mapPageController.getMinLat,
                              mapPageController.getMaxLat),
                        );
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
                        mapPageController.polylines.clear();
                        //polylineObj.clear();
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
                  const SelectMapType(),
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
                        Get.bottomSheet(
                          isDismissible: true,
                          backgroundColor: Colors.white,
                          RoadStatistics(
                              roadStats: mapPageController.getRoadStats),
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
