import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/reading_widget.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/start_end_widget.dart';
import 'package:pci_app/src/Presentation/Widgets/custom_appbar.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    double totalH = h -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        0.18 * w;
    logger.d('Height: $h, Total Height: $totalH');

    AccDataController accDataController = Get.find();
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar as Sliver
          const CustomSliverAppBar(),
          // Content using SliverList
          SliverList(
            delegate: SliverChildListDelegate([
              Gap(totalH * 0.015), // 1.5% of totalH
              const StartButton(), // 30% of totalH
              Gap(totalH * 0.02), // 2% of totalH
              // Message Text
              SizedBox(
                height: totalH * 0.05, // 5% of totalH
                child: Center(
                  child: Obx(() {
                    return FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        accDataController.showStartButton
                            ? accDataController.startMessage
                            : accDataController.progressMessage,
                        style: GoogleFonts.inter(
                          color:
                              accDataController.sensorScreencolor.updateMessage,
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: totalH * 0.02),
              // 1.5 + 30 + 2 + 5 + 2 = 40.5% of totalH
              const ReadingWidget(),
            ]),
          ),
        ],
      ),
    );
  }
}
