// This widget is used to display the map type dropdown. It is used to select the type of map to be displayed on the Map Screen.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pciapp/src/Presentation/Controllers/map_page_controller.dart';

class SelectMapType extends StatelessWidget {
  const SelectMapType({super.key});

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();

    return PopupMenuButton<MapType>(
        tooltip: 'Select Map Type',
        padding: const EdgeInsets.all(14),
        icon: const Icon(
          Icons.layers_outlined,
          color: Colors.black,
        ),
        onSelected: (MapType value) {
          mapPageController.backgroundMapType = value;
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<MapType>>[
            PopupMenuItem<MapType>(
              enabled: false,
              child: Text(
                'Map Type',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const PopupMenuDivider(),
            ...mapPageController.googlemapType
                .map<PopupMenuItem<MapType>>((MapType value) {
              return PopupMenuItem<MapType>(
                value: value,
                child: Text(
                  value.name.capitalize!,
                  style: GoogleFonts.inter(
                    color: value == mapPageController.backgroundMapType
                        ? Colors.blue
                        : Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              );
            }),
          ];
        });
  }
}
