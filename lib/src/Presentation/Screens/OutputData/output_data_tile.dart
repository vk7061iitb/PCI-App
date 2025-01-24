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
import 'package:pci_app/Utils/font_size.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pci_app/src/Presentation/Screens/MapsPage/widget/road_stats.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';
import '../../../../Utils/get_icon.dart';
import '../MapsPage/maps_page.dart';

class OutputDataItem extends StatefulWidget {
  const OutputDataItem(
      {super.key,
      required this.filename,
      required this.vehicleType,
      required this.time,
      required this.planned,
      required this.id,
      required this.driveFileID});

  final String filename;
  final int id;
  final String time;
  final String planned;
  final String vehicleType;
  final String driveFileID;

  @override
  State<OutputDataItem> createState() => _OutputDataItemState();
}

class _OutputDataItemState extends State<OutputDataItem> {
  @override
  Widget build(BuildContext context) {
    UserDataController userDataController = UserDataController();
    final user = userDataController.storage.read('user');
    final w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    double left = 0, right = 0, top = 0, bottom = 0;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: fs.bodyTextFontSize,
    );
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
        if (outputDataController.slectedFiles.contains(widget.id)) {
          outputDataController.slectedFiles.remove(widget.id);
        } else {
          outputDataController.slectedFiles.add(widget.id);
        }
      },
      onTap: () {
        // already selected
        if (outputDataController.slectedFiles.contains(widget.id)) {
          outputDataController.slectedFiles.remove(widget.id);
          return;
        }
        // multi-selct enabled
        if (outputDataController.slectedFiles.isNotEmpty) {
          outputDataController.slectedFiles.add(widget.id);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          items: [
            if (widget.driveFileID.isEmpty)
              PopupMenuItem(
                onTap: () async {
                  // Function to export the data
                  List<Map<String, dynamic>> query = await localDatabase
                      .queryRoadOutputData(journeyID: widget.id);
                  Map<String, dynamic> metaData = {
                    'filename': widget.filename,
                    'vehicleType': widget.vehicleType,
                    'time': widget.time,
                    'user': user,
                  };
                  outputDataController.uploadToDrive(
                      query, metaData, widget.id);
                },
                child: Text(
                  "Sync to drive",
                  style: popUpMenuTextStyle.copyWith(
                    color: activeColor,
                  ),
                ),
              ),
            PopupMenuItem(
              onTap: () async {
                outputDataController.slectedFiles.clear();
                outputDataController.slectedFiles.add(widget.id);
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
              child: Text(
                "Show on Map",
                style: popUpMenuTextStyle,
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                if (context.mounted) {
                  Get.to(
                    () => RoadStatistics(
                      id: widget.id,
                      filename: widget.filename,
                      planned: widget.planned,
                      time: widget.time,
                      vehicleType: widget.vehicleType,
                    ),
                    transition: Transition.cupertino,
                  );
                }
              },
              child: Text(
                "Statistics",
                style: popUpMenuTextStyle,
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                // Function to export the data
                List<Map<String, dynamic>> query = await localDatabase
                    .queryRoadOutputData(journeyID: widget.id);
                outputDataController.exportData(
                  filename: widget.filename,
                  vehicle: widget.vehicleType,
                  time: widget.time,
                  planned: widget.planned,
                  jouneyData: query,
                );
              },
              child: Text(
                "Export CSV",
                style: popUpMenuTextStyle,
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                // Function to export the data
                List<Map<String, dynamic>> query = await localDatabase
                    .queryRoadOutputData(journeyID: widget.id);
                Map<String, dynamic> metaData = {
                  'filename': widget.filename,
                  'vehicleType': widget.vehicleType,
                  'time': widget.time,
                  'user': user,
                };
                outputDataController.exportJSON(query, metaData);
              },
              child: Text(
                "Export JSON",
                style: popUpMenuTextStyle,
              ),
            ),
            PopupMenuItem(
              onTap: () async {
                // Function to export the data
                final data = {
                  'filename': widget.filename,
                  'vehicle': widget.vehicleType,
                  'time': widget.time,
                  'id': widget.id,
                };
                try {
                  await outputDataController.dowloadReport(data);
                } catch (e) {
                  logger.f(e.toString());
                }
              },
              child: Text(
                "Report",
                style: popUpMenuTextStyle,
              ),
            ),
            PopupMenuItem(
              onTap: () {
                _showDeleteDialog(context, widget.id).then((value) {
                  if (value != null && value) {
                    outputDataController.deleteData(widget.id);
                  }
                });
              },
              child: Text(
                "Delete",
                style: popUpMenuTextStyle,
              ),
            ),
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: outputDataController.slectedFiles.isNotEmpty
                        ? outputDataController.slectedFiles.contains(widget.id)
                            ? Row(
                                key: ValueKey(
                                    'check_${widget.id}'), // Unique key for animation
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: activeColor,
                                    size: 24,
                                  ),
                                  const Gap(8),
                                ],
                              )
                            : Row(
                                key: ValueKey('empty_${widget.id}'),
                                children: [
                                  Icon(
                                    Icons.circle_outlined,
                                    color: textColor,
                                    size: 24,
                                  ),
                                  const Gap(8),
                                ],
                              )
                        : SizedBox(),
                  );
                }),
                Container(
                  width: (MediaQuery.sizeOf(context).width * 0.15 < 80)
                      ? MediaQuery.sizeOf(context).width * 0.15
                      : 80,
                  height: (MediaQuery.sizeOf(context).width * 0.15 < 80)
                      ? MediaQuery.sizeOf(context).width * 0.15
                      : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                        getIcon(widget.vehicleType),
                        size: (MediaQuery.sizeOf(context).width * 0.1 < 50)
                            ? MediaQuery.sizeOf(context).width * 0.1
                            : 50,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Gap(MediaQuery.sizeOf(context).width * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.filename,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: fs.bodyTextFontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              widget.planned,
                              style: GoogleFonts.inter(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.time,
                        style: GoogleFonts.inter(
                          color: Colors.teal,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
