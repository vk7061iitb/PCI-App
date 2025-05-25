import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';
import 'package:pciapp/Utils/text_styles.dart';
import 'package:pciapp/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';
import 'journey_summary.dart';
import 'pause_resume_sheet.dart';
import 'road_type_button.dart';
import 'section_name_widget.dart';

final AutoSizeGroup textGroup = AutoSizeGroup();

// the homepaege wigets
class ReadingWidget extends StatelessWidget {
  const ReadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    AccDataController accDataController = Get.find<AccDataController>();
    TextStyle sensorNameStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xFF202124),
      textStyle: TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
    );
    TextStyle labelTextStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF202124),
    );
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    double totalH = h -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        0.18 * w;
    FontSize fs = getFontSize(w);
    return Column(
      children: [
        SectionName(totalH: totalH, width: w, label: "Journey Summary"),
        Gap(h * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: JourneySummary(),
        ),

        Gap(h * 0.02),
        // RoadType
        SectionName(totalH: totalH, width: w, label: "Road Type"),
        Gap(h * 0.01),
        Wrap(
          spacing: w * 0.01, // Horizontal space between children
          runSpacing: w * 0.04, // Vertical space between rows
          alignment:
              WrapAlignment.center, // Center items horizontally in the row
          runAlignment:
              WrapAlignment.center, // Center the rows themselves vertically
          children: [
            /// Paved button
            RoadTypeButton(
                width: w,
                height: h,
                buttonImgPath: assetsPath.pave,
                tooltipMessage: "Tap when road is paved",
                label: "Paved",
                selectedRoadType: accDataController.currRoadType,
                onTap: () {
                  // if pause/resume is already tapped then do nothing
                  if (accDataController.currRoadIndex < 0) {
                    return;
                  }
                  accDataController.currRoadType.value = "Paved";
                  accDataController.currRoadIndex.value = accDataController
                      .roads
                      .indexOf(accDataController.currRoadType.value);
                }),

            Gap(w * 0.05),

            /// Unpaved
            RoadTypeButton(
                width: w,
                height: h,
                buttonImgPath: assetsPath.unPave,
                tooltipMessage: "Tap when road is unpaved",
                label: "Unpaved",
                selectedRoadType: accDataController.currRoadType,
                onTap: () {
                  // if pause/resume is already tapped then do nothing
                  if (accDataController.currRoadIndex < 0) {
                    return;
                  }
                  accDataController.currRoadType.value = "Unpaved";
                  accDataController.currRoadIndex.value = accDataController
                      .roads
                      .indexOf(accDataController.currRoadType.value);
                }),

            Gap(w * 0.05),

            /// Pedestrian
            RoadTypeButton(
                width: w,
                height: h,
                buttonImgPath: assetsPath.pedestrian,
                tooltipMessage: "Tap when road in pedestrian",
                label: "Pedestrian",
                selectedRoadType: accDataController.currRoadType,
                onTap: () {
                  // if pause/resume is already tapped then do nothing
                  if (accDataController.currRoadIndex < 0) {
                    return;
                  }
                  accDataController.currRoadType.value = "Pedestrian";
                  accDataController.currRoadIndex.value = accDataController
                      .roads
                      .indexOf(accDataController.currRoadType.value);
                }),

            SectionName(totalH: totalH, width: w, label: "Pause/Resume"),

            /// Pause/Resume
            SizedBox(
              width: w * 0.3,
              child: Tooltip(
                message: "Tap when you want to pause the reading",
                child: InkWell(
                  onTap: () async {
                    if (accDataController.showStartButton) {
                      // reading is not started yet
                      Get.showSnackbar(
                        customGetSnackBar(
                          "Error",
                          "Reading has not been started yet!",
                          Icons.warning_amber,
                        ),
                      );
                      return;
                    }
                    if (accDataController.currRoadIndex < 0) {
                      // resume is tapped ( the pause make the current road index = -1/-2)
                      // this will work as resume button
                      // resume the reading
                      // reset the data
                      accDataController.currRoadIndex.value =
                          accDataController.prevRoadIndex.value;
                      accDataController.remarks.value = "-";
                      accDataController.pauseReasonSelectedOption.value = "";
                      accDataController.pauseReasonController.clear();
                      return;
                    }
                    // pause button tapped
                    accDataController.prevRoadIndex.value =
                        accDataController.currRoadIndex.value;
                    bool? type = await _selectReason(context);

                    if (type == null) {
                      return;
                    } else if (type == true) {
                      accDataController.currRoadIndex.value = -1;
                      accDataController.pauseReasonSelectedOption.value =
                          "Measurement";
                    } else {
                      accDataController.currRoadIndex.value = -2;
                      accDataController.pauseReasonSelectedOption.value =
                          "Others";
                    }

                    // open the panel
                    Get.bottomSheet(
                      PauseResumeSheet(),
                      isDismissible: false,
                      enableDrag: false,
                      ignoreSafeArea: false,
                    );
                  },
                  radius: 25,
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        SizedBox(
                            width: (w > 600)
                                ? w * 0.12
                                : w * 0.1, // Larger icon size for wide screens
                            height: (w > 600) ? w * 0.12 : w * 0.1,
                            child: RepaintBoundary(
                              child: Obx(
                                () => SvgPicture.asset(
                                  colorFilter: ColorFilter.mode(
                                    (accDataController.currRoadIndex.value < 0)
                                        ? Colors.blue
                                        : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  (accDataController.currRoadIndex.value >= 0)
                                      ? assetsPath.pause
                                      : assetsPath.resume,
                                ),
                              ),
                            )),
                        Gap(h * 0.01),
                        Center(
                          child: FittedBox(
                              child: RepaintBoundary(
                            child: Obx(
                              () => AutoSizeText(
                                (accDataController.currRoadIndex.value >= 0)
                                    ? "Pause"
                                    : "Resume",
                                style: GoogleFonts.inter(
                                  fontSize: fs.bodyTextFontSize,
                                  fontWeight:
                                      (accDataController.currRoadIndex.value <
                                              0)
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      (accDataController.currRoadIndex.value <
                                              0)
                                          ? activeColor
                                          : Colors.black,
                                ),
                                group: textGroup,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Gap(w * 0.05),
          ],
        ),
        Gap(totalH * 0.05), // 5% of total height
        SectionName(totalH: totalH, width: w, label: "Sensor Reading"),
        Gap(totalH * 0.02),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(w * 0.025),

            /// Acceleration Widget
            Container(
              width: w * 0.45,
              height: totalH * 0.3, // 30% of total height
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Gap(constraints.maxWidth * 0.05),
                          SizedBox(
                            width: 0.15 * constraints.maxWidth,
                            height: 0.15 * constraints.maxHeight,
                            child: SvgPicture.asset(
                              assetsPath.accelerometer,
                            ),
                          ),
                          Gap(constraints.maxWidth * 0.05),
                          Text(
                            "Acceleration",
                            style: sensorNameStyle.copyWith(
                              fontSize: fs.appBarFontSize,
                            ),
                          ),
                          Gap(constraints.maxWidth * 0.05),
                        ],
                      ),
                    ),
                    // X - Acceleration
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
                        children: [
                          Text(
                            "X",
                            style: labelTextStyle.copyWith(
                              fontSize: fs.bodyTextFontSize,
                            ),
                          ),
                          Gap(constraints.maxWidth * 0.1),
                          Container(
                            width: constraints.maxWidth * 0.50,
                            height: constraints.maxHeight * 0.20,
                            decoration: BoxDecoration(
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: RepaintBoundary(
                                child: Obx(() {
                                  return Text(
                                    accDataController.accData.value.x
                                        .toStringAsFixed(3),
                                    style: labelTextStyle.copyWith(
                                      fontSize: fs.bodyTextFontSize,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Y - Acceleration
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Y",
                            style: labelTextStyle.copyWith(
                              fontSize: fs.bodyTextFontSize,
                            ),
                          ),
                          Gap(constraints.maxWidth * 0.1),
                          Container(
                            width: constraints.maxWidth * 0.50,
                            height: constraints.maxHeight * 0.20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: RepaintBoundary(
                                child: Obx(() {
                                  return Text(
                                    accDataController.accData.value.y
                                        .toStringAsFixed(3),
                                    style: labelTextStyle.copyWith(
                                      fontSize: fs.bodyTextFontSize,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Z - Acceleration
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Z",
                            style: labelTextStyle.copyWith(
                              fontSize: fs.bodyTextFontSize,
                            ),
                          ),
                          Gap(constraints.maxWidth * 0.1),
                          Container(
                            width: constraints.maxWidth * 0.50,
                            height: constraints.maxHeight * 0.20,
                            decoration: BoxDecoration(
                              color: white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: RepaintBoundary(
                                child: Obx(() {
                                  return Text(
                                    accDataController.accData.value.z
                                        .toStringAsFixed(3),
                                    style: labelTextStyle.copyWith(
                                      fontSize: fs.bodyTextFontSize,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            Gap(w * 0.05),

            /// Location Widget
            Container(
              width: w * 0.45,
              height: totalH * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: white,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 0.15 * constraints.maxWidth,
                              height: 0.15 * constraints.maxHeight,
                              child: SvgPicture.asset(
                                assetsPath.location,
                              ),
                            ),
                            Gap(constraints.maxWidth * 0.05),
                            Text(
                              "Location",
                              style: sensorNameStyle.copyWith(
                                fontSize: fs.appBarFontSize,
                              ),
                            ),
                            Gap(constraints.maxWidth * 0.05),
                          ],
                        ),
                      ),
                      // latitude, longitude, accuracy
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Lat",
                              style: labelTextStyle.copyWith(
                                  fontSize: fs
                                      .bodyTextFontSize // Scales text size based on width
                                  ),
                            ),
                            Gap(constraints.maxWidth * 0.1),
                            Container(
                              width: constraints.maxWidth * 0.50,
                              height: constraints.maxHeight * 0.20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: RepaintBoundary(
                                  child: Obx(() {
                                    return Text(
                                      accDataController.isRecordingData
                                          ? accDataController
                                              .devicePosition.latitude
                                              .toStringAsFixed(3)
                                          : "0.000",
                                      style: labelTextStyle.copyWith(
                                        fontSize: fs.bodyTextFontSize,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      FittedBox(
                        fit: BoxFit.contain,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Lon",
                              style: labelTextStyle.copyWith(
                                fontSize: fs.bodyTextFontSize,
                              ),
                            ),
                            Gap(constraints.maxWidth * 0.1),
                            Container(
                              width: constraints.maxWidth * 0.50,
                              height: constraints.maxHeight * 0.20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: RepaintBoundary(
                                  child: Obx(() {
                                    return Text(
                                      accDataController.isRecordingData
                                          ? accDataController
                                              .devicePosition.longitude
                                              .toStringAsFixed(3)
                                          : "0.000",
                                      style: labelTextStyle.copyWith(
                                        fontSize: fs.bodyTextFontSize,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Acc",
                              style: labelTextStyle.copyWith(
                                fontSize: fs.bodyTextFontSize,
                              ),
                            ),
                            Gap(constraints.maxWidth * 0.1),
                            Container(
                              width: constraints.maxWidth * 0.50,
                              height: constraints.maxHeight * 0.20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: RepaintBoundary(
                                  child: Obx(() {
                                    return Text(
                                      accDataController.isRecordingData
                                          ? accDataController
                                              .devicePosition.accuracy
                                              .toStringAsFixed(3)
                                          : "0.000",
                                      style: labelTextStyle.copyWith(
                                        fontSize: fs.bodyTextFontSize,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        //
      ],
    );
  }
}

Future<bool?> _selectReason(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reason'),
        titleTextStyle: dialogTitleStyle,
        content: const Text('Please select the reason for this pause'),
        contentTextStyle: dialogContentStyle,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text('Measurements', style: dialogButtonStyle),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text('Others', style: dialogButtonStyle),
          ),
        ],
      );
    },
  );
}
