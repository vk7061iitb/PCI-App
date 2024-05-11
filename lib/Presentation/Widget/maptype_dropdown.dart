import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Objects/data.dart';

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
    return DropdownButton<String>(
      isDense: true,
      isExpanded: false,
      value: dropdownValue,
      onChanged: (String? value) {
        // This is called when the user selects an item.
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
    
            case 'Teraain':
              googleMapType = googlemapType[3];
              break;
    
            case 'None':
              googleMapType = googlemapType[4];
              break;
    
            default:
              googleMapType = googlemapType[1];
          }
          dropdownValue = value!;
          if (kDebugMode) {
            print('Map Type: $dropdownValue');
          }
          widget.onChanged(dropdownValue);
        });
      },
      style: GoogleFonts.inter(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      elevation: 1,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(15),
      items: mapType.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
    );
  }
}
