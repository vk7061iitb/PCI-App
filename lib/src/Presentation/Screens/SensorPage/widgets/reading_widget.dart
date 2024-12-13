import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';

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

    return Column(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: SizedBox(
                  height: totalH * 0.06, // 5% of total height
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: AutoSizeText(
                      "Road Type",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: (w > 600) ? 28 : 24,
                        color: textColor,
                      ),
                      maxFontSize: (w > 600) ? 28 : 24,
                      minFontSize: 16,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
            Gap(totalH * 0.02), // 1.5% of total height
            SizedBox(
              width: w * 0.90,
              height: (h > 800) ? h * 0.10 : h * 0.12,
              child: LayoutBuilder(builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    children: [
                      Obx(() {
                        return InkWell(
                          onTap: () {
                            accDataController.currRoadType.value = "Paved";
                            accDataController.currRoadIndex.value =
                                accDataController.roads.indexOf(
                                    accDataController.currRoadType.value);
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
                                      : w *
                                          0.1, // Larger icon size for wide screens
                                  height: (w > 600) ? w * 0.12 : w * 0.1,
                                  child: SvgPicture.asset(
                                    colorFilter: ColorFilter.mode(
                                      (accDataController.currRoadType.value ==
                                              "Paved")
                                          ? Colors.blue
                                          : Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                    assetsPath.pave,
                                  ),
                                ),
                                Gap(constraints.maxHeight * 0.05),
                                Center(
                                  child: AutoSizeText(
                                    "Paved",
                                    style: GoogleFonts.inter(
                                      fontSize: (w > 600) ? 20 : 18,
                                      fontWeight: FontWeight.w400,
                                      color: (accDataController
                                                  .currRoadType.value ==
                                              "Paved")
                                          ? activeColor
                                          : Colors.black,
                                    ),
                                    group: textGroup,
                                    maxFontSize: (w > 600) ? 20 : 18,
                                    minFontSize: 12,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Gap((w > 600) ? w * 0.03 : w * 0.05),
                      Obx(() {
                        return InkWell(
                          onTap: () {
                            accDataController.currRoadType.value = "Unpaved";
                            accDataController.currRoadIndex.value =
                                accDataController.roads.indexOf(
                                    accDataController.currRoadType.value);
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
                                      : w *
                                          0.1, // Larger icon size for wide screens
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
                                Gap(constraints.maxHeight * 0.05),
                                Center(
                                  child: AutoSizeText(
                                    "Un-Paved",
                                    style: GoogleFonts.inter(
                                      fontSize: (w > 600) ? 20 : 18,
                                      fontWeight: FontWeight.w400,
                                      color: (accDataController
                                                  .currRoadType.value ==
                                              "Unpaved")
                                          ? activeColor
                                          : Colors.black,
                                    ),
                                    group: textGroup,
                                    maxFontSize: (w > 600) ? 20 : 18,
                                    minFontSize: 12,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Gap(w * 0.05),
                      Obx(() {
                        return InkWell(
                          onTap: () {
                            accDataController.currRoadType.value = "Pedestrian";
                            accDataController.currRoadIndex.value =
                                accDataController.roads.indexOf(
                                    accDataController.currRoadType.value);
                            accDataController.isPedestrianFound = true;
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
                                            ? Colors.blue
                                            : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  Gap(constraints.maxHeight * 0.05),
                                  Center(
                                    child: AutoSizeText(
                                      "Pedestrian",
                                      style: GoogleFonts.inter(
                                        fontSize: (w > 600) ? 20 : 18,
                                        fontWeight: FontWeight.w400,
                                        color: (accDataController
                                                    .currRoadType.value ==
                                                "Pedestrian")
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                      group: textGroup,
                                      maxFontSize: (w > 600) ? 20 : 18,
                                      minFontSize: 12,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
            Gap(w * 0.05),
            SizedBox(
              width: w * 0.90,
              height: h * 0.12, // 12% of total height
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return InkWell(
                            onTap: () async {
                              // break
                              accDataController.bnb.value = 1;
                              // after 2 sec
                              if (!accDataController.showStartButton) {
                                Future.delayed(const Duration(seconds: 2))
                                    .then((_) {
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
                                        : w *
                                            0.1, // Larger icon size for wide screens
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
                                  Gap(constraints.maxHeight * 0.1),
                                  Center(
                                    child: AutoSizeText(
                                      "Break",
                                      style: GoogleFonts.inter(
                                        fontSize: (w > 600) ? 20 : 18,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            (accDataController.bnb.value == 1)
                                                ? activeColor
                                                : Colors.black,
                                      ),
                                      group: textGroup,
                                      maxFontSize: (w > 600) ? 20 : 18,
                                      minFontSize: 12,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        Gap(w * 0.05),
                        Obx(() {
                          return InkWell(
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
                                        : w *
                                            0.1, // Larger icon size for wide screens
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
                                  Gap(constraints.maxHeight * 0.1),
                                  Center(
                                    child: AutoSizeText(
                                      "No-Break",
                                      style: GoogleFonts.inter(
                                        fontSize: (w > 600) ? 20 : 18,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            (accDataController.bnb.value == 0)
                                                ? activeColor
                                                : Colors.black,
                                      ),
                                      group: textGroup,
                                      maxFontSize: (w > 600) ? 20 : 18,
                                      minFontSize: 12,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Gap(totalH * 0.04), // 2.5% of total height
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: SizedBox(
              height: totalH * 0.06, // 5% of total height
              child: FittedBox(
                fit: BoxFit.contain,
                child: AutoSizeText(
                  "Sensor Reading",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: (w > 600) ? 28 : 24,
                    color: textColor,
                  ),
                  maxFontSize: (w > 600) ? 28 : 24,
                  minFontSize: 16,
                  maxLines: 1,
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
                              fontSize: w * 0.045,
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
                              fontSize: w * 0.04,
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
                                  style: labelTextStyle,
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
                              fontSize: w * 0.04,
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
                                  style: labelTextStyle,
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
                            style: labelTextStyle
                              ..copyWith(
                                fontSize: w * 0.04,
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
                                  style: labelTextStyle,
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
                                fontSize: w *
                                    0.045, // Scales text size based on width
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
                                fontSize:
                                    w * 0.04, // Scales text size based on width
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
                                    style: labelTextStyle,
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
                                fontSize:
                                    w * 0.04, // Scales text size based on width
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
                                    style: labelTextStyle,
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
                                fontSize:
                                    w * 0.04, // Scales text size based on width
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
                                    style: labelTextStyle,
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
