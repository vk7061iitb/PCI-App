// This widget is used to display the map type dropdown. It is used to select the type of map to be displayed on the Map Screen.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import '../../../../../Objects/data.dart';

class SelectMapType extends StatelessWidget {
  const SelectMapType({super.key});

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();

    return PopupMenuButton<String>(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: const BorderSide(
                color: Colors.black38,
                width: 1,
              ),
            ),
          ),
        ),
        tooltip: 'Select Map Type',
        padding: const EdgeInsets.all(14),
        icon: const Icon(
          Icons.map,
          color: Colors.black,
        ),
        onSelected: (String value) {
          switch (value) {
            case 'Normal':
              mapPageController.backgroundMapType = googlemapType[0];
              break;
            case 'Satellite':
              mapPageController.backgroundMapType = googlemapType[1];
              break;
            case 'Hybrid':
              mapPageController.backgroundMapType = googlemapType[2];
              break;
            case 'Terrain':
              mapPageController.backgroundMapType = googlemapType[3];
              break;
            case 'None':
              mapPageController.backgroundMapType = googlemapType[4];
              break;
            default:
              mapPageController.backgroundMapType = googlemapType[1];
          }
          mapPageController.dropdownvalue = value;
          if (kDebugMode) {
            print('Map Type: ${mapPageController.dropdownvalue}');
          }
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
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
            ...mapPageController.mapType
                .map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    color: value == mapPageController.dropdownvalue
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
