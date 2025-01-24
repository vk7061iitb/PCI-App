import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';
import 'package:pciapp/src/Presentation/Controllers/sensor_controller.dart';

import '../../../../../Utils/format_chainage.dart';

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
    final AutoSizeGroup textGroup = AutoSizeGroup();
    FontSize fs = getFontSize(w);
    return Column(
      children: [
        Obx(() {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.05),
              child: SizedBox(
                height: totalH * 0.05, // 5% of total height
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      AutoSizeText(
                        "Distance Travelled",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: fs.heading2FontSize,
                          color: textColor,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          formatChainage(
                              accDataController.totalDistanceTravelled.value),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: fs.heading2FontSize,
                            color: activeColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        Gap(h * 0.02),
        // RoadType
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: SizedBox(
              height: totalH * 0.05, // 5% of total height
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AutoSizeText(
                  "Road Type",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: fs.heading2FontSize,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        Gap(h * 0.02),
        Wrap(
          spacing: w * 0.01, // Horizontal space between children
          runSpacing: w * 0.04, // Vertical space between rows
          alignment:
              WrapAlignment.center, // Center items horizontally in the row
          runAlignment:
              WrapAlignment.center, // Center the rows themselves vertically
          children: [
            /// Paved
            Obx(() {
              return SizedBox(
                width: w * 0.3,
                child: Tooltip(
                  message: "Tap when road is paved",
                  child: InkWell(
                    onTap: () {
                      accDataController.currRoadType.value = "Paved";
                      accDataController.currRoadIndex.value = accDataController
                          .roads
                          .indexOf(accDataController.currRoadType.value);
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
                            child: SvgPicture.asset(
                              colorFilter: ColorFilter.mode(
                                (accDataController.currRoadType.value ==
                                        "Paved")
                                    ? activeColor
                                    : Colors.black,
                                BlendMode.srcIn,
                              ),
                              assetsPath.pave,
                            ),
                          ),
                          Gap(h * 0.01),
                          Center(
                            child: AutoSizeText(
                              "Paved",
                              style: GoogleFonts.inter(
                                fontSize: fs.bodyTextFontSize,
                                fontWeight:
                                    (accDataController.currRoadType.value ==
                                            "Paved")
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color: (accDataController.currRoadType.value ==
                                        "Paved")
                                    ? activeColor
                                    : Colors.black,
                              ),
                              group: textGroup,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Gap(w * 0.05),

            /// Unpaved
            Obx(() {
              return SizedBox(
                width: w * 0.3,
                child: Tooltip(
                  message: "Tap when raod is unpaved",
                  child: InkWell(
                    onTap: () {
                      accDataController.currRoadType.value = "Unpaved";
                      accDataController.currRoadIndex.value = accDataController
                          .roads
                          .indexOf(accDataController.currRoadType.value);
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
                            child: SvgPicture.asset(
                              assetsPath.unPave,
                              colorFilter: ColorFilter.mode(
                                (accDataController.currRoadType.value ==
                                        "Unpaved")
                                    ? activeColor
                                    : Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Gap(h * 0.01),
                          Center(
                            child: AutoSizeText(
                              "Un-Paved",
                              style: GoogleFonts.inter(
                                fontSize: fs.bodyTextFontSize,
                                fontWeight:
                                    (accDataController.currRoadType.value ==
                                            "Unpaved")
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color: (accDataController.currRoadType.value ==
                                        "Unpaved")
                                    ? activeColor
                                    : Colors.black,
                              ),
                              group: textGroup,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Gap(w * 0.05),

            /// Pedestrian
            Obx(() {
              return SizedBox(
                width: w * 0.3,
                child: Tooltip(
                  message: "Tap when road in pedestrian",
                  child: InkWell(
                    onTap: () {
                      accDataController.currRoadType.value = "Pedestrian";
                      accDataController.currRoadIndex.value = accDataController
                          .roads
                          .indexOf(accDataController.currRoadType.value);
                      accDataController.isPedestrianFound.value = true;
                    },
                    radius: 25,
                    borderRadius: BorderRadius.circular(5),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: (w > 600)
                                  ? w * 0.12
                                  : w *
                                      0.1, // Larger icon size for wide screens
                              height: (w > 600) ? w * 0.12 : w * 0.1,
                              child: SvgPicture.asset(
                                assetsPath.pedestrian,
                                colorFilter: ColorFilter.mode(
                                  (accDataController.currRoadType.value ==
                                          "Pedestrian")
                                      ? activeColor
                                      : Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Gap(h * 0.01),
                            Center(
                              child: AutoSizeText(
                                "Pedestrian",
                                style: GoogleFonts.inter(
                                  fontSize: fs.bodyTextFontSize,
                                  fontWeight:
                                      (accDataController.currRoadType.value ==
                                              "Pedestrian")
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      (accDataController.currRoadType.value ==
                                              "Pedestrian")
                                          ? activeColor
                                          : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                group: textGroup,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            /// Break
            Obx(() {
              return SizedBox(
                width: w * 0.3,
                child: Tooltip(
                  message: "Tap when there's a breaker",
                  child: InkWell(
                    onTap: () async {
                      // break
                      accDataController.bnb.value = 1;
                      // after 2 sec
                      if (!accDataController.showStartButton) {
                        Future.delayed(const Duration(seconds: 2)).then((_) {
                          accDataController.bnb.value = 0;
                        });
                      }
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
                            child: SvgPicture.asset(
                              colorFilter: ColorFilter.mode(
                                (accDataController.bnb.value == 1)
                                    ? Colors.blue
                                    : Colors.black,
                                BlendMode.srcIn,
                              ),
                              assetsPath.breAk,
                            ),
                          ),
                          Gap(h * 0.01),
                          Center(
                            child: FittedBox(
                              child: AutoSizeText(
                                "Break",
                                style: GoogleFonts.inter(
                                  fontSize: fs.bodyTextFontSize,
                                  fontWeight: (accDataController.bnb.value == 1)
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: (accDataController.bnb.value == 1)
                                      ? activeColor
                                      : Colors.black,
                                ),
                                group: textGroup,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            Gap(w * 0.05),

            /// No-Break
            Obx(() {
              return SizedBox(
                width: w * 0.3,
                child: Tooltip(
                  message: "Tap when there's no speed breaker",
                  child: InkWell(
                    onTap: () {
                      // break
                      accDataController.bnb.value = 0;
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
                            child: SvgPicture.asset(
                              colorFilter: ColorFilter.mode(
                                (accDataController.bnb.value == 0)
                                    ? Colors.blue
                                    : Colors.black,
                                BlendMode.srcIn,
                              ),
                              assetsPath.noBreak,
                            ),
                          ),
                          Gap(h * 0.01),
                          Center(
                            child: AutoSizeText(
                              "No-Break",
                              style: GoogleFonts.inter(
                                fontSize: fs.bodyTextFontSize,
                                fontWeight: (accDataController.bnb.value == 0)
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: (accDataController.bnb.value == 0)
                                    ? activeColor
                                    : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              group: textGroup,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        Gap(totalH * 0.04), // 2.5% of total height
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: SizedBox(
              height: totalH * 0.05, // 5% of total height
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AutoSizeText(
                  "Sensor Reading",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: fs.heading2FontSize,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        Gap(totalH * 0.02), // 1.5% of total height

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
