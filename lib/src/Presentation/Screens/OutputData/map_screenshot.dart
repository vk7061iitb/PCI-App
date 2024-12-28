import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import '../../../../Utils/font_size.dart';
import '../../Controllers/map_page_controller.dart';
import '../MapsPage/widget/maptype_dropdown.dart';
import 'pdf_preview.dart';

class MapScreenshot extends StatelessWidget {
  const MapScreenshot({super.key});

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final MapPageController mapPageController = Get.find<MapPageController>();
    final OutputDataController outputDataController =
        Get.find<OutputDataController>();
    Uint8List predBasedImdData = Uint8List.fromList([]);
    Uint8List velBasedImdData = Uint8List.fromList([]);
    mapPageController.showPCIlabel = true;
    mapPageController.isPredPCICaptured.value = false;
    mapPageController.isVelPCICaptured.value = false;
    double w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      floatingActionButton: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!mapPageController.isPredPCICaptured.value &&
                !mapPageController.isVelPCICaptured.value)
              InkWell(
                onTap: () async {
                  await outputDataController.takeSS().then((val) async {
                    mapPageController.showPCIlabel = false;
                    predBasedImdData = val;
                    await mapPageController.plotRoadData().then((_) {
                      mapPageController.isPredPCICaptured.value = true;
                    });
                  });
                },
                child: _buildButton("Prediction Based", context),
              ),
            if (mapPageController.isPredPCICaptured.value &&
                !mapPageController.isVelPCICaptured.value)
              InkWell(
                onTap: () async {
                  await outputDataController.takeSS().then((val) {
                    velBasedImdData = val;
                    mapPageController.showPCIlabel = true;
                  });
                  mapPageController.isVelPCICaptured.value = true;
                  Get.back();
                  Get.to(
                    () => RoadStatisticsPdfPage(
                      id: data['id'],
                      filename: data['filename'],
                      planned: data['planned'],
                      vehicleType: data['vehicleType'],
                      time: data['time'],
                      img1Byte: predBasedImdData,
                      img2Byte: velBasedImdData,
                    ),
                    transition: Transition.cupertino,
                  );
                },
                child: _buildButton("Velocity Based", context),
              ),
          ],
        );
      }),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  key: outputDataController.repaintKey,
                  child: GoogleMap(
                    buildingsEnabled: false,
                    mapType: mapPageController.backgroundMapType,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
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
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
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
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildButton(String text, context) {
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined),
          const Gap(5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: fs.bodyTextFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
