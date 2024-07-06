/* 
This widget is used to display the map type dropdown. It is used to select the type of map to be displayed on the Map Screen.
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../Objects/data.dart';

class MapTypeDropdown extends StatefulWidget {
  final Function(String) onChanged;
  const MapTypeDropdown({required this.onChanged, super.key});

  @override
  State<MapTypeDropdown> createState() => _MapTypeDropdownState();
}

class _MapTypeDropdownState extends State<MapTypeDropdown> {
  String dropdownValue = mapType[0]; // Set initial value

  @override
  Widget build(BuildContext context) {
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
        setState(() {
          switch (value) {
            case 'Normal':
              googleMapType = googlemapType[0];
              break;
            case 'Satellite':
              googleMapType = googlemapType[1];
              break;
            case 'Hybrid':
              googleMapType = googlemapType[2];
              break;
            case 'Terrain':
              googleMapType = googlemapType[3];
              break;
            case 'None':
              googleMapType = googlemapType[4];
              break;
            default:
              googleMapType = googlemapType[1];
          }
          dropdownValue = value;
          if (kDebugMode) {
            print('Map Type: $dropdownValue');
          }
          widget.onChanged(dropdownValue);
        });
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
          ...mapType.map<PopupMenuItem<String>>((String value) {
            return PopupMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  color: value == dropdownValue ? Colors.blue : Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            );
          }),
        ];
      },
    );
  }
}
