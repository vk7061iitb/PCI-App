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
    return Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                width: MediaQuery.of(context).size.width * 0.06,
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
              locationController.checkLocationService();
              if (accDataController.showStartButton) {
                accDataController.onStartButtonPressed();
              } else {
                await accDataController.onEndButtonPressed();
                Get.bottomSheet(
                  const SaveFile(),
                  isDismissible: false,
                  enableDrag: false,
                  ignoreSafeArea: false,
                );
              }
            },
            borderRadius: BorderRadius.circular(85),
            child: Obx(() {
              return Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accDataController.showStartButton
                          ? accDataController.sensorScreencolor.startCircle
                          : accDataController.sensorScreencolor.endCircle,
                      width: MediaQuery.of(context).size.width * 0.06,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Center(
                  child: Text(
                    accDataController.showStartButton ? "Start" : "End",
                    style: GoogleFonts.inter(
                      fontSize: MediaQuery.textScalerOf(context).scale(36),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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
