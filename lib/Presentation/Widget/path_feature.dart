// This file contains the code for the feature list of the polyline

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';

class PolylineFeature extends StatelessWidget {
  final int polylineIndex;
  const PolylineFeature({super.key, required this.polylineIndex});

  @override
  Widget build(BuildContext context) {
    // Define text styles
    TextStyle listTileTitleStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    TextStyle listTileTralingStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.blueGrey,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Features',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: polylineObj[polylineIndex].properties.keyList.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFF3EDF5),
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      // Key
                      title: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          polylineObj[polylineIndex]
                              .properties
                              .keyList[index]
                              .toString(),
                          style: listTileTitleStyle,
                        ),
                      ),
                      // Value
                      trailing: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          polylineObj[polylineIndex]
                              .properties
                              .valuesList[index]
                              .toStringAsFixed(2),
                          style: listTileTralingStyle,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
