import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/reading_widget.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/start_end_widget.dart';
import 'package:pci_app/src/Presentation/Widgets/custom_appbar.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AccDataController accDataController = Get.find();
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar as Sliver
          const CustomSliverAppBar(),

          // Content using SliverList
          SliverList(
            delegate: SliverChildListDelegate([
              Gap(MediaQuery.sizeOf(context).height * 0.03),
              const StartButton(),
              Gap(MediaQuery.sizeOf(context).height * 0.03),

              // Message Text
              Center(
                child: Obx(() {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      accDataController.showStartButton
                          ? accDataController.startMessage
                          : accDataController.progressMessage,
                      style: GoogleFonts.inter(
                        color:
                            accDataController.sensorScreencolor.updateMessage,
                        fontWeight: FontWeight.w500,
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.025),
              const ReadingWidget(),
            ]),
          ),
        ],
      ),
    );
  }
}
