import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';
import '../../../../../Utils/format_chainage.dart';
import '../../../Controllers/sensor_controller.dart';

class JourneySummary extends StatelessWidget {
  const JourneySummary({super.key});

  @override
  Widget build(BuildContext context) {
    AccDataController accDataController = Get.find<AccDataController>();
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: w * 0.26,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Distance",
                  style: GoogleFonts.inter(
                    fontSize: fs.bodyTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: Obx(() => AutoSizeText(
                        formatChainage(
                            accDataController.totalDistanceTravelled.value),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: fs.heading2FontSize,
                          color: textColor,
                        ),
                      )),
                ),
                Text(
                  "km",
                  style: GoogleFonts.inter(
                    fontSize: fs.smallTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap(0.05 * w),
        // speed column
        SizedBox(
          width: 0.26 * w,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  "Speed",
                  style: GoogleFonts.inter(
                    fontSize: fs.bodyTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: Obx(() => AutoSizeText(
                        formatSpeed(accDataController.currSpeed.value),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: fs.heading2FontSize,
                          color: textColor,
                        ),
                      )),
                ),
                Text(
                  "kmph",
                  style: GoogleFonts.inter(
                    fontSize: fs.smallTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap(0.05 * w),
        // speed column
        SizedBox(
          width: 0.26 * w,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  "Duration",
                  style: GoogleFonts.inter(
                    fontSize: fs.bodyTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                RepaintBoundary(
                    child: Obx(
                  () => AutoSizeText(
                    formatDuration(accDataController.elapsedTime.value),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: fs.heading2FontSize,
                      color: textColor,
                    ),
                  ),
                )),
                Text(
                  "min",
                  style: GoogleFonts.inter(
                    fontSize: fs.smallTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    textStyle: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
