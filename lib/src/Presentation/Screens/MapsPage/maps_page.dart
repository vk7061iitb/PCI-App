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
import 'package:pciapp/Utils/font_size.dart';
import '../../../../Objects/data.dart';
import '../../Controllers/map_page_controller.dart';
import 'widget/map_page_legends.dart';
import 'widget/maptype_dropdown.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    TextStyle normalStyle = GoogleFonts.inter(
      color: textColor,
      fontSize: fs.bodyTextFontSize,
      fontWeight: FontWeight.w400,
    );
    final GlobalKey gKey = GlobalKey();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if(didPop){
          mapPageController.clearData();
          logger.d("exited the maps page");
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  key: gKey,
                  child: Obx(() {
                    return GoogleMap(
                      buildingsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      liteModeEnabled: false,
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
                    );
                  }),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                // Row containing the buttons to zoom, clear, change map type and view road statistics
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
              Positioned(
                top: 10,
                right: 10,
                child: SizedBox(
                  width: w * 0.075,
                  child: FittedBox(
                    child: Column(
                      children: [
                        for (var entry in legend.entries)
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                color: entry.value,
                                margin: EdgeInsets.only(right: 6),
                              ),
                              Text(entry.key),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.25, // Starting height (10% of screen)
                  minChildSize: 0.15, // Minimum height
                  maxChildSize: 0.4,
                  builder: (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(blurRadius: 10, color: Colors.grey.shade300)
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          const Gap(10),
                          Center(
                            child: Container(
                              width: w * 0.1,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const Gap(15),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.layers_outlined,
                                  size: MediaQuery.textScalerOf(context)
                                      .scale(20),
                                  color: Colors.black,
                                ),
                                const Gap(10),
                                Text(
                                  "Background Layer",
                                  style: normalStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // background layer
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      mapPageController.plotMapBackground(),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: RepaintBoundary(
                                    child: Obx(
                                      () => Text(
                                        "DRRP Layer",
                                        style: normalStyle.copyWith(
                                          color: mapPageController
                                                  .isDrrpLayerVisible
                                              ? activeColor
                                              : textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                Obx(
                                  () => Expanded(
                                    child: Text(
                                      mapPageController
                                          .backgroundMapLayerName.value,
                                      style: normalStyle.copyWith(
                                          color: activeColor),
                                          overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Gap(5),

                          // open other GeoJSON file
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () => mapPageController
                                      .plotMapBackground(plotDRRPLayer: false),
                                  child: Text(
                                    "Open file",
                                    style: normalStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: activeColor,
                                    ),
                                  ),
                                ),

                                // remove all
                                TextButton(
                                  onPressed: () =>
                                      mapPageController.plotMapBackground(
                                          removeAllBackgroundLayer: true),
                                  child: Text(
                                    "Remove All",
                                    style: normalStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: activeColor,
                                      overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // foreground layer
                          const Gap(15),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.layers_outlined,
                                  size: MediaQuery.textScalerOf(context)
                                      .scale(20),
                                  color: Colors.black,
                                ),
                                const Gap(10),
                                Text(
                                  "Foreground Layer",
                                  style: normalStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (mapPageController.showPCIlabel ==
                                        true) {
                                      // already plotted
                                      return;
                                    }
                                    mapPageController.showPCIlabel = true;
                                    mapPageController.plotRoadData();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: RepaintBoundary(
                                    child: Obx(
                                      () => Text(
                                        "PCI (Prediction)",
                                        style: normalStyle.copyWith(
                                          color: mapPageController.showPCIlabel
                                              ? Colors.blue
                                              : textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                TextButton(
                                  onPressed: () {
                                    if (mapPageController.showPCIlabel ==
                                        false) {
                                      // already plotted
                                      return;
                                    }
                                    mapPageController.showPCIlabel = false;
                                    mapPageController.plotRoadData();
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                      Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: RepaintBoundary(
                                    child: Obx(
                                      () => Text(
                                        "PCI (Velocity)",
                                        style: normalStyle.copyWith(
                                          color: mapPageController.showPCIlabel
                                              ? textColor
                                              : Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
