import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/road_stats_controller.dart';
import 'package:pci_app/src/Presentation/Screens/OutputData/output_data_tile.dart';

import '../MapsPage/maps_page.dart';

class OutputDataPage extends StatefulWidget {
  const OutputDataPage({super.key});

  @override
  State<OutputDataPage> createState() => _OutputDataPageState();
}

class _OutputDataPageState extends State<OutputDataPage> {
  @override
  Widget build(BuildContext context) {
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    // ignore: unused_local_variable
    RoadStatsController roadStatsController = Get.put(RoadStatsController());
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return AnimatedSwitcher(
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            duration: const Duration(milliseconds: 300),
            child: outputDataController.slectedFiles.isNotEmpty
                ? _buildSelectedBar(outputDataController, popUpMenuTextStyle)
                : _buildDefaultAppBar(),
          );
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          if (outputDataController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (outputDataController.outputDataFile.isEmpty) {
            return _buildEmptyFileView();
          }

          return RefreshIndicator(
            onRefresh: outputDataController.fetchData,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
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
          );
        }),
      ),
    );
  }

  Widget _buildDefaultAppBar() {
    return AppBar(
      key: const ValueKey("DefaultAppBar"),
      title: Text(
        'Journey History',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      backgroundColor: backgroundColor,
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
    );
  }

  Widget _buildSelectedBar(
    OutputDataController outputDataController,
    TextStyle popUpMenuTextStyle,
  ) {
    return Container(
      key: const ValueKey("SelectedBar"),
      color: backgroundColor,
      height: kToolbarHeight,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                outputDataController.slectedFiles.clear();
              });
            },
            icon: Icon(
              Icons.close_outlined,
              color: Colors.black,
              size: kToolbarHeight * 0.5,
            ),
          ),
          const Gap(10),
          Text(
            '${outputDataController.slectedFiles.length} selected',
            style: GoogleFonts.inter(
              fontSize: 24,
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
                  onTap: () {
                    outputDataController.plotRoads().then((_) {
                      Get.to(() => MapPage(), transition: Transition.cupertino);
                      outputDataController.slectedFiles.clear();
                    });
                  },
                ),
                PopupMenuItem(
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
                  onTap: () {
                    outputDataController.makeZip();
                  },
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFileView() {
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
}
