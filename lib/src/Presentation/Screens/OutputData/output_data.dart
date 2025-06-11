import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pciapp/src/Presentation/Screens/OutputData/output_data_tile.dart';
import 'package:pciapp/Utils/text_styles.dart';
import '../../../../Utils/font_size.dart';
import '../MapsPage/maps_page.dart';

String aboutPage = '''
This page displays all processed data, which contains the roads PCI(Pavement Condition Index) values. 
You can see the road statistics and also download its PDF report. One can also visulize the data on
maps.
''';

class OutputDataPage extends StatefulWidget {
  const OutputDataPage({super.key});

  @override
  State<OutputDataPage> createState() => _OutputDataPageState();
}

class _OutputDataPageState extends State<OutputDataPage> {
  Widget _buildSelectedBar(
    OutputDataController outputDataController,
    TextStyle popUpMenuTextStyle,
    double w,
  ) {
    FontSize fs = getFontSize(w);
    IconsSize iS = getIconSize(w);
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
          Gap(w * 0.02),
          Text(
            '${outputDataController.slectedFiles.length} selected',
            style: GoogleFonts.inter(
              fontSize: fs.appBarFontSize,
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
                      Padding(
                        padding: EdgeInsets.only(right: w * 0.02),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.black87,
                          size: iS.generalIconSize,
                        ),
                      ),
                      Text(
                        "Show on Map",
                        style: popUpMenuTextStyle.copyWith(
                          fontSize: fs.bodyTextFontSize,
                        ),
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
                      Padding(
                        padding: EdgeInsets.only(right: w * 0.02),
                        child: Icon(
                          Icons.file_download,
                          color: Colors.black87,
                          size: iS.generalIconSize,
                        ),
                      ),
                      Text(
                        "Export",
                        style: popUpMenuTextStyle.copyWith(
                          fontSize: fs.bodyTextFontSize,
                        ),
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

  @override
  Widget build(BuildContext context) {
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    IconsSize iconsSize = getIconSize(w);
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
                ? _buildSelectedBar(outputDataController, popUpMenuTextStyle, w)
                : AppBar(
                    key: const ValueKey("DefaultAppBar"),
                    title: Text(
                      'Journey History',
                      style: GoogleFonts.inter(
                        fontSize: fs.appBarFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    backgroundColor: backgroundColor,
                    foregroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    scrolledUnderElevation: 0,
                    actions: [
                      PopupMenuButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  onTap: () async {
                                    await outputDataController
                                        .insertJourneyDataviaUpload();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.download_outlined),
                                      const Gap(8),
                                      Text(
                                        "Import File",
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: MediaQuery.textScalerOf(context)
                                              .scale(16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // info button
                                PopupMenuItem(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('About the journey history',
                                            style: dialogTitleStyle),
                                        content: Text(aboutPage,
                                            style: dialogContentStyle),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              'OK',
                                              style: dialogButtonStyle,
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.info_outline_rounded),
                                      const Gap(8),
                                      Text("About Page", style: popUpMenuTextStyle,),
                                    ],
                                  ),
                                ),
                              ]),
                      // info
                    ],
                  ),
          );
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          if (outputDataController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (outputDataController.outputDataFile.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    assetsPath.emptyFile,
                    width: iconsSize.buttonIconSize,
                  ),
                  Text(
                    'There are no files to display',
                    style: GoogleFonts.inter(
                      fontSize: fs.bodyTextFontSize,
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
            color: activeColor,
            backgroundColor: backgroundColor,
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(
                  Color(0xFFc0c0c0),
                ),
                thickness: WidgetStateProperty.all(8.0),
                radius: Radius.circular(10),
                interactive: true,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: false,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: outputDataController.outputDataFile.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = outputDataController.outputDataFile[index];

                    return OutputDataItem(
                      filename: item["filename"],
                      vehicleType: item["vehicleType"],
                      time: item["Time"],
                      planned: item["planned"],
                      id: item["id"],
                      driveFileID: item["driveFileID"] ?? "",
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
