/* 
  This widget is used to display the output data. It displays the filename,time, and 
  vehicle type of the data. It also displays an icon for the vehicle type and a popup 
  menu with options to show the data on the map and delete the data.
*/

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pci_app/src/Presentation/Screens/MapsPage/widget/road_stats.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import '../../../../Utils/get_icon.dart';
import '../MapsPage/maps_page.dart';

class OutputDataItem extends StatelessWidget {
  const OutputDataItem({
    super.key,
    required this.filename,
    required this.vehicleType,
    required this.time,
    required this.id,
  });

  final String filename;
  final int id;
  final String time;
  final String vehicleType;

  @override
  Widget build(BuildContext context) {
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    double left = 0, right = 0, top = 0, bottom = 0;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );
    UserDataController userDataController = UserDataController();
    final user = userDataController.storage.read('user');

    return InkWell(
      onTapDown: (TapDownDetails tapdownDetails) {
        // do something
        left = tapdownDetails.globalPosition.dx;
        top = tapdownDetails.globalPosition.dy;
        overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        right = overlay.size.width - left;
        bottom = overlay.size.height - top;
      },
      onLongPress: () {
        // multi-select
        if (outputDataController.slectedFiles.contains(id)) {
          outputDataController.slectedFiles.remove(id);
        } else {
          outputDataController.slectedFiles.add(id);
        }
      },
      onTap: () {
        // already selected
        if (outputDataController.slectedFiles.contains(id)) {
          outputDataController.slectedFiles.remove(id);
          return;
        }
        // multi-selct enabled
        if (outputDataController.slectedFiles.isNotEmpty) {
          outputDataController.slectedFiles.add(id);
          return;
        }
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            left,
            top,
            right,
            bottom,
          ),
          items: [
            PopupMenuItem(
              onTap: () async {
                outputDataController.slectedFiles.clear();
                outputDataController.slectedFiles.add(id);
                try {
                  outputDataController.plotRoads().then((_) {
                    Get.to(
                      () => MapPage(),
                      transition: Transition.cupertino,
                    );
                    outputDataController.slectedFiles.clear();
                  });
                } catch (e) {
                  customGetSnackBar("Plotting Error",
                      "Error in plotting the road data", Icons.error_outline);
                  logger.e(e.toString());
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
                  Get.to(
                    () => RoadStatistics(
                      id: id,
                      filename: filename,
                    ),
                    transition: Transition.cupertino,
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
                    await localDatabase.queryRoadOutputData(jouneyID: id);
                outputDataController.exportData(
                  filename: filename,
                  vehicle: vehicleType,
                  time: time,
                  jouneyData: query,
                );
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
                    "Export CSV",
                    style: popUpMenuTextStyle,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                // Function to export the data
                List<Map<String, dynamic>> query =
                    await localDatabase.queryRoadOutputData(jouneyID: id);
                Map<String, dynamic> metaData = {
                  'filename': filename,
                  'vehicleType': vehicleType,
                  'time': time,
                  'user': user,
                };
                outputDataController.exportJSON(query, metaData);
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
                    "Export JSON",
                    style: popUpMenuTextStyle,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                // Function to export the data
                final data = {
                  'filename': filename,
                  'vehicle': vehicleType,
                  'time': time,
                  'id': id,
                };
                try {
                  await outputDataController.dowloadReport(data);
                } catch (e) {
                  logger.f(e.toString());
                }
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
                    "Report",
                    style: popUpMenuTextStyle,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                _showDeleteDialog(context, id).then((value) {
                  if (value != null && value) {
                    outputDataController.deleteData(id);
                  }
                });
              },
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
          ],
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          right: 10,
          left: 10,
          top: 2,
          bottom: 2,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.15,
                  height: MediaQuery.sizeOf(context).width * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                        getIcon(vehicleType),
                        size: MediaQuery.sizeOf(context).width * 0.1,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Gap(MediaQuery.sizeOf(context).width * 0.05),
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
                Obx(() {
                  return outputDataController.slectedFiles.contains(id)
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.blue.shade800,
                        )
                      : SizedBox();
                }),
              ],
            ),
            Divider(
              color: Colors.black12,
              thickness: 0.5,
              indent: MediaQuery.sizeOf(context).width * 0.2,
            )
          ],
        ),
      ),
    );
  }
}

// Get alert dialog for the user to confirm the deletion of the data
Future<bool?> _showDeleteDialog(BuildContext context, int id) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete File?'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content: const Text('Are you sure you want to delete this file?'),
        contentTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text(
              'Yes',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    },
  );
}
