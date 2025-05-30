import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/src/Presentation/Controllers/location_permission.dart';
import 'package:pciapp/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pciapp/src/Presentation/Screens/SensorPage/widgets/submit_data_sheet.dart';
import '../../../../../Utils/font_size.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    AccDataController accDataController = Get.find();
    LocationController locationController = Get.find();

    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    double totalH = h -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        0.18 * w;
    double buttonWidth = (w > 500 && totalH > 300)
        ? totalH * 0.04 // Use 2% of total height if height is sufficient
        : (totalH <= 300)
            ? totalH * 0.05 // Scale up for very small heights
            : w * 0.062; // Default behavior for smaller screens
    FontSize fs = getFontSize(w);
    return Stack(
      children: [
        Center(
          child: Container(
            width: totalH * 0.3,
            height: totalH * 0.3,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                width: buttonWidth,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: Offset(0, 4)),
              ],
            ),
          ),
        ),
        Center(
          child: InkWell(
            onTap: () async {
              bool hasLocPerm = await locationController.locationPermission();
              logger.i(hasLocPerm);
              if (accDataController.showStartButton) {
                accDataController.onStartButtonPressed();
              } else {
                await accDataController.onEndButtonPressed();
                Get.bottomSheet(
                  SubmitDataSheet(),
                  isDismissible: false,
                  enableDrag: false,
                  ignoreSafeArea: false,
                );
              }
            },
            borderRadius: BorderRadius.circular(totalH * 0.3 - buttonWidth),
            child: Obx(() {
              return Container(
                width: totalH * 0.3,
                height: totalH * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accDataController.showStartButton
                          ? accDataController.sensorScreencolor.startCircle
                          : accDataController.sensorScreencolor.endCircle,
                      width: buttonWidth,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        accDataController.showStartButton ? "Start" : "End",
                        style: GoogleFonts.inter(
                          fontSize: fs.heading1FontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
