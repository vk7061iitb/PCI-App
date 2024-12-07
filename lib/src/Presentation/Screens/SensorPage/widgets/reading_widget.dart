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

    return Column(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: SizedBox(
                  height: totalH * 0.05, // 5% of total height
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      "Road Type",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(totalH * 0.015), // 1.5% of total height
            SizedBox(
              width: w * 0.90,
              height: h * 0.12, // 12% of total height
              child: LayoutBuilder(builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    children: [
                      Obx(() {
                        return InkWell(
                          onTap: () {
                            if (accDataController.showStartButton) {
                              accDataController.currRoadType.value = "Paved";
                            }
                          },
                          radius: 25,
                          borderRadius: BorderRadius.circular(5),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: w * 0.1,
                                  height: w * 0.1,
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
                                Gap(constraints.maxWidth * 0.05),
                                Center(
                                  child: Text(
                                    "Paved",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: (accDataController
                                                  .currRoadType.value ==
                                              "Paved")
                                          ? activeColor
                                          : Colors.black,
                                    ),
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
                            if (accDataController.showStartButton) {
                              accDataController.currRoadType.value = "Unpaved";
                            }
                          },
                          radius: 25,
                          borderRadius: BorderRadius.circular(5),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: w * 0.1,
                                  height: w * 0.1,
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
                                Gap(constraints.maxWidth * 0.05),
                                Center(
                                  child: Text(
                                    "Un-Paved",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: (accDataController
                                                  .currRoadType.value ==
                                              "Unpaved")
                                          ? activeColor
                                          : Colors.black,
                                    ),
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
                            if (accDataController.showStartButton) {
                              accDataController.currRoadType.value =
                                  "Pedestrian";
                            }
                          },
                          radius: 25,
                          borderRadius: BorderRadius.circular(5),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: w * 0.1,
                                    height: w * 0.1,
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
                                  Gap(constraints.maxWidth * 0.05),
                                  Text(
                                    "Pedestrian",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: (accDataController
                                                  .currRoadType.value ==
                                              "Pedestrian")
                                          ? Colors.blue
                                          : Colors.black,
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
          ],
        ),

        Gap(totalH * 0.025), // 2.5% of total height
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05),
            child: SizedBox(
              height: totalH * 0.05, // 5% of total height
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  "Sensor Reading",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        Gap(totalH * 0.015), // 1.5% of total height

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
                            style: sensorNameStyle,
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
                            style: labelTextStyle,
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
                            style: labelTextStyle,
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
                            style: labelTextStyle,
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
                              style: sensorNameStyle,
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
                              style: labelTextStyle,
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
                              style: labelTextStyle,
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
                              style: labelTextStyle,
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
