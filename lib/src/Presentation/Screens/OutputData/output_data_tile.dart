/* 
  This widget is used to display the output data. It displays the filename,time, and 
  vehicle type of the data. It also displays an icon for the vehicle type and a popup 
  menu with options to show the data on the map and delete the data.
*/

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import 'package:pci_app/src/Presentation/Screens/MapsPage/widget/road_stats.dart';
import 'package:share_plus/share_plus.dart';
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
  final int id;
  final VoidCallback onDeleteTap;
  final String time;
  final String vehicleType;

// Function to get the icon for the vehicle type
  Icon getIcon(String vehicleType) {
    if (vehicleType == 'Car') {
      return const Icon(
        Icons.directions_car_filled_outlined,
        size: 40,
        color: Colors.black87,
      );
    } else if (vehicleType == 'Bike') {
      return const Icon(
        Icons.motorcycle_outlined,
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
        Icons.directions_bus_outlined,
        size: 40,
        color: Colors.black87,
      );
    } else {
      return const Icon(
        Icons.directions_run_outlined,
        size: 40,
        color: Colors.black87,
      );
    }
  }

  // velocity to pci
  double velocityToPCI(double velocity) {
    if (velocity >= 30) {
      return 5;
    } else if (velocity > 20) {
      return 4;
    } else if (velocity > 10) {
      return 3;
    } else if (velocity > 5) {
      return 2;
    } else {
      return 1;
    }
  }

  // export data
  Future<void> exportData(String filename, String vehicle, String time,
      List<Map<String, dynamic>> query) async {
    List<List<dynamic>> csvData = [];
    csvData.add([
      'Road Name',
      'Latitude',
      'Longitude',
      'PCI(prediction)',
      'PCI(velocity)',
      'Velocity(km/hr)',
    ]);
    for (var road in query) {
      String roadName = road["roadName"];
      List<dynamic> labels = jsonDecode(road["labels"]);

      // add the velocity_prediction in the labels
      for (int i = 0; i < labels.length; i++) {
        labels[i]['vel_prediction'] =
            velocityToPCI(labels[i]['velocity'] * 3.6); // convert to km/hr
      }

      for (int i = 0; i < labels.length; i++) {
        List<dynamic> row = [];
        row.add(roadName);
        row.add(labels[i]['latitude']);
        row.add(labels[i]['longitude']);
        row.add(labels[i]['prediction']);
        row.add(labels[i]['vel_prediction']);
        row.add(labels[i]['velocity'] * 3.6); // convert to km/hr
        csvData.add(row);
      }
    }
    final tempdir = await getTemporaryDirectory();
    String csv = const ListToCsvConverter().convert(csvData);
    String fileName = '$filename-$vehicle-$time.csv';
    String path = '${tempdir.path}/$fileName';
    File file = File(path);
    file.writeAsString(csv);
    XFile fileToShare = XFile(path);
    await fileToShare.readAsString();
    Share.shareXFiles([fileToShare]).then((value) {
      file.delete();
    });
  }

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find();
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.09,
      width: MediaQuery.of(context).size.width,
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
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              child: getIcon(vehicleType),
            ),
          ),
          const Gap(5),
          // Vetical line to separate the icon and the filename
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: 1,
            color: Colors.black26,
          ),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
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
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: Colors.teal,
                    ),
                    const SizedBox(width: 10),
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
                    List<Map<String, dynamic>> roadOutputDataQuery =
                        await localDatabase.queryRoadOutputData(id);
                    mapPageController.currentRoad = {
                      "filename": filename,
                      "vehicleType": vehicleType,
                      "time": time,
                    };
                    mapPageController.roadOutputDataQuery = roadOutputDataQuery;
                    mapPageController.plotRoadData();

                    if (context.mounted) {
                      Get.to(
                        () => MapPage(),
                        transition: Transition.cupertino,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Show on Map",
                        style: popUpMenuTextStyle,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    if (context.mounted) {
                      Get.bottomSheet(
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: RoadStatistics(
                            id: id,
                          ),
                        ),
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        ignoreSafeArea: false,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.bar_chart_outlined,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Statistics",
                        style: popUpMenuTextStyle,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    // Function to export the data
                    List<Map<String, dynamic>> query =
                        await localDatabase.queryRoadOutputData(id);
                    exportData(filename, vehicleType, time, query);
                  },
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.file_download,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Export",
                        style: popUpMenuTextStyle,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: onDeleteTap,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Delete",
                        style: popUpMenuTextStyle,
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
