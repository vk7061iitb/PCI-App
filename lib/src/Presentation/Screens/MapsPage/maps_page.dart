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
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import '../../../../Objects/data.dart';
import '../../Controllers/map_page_controller.dart';
import 'widget/map_page_legends.dart';
import 'widget/maptype_dropdown.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;

    final GlobalKey gKey = GlobalKey();
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(
                () {
                  return RepaintBoundary(
                    key: gKey,
                    child: GoogleMap(
                      buildingsEnabled: false,
                      mapType: mapPageController.backgroundMapType,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          0,
                          0,
                        ),
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) async {
                        mapPageController.setGoogleMapController = controller;
                        await mapPageController.animateToLocation(
                          mapPageController.getMinLat,
                          mapPageController.getMaxLat,
                        );
                        mapPageController.isMapCreated.value = true;
                      },
                      polylines: mapPageController.pciPolylines,
                      zoomControlsEnabled: false,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Obx(
                () => Container(
                  padding: const EdgeInsets.all(10),
                  width: w,
                  height: h * 0.08,
                  color: backgroundColor,
                  child: FittedBox(
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            try {
                              mapPageController.isDrrpLayerVisible =
                                  !mapPageController.isDrrpLayerVisible;
                              if (mapPageController.isDrrpLayerVisible) {
                                mapPageController.showIndicator.value = true;
                                mapPageController.plotDRRPLayer().then((_) {
                                  Future.delayed(const Duration(seconds: 1))
                                      .then((_) {
                                    mapPageController.showIndicator.value =
                                        false;
                                  });
                                });
                                return;
                              }
                              // clear the DRRP layer
                              mapPageController.showIndicator.value = true;
                              await mapPageController
                                  .removeDRRPLayer()
                                  .then((_) {
                                Future.delayed(const Duration(seconds: 1))
                                    .then((_) {
                                  mapPageController.showIndicator.value = false;
                                });
                              });
                            } catch (e) {
                              // Handle any errors that occur during the onTap execution
                              customGetSnackBar(
                                  "Error",
                                  "'Error toggling DRRP layer: $e'",
                                  Icons.error_outline);
                              logger.e('Error toggling DRRP layer: $e');
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              mapPageController.isDrrpLayerVisible
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha:0.05),
                            ),
                          ),
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
                        const Gap(10),
                        TextButton(
                          onPressed: () async {
                            if (mapPageController.showIndicator.value) return;
                            mapPageController.showPCIlabel =
                                !mapPageController.showPCIlabel;
                            logger.i(mapPageController.pciPolylines.length);
                            mapPageController.showIndicator.value = true;
                            await mapPageController.plotRoadData().then((_) {
                              Future.delayed(const Duration(seconds: 1))
                                  .then((_) {
                                mapPageController.showIndicator.value = false;
                              });
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.blue.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                // tick icon
                                mapPageController.showPCIlabel
                                    ? Icons.insights_rounded
                                    : Icons.speed_rounded,
                                color: Colors.blue,
                                size:
                                    MediaQuery.textScalerOf(context).scale(20),
                              ),
                              const Gap(10),
                              Text(
                                mapPageController.showPCIlabel
                                    ? "PCI (Prediction)"
                                    : "PCI (Velocity)",
                                style: GoogleFonts.inter(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(18),
                                ),
                              ),
                              const Gap(5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: h * 0.08,
              left: 0,
              child: SizedBox(
                width: w,
                child: Obx(
                  () {
                    return mapPageController.showIndicator.value
                        ? LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue[800]!),
                          )
                        : const SizedBox();
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              // Row containing the buttons to zoom, clear, change map type and view road statistics
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Road Statistics Button //
                  /*  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: w * 0.12,
                      height: w * 0.12,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: IconButton(
                          onPressed: () {
                            Get.bottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.white,
                              MapPageRoadStatistics(
                                roadStats: mapPageController.roadStats,
                                selectedJourney:
                                    mapPageController.selectedRoads,
                                roadOutputData:
                                    mapPageController.roadOutputData,
                              ),
                            );
                          },
                          icon: SvgPicture.asset(
                            assetsPath.stats,
                            height: 30,
                            width: 30,
                          ),
                          tooltip: 'Road Statistics',
                        ),
                      ),
                    ),
                  ),
                  */
                  const Gap(20),
                  // Zoom to Fit Button //
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: w * 0.12,
                      height: w * 0.12,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: IconButton(
                          onPressed: () async {
                            Future.delayed(const Duration(milliseconds: 500))
                                .then(
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
                    ),
                  ),
                  const Gap(20),
                  // Map Type Dropdown //
                  Container(
                    width: w * 0.12,
                    height: w * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: const SelectMapType(),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Positioned(
                bottom: mapPageController.legendPos.value.dy,
                right: mapPageController.legendPos.value.dx,
                child: LongPressDraggable(
                  rootOverlay: false,
                  onDragEnd: (details) {
                    mapPageController.legendPos.value = Offset(
                      w - details.offset.dx - w * 0.2,
                      h - details.offset.dy - h * 0.2,
                    );
                  },
                  feedback: SizedBox(
                    width: w * 0.2,
                    height: h * 0.2,
                    child: FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      child: const Legends(),
                    ),
                  ),
                  child: SizedBox(
                    width: w * 0.2,
                    height: h * 0.2,
                    child: FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      child: const Legends(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
