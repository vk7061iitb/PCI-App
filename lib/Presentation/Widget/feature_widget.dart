import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';

Widget bottomSheetContent(BuildContext context, int polylineIndex) {
  TextStyle style01 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );
  TextStyle style02 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.blueGrey,
  );
  return Container(
    height: MediaQuery.of(context).size.height * 0.5,
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
                    title: Text(
                      polylineObj[polylineIndex]
                          .properties
                          .keyList[index]
                          .toString(),
                      style: style01,
                    ),
                    trailing: Text(
                      polylineObj[polylineIndex]
                          .properties
                          .valuesList[index]
                          .toString(),
                      style: style02,
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
