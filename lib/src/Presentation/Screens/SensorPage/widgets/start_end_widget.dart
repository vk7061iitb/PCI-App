import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/location_permission.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/save_file_widget.dart';

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
    return Stack(
      children: [
        Center(
          child: Container(
            width: totalH * 0.3,
            height: totalH * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                width: w * 0.065,
              ),
              boxShadow: [
                BoxShadow(
                  color: accDataController.sensorScreencolor.shadowColor,
                  blurRadius: 2,
                  spreadRadius: 0,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: InkWell(
            onTap: () async {
              await locationController.locationPermission();
              if (accDataController.showStartButton) {
                accDataController.onStartButtonPressed();
              } else {
                await accDataController.onEndButtonPressed();
                Get.bottomSheet(
                  SaveFile(),
                  isDismissible: false,
                  enableDrag: false,
                  ignoreSafeArea: false,
                );
              }
            },
            borderRadius: BorderRadius.circular(100),
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
                      width: MediaQuery.of(context).size.width * 0.065,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      accDataController.showStartButton ? "Start" : "End",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
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
