import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pci_app/src/Presentation/Screens/OutputData/output_data_tile.dart';

import '../MapsPage/maps_page.dart';

class OutputDataPage extends StatelessWidget {
  const OutputDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: AppBar(
        title: Text(
          'Journey History',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF3EDF5),
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (outputDataController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (outputDataController.outputDataFile.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    assetsPath.emptyFile,
                    width: 50,
                  ),
                  Text(
                    'There are no files to display',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: outputDataController.fetchData,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            child: Column(
              children: [
                outputDataController.slectedFiles.isNotEmpty
                    ? SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1), // Slides down slightly
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: const AlwaysStoppedAnimation(1),
                            curve: Curves.easeOutQuad,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: const AlwaysStoppedAnimation(1),
                          child: SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.1,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    outputDataController.slectedFiles.clear();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: MediaQuery.sizeOf(context).height *
                                        0.04,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  '${outputDataController.slectedFiles.length} selected',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton(
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5),
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
                                        onTap: () {
                                          // show on map
                                          outputDataController
                                              .plotRoads()
                                              .then((_) {
                                            Get.to(
                                              () => MapPage(),
                                              transition: Transition.cupertino,
                                            );
                                            outputDataController.slectedFiles
                                                .clear();
                                          });
                                        },
                                      ),
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 5),
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
                                        onTap: () {
                                          // export data
                                          outputDataController.makeZip();
                                        },
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const Gap(0),
                const Gap(10),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: outputDataController.outputDataFile.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = outputDataController.outputDataFile[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: OutputDataItem(
                          filename: item["filename"],
                          vehicleType: item["vehicleType"],
                          time: item["Time"],
                          id: item["id"],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
