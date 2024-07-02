import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/reading_widget.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/start_end_widget.dart';
import 'package:pci_app/src/Presentation/Widgets/custom_appbar.dart';
import '../../../../Objects/data.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AccDataController accDataController = Get.put(AccDataController());
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xFFF3EDF5),
      body: ListView(
        children: [
          const Gap(20),
          const StartButton(),
          const Gap(20),
          Center(
            child: Obx(() {
              return Text(
                accDataController.showStartButton
                    ? startMessage
                    : progressMessage,
                style: GoogleFonts.inter(
                  color: accDataController.sensorScreencolor.updateMessage,
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.textScalerOf(context).scale(18),
                ),
              );
            }),
          ),
          const Gap(20),
          const ReadingWidget(),
        ],
      ),
    );
  }
}
