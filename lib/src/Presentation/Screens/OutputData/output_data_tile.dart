/* 
  This widget is used to display the output data. It displays the filename,time, and 
  vehicle type of the data. It also displays an icon for the vehicle type and a popup 
  menu with options to show the data on the map and delete the data.
*/

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Models/pci_data.dart';
import 'package:pci_app/src/Models/stats_data.dart';
import '../../../../Functions/pci_data.dart';
import '../MapsPage/maps_page.dart';

class OutputDataItem extends StatelessWidget {
  const OutputDataItem({
    super.key,
    required this.filename,
    required this.vehicleType,
    required this.time,
    required this.onDeleteTap,
    required this.id,
  });

  final String filename;
  final String time;
  final String vehicleType;
  final int id;
  final VoidCallback onDeleteTap;

// Function to get the icon for the vehicle type
  Icon getIcon(String vehicleType) {
    if (vehicleType == 'Car') {
      return const Icon(
        Icons.directions_car,
        size: 40,
        color: Colors.black87,
      );
    } else if (vehicleType == 'Bike') {
      return const Icon(
        Icons.motorcycle,
        size: 40,
        color: Colors.black87,
      );
    } else if (vehicleType == 'Auto') {
      return const Icon(
        Icons.electric_rickshaw_outlined,
        size: 40,
        color: Colors.black87,
      );
    } else if (vehicleType == 'Bus') {
      return const Icon(
        Icons.directions_bus,
        size: 40,
        color: Colors.black87,
      );
    } else {
      return const Icon(
        Icons.directions_walk,
        size: 40,
        color: Colors.black87,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: getIcon(vehicleType),
              ),
            ),
          ),
          const Gap(5),
          Container(
            height: 50,
            width: 1,
            color: Colors.black26,
          ),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  filename,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      color: Colors.teal,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  onTap: () async {
                    List<PciData2> pciDataOutput =
                        await localDatabase.queryPciData(id);
                    jsonData = outputDataToGeoJson(pciDataOutput);
                    List<OutputStats> outputDataStats =
                        await localDatabase.queryStats(id);
                    outputStats = outputDataStats;
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapPage(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Show on Map",
                    style: popUpMenuTextStyle,
                  ),
                ),
                PopupMenuItem(
                  onTap: onDeleteTap,
                  child: Text(
                    "Delete",
                    style: popUpMenuTextStyle,
                  ),
                )
              ];
            },
          ),
        ],
      ),
    );
  }
}
