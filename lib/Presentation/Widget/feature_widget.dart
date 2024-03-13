import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget bottomSheetContent(BuildContext context) {
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
          ListTile(
            leading: const Icon(Icons.add_road_outlined),
            title: const Text('Road ID'),
            onTap: () {
              // Handle the tap on "Photos"
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: const Text('Avg. Speed'),
            onTap: () {
              // Handle the tap on "Music"
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Total Length'),
            onTap: () {
              // Handle the tap on "Videos"
              Navigator.pop(context);
            },
          ),
        ],
      ),
  );
}
