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
    AccDataController accDataController = Get.find();
    TextStyle sensorNameStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
    TextStyle labelTextStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );

    TextStyle speedTextStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    TextStyle speedValueTextStyle = GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    return Column(
      children: [
        Row(
          children: [
            // Accelerometer Reading
            Gap(MediaQuery.sizeOf(context).width * 0.025),
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      fit: BoxFit.contain,
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
                              color: Colors.white,
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
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
                              color: Colors.white,
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
            Gap(MediaQuery.sizeOf(context).width * 0.05),
            // Gyroscope Reading
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(15)),
              child: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Gap(constraints.maxWidth * 0.05),
                          SizedBox(
                            width: 0.15 * constraints.maxWidth,
                            height: 0.15 * constraints.maxHeight,
                            child: SvgPicture.asset(assetsPath.gyroscope),
                          ),
                          Gap(constraints.maxWidth * 0.05),
                          Text(
                            "Gyroscope",
                            style: sensorNameStyle,
                          ),
                          Gap(constraints.maxWidth * 0.05),
                        ],
                      ),
                    ),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                "0.000",
                                style: labelTextStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                "0.000",
                                style: labelTextStyle,
                              ),
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
                            "Z",
                            style: labelTextStyle,
                          ),
                          Gap(constraints.maxWidth * 0.1),
                          Container(
                            width: constraints.maxWidth * 0.50,
                            height: constraints.maxHeight * 0.20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                "0.000",
                                style: labelTextStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            Gap(MediaQuery.sizeOf(context).width * 0.025),
          ],
        ),
        Gap(MediaQuery.sizeOf(context).width * 0.05),
        Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.width * 0.45,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
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
              Container(
                width: MediaQuery.of(context).size.width * 0.30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(() {
                          return Text(
                            accDataController.isRecordingData
                                ? (accDataController.devicePosition.speed * 3.6)
                                    .toStringAsFixed(2)
                                : "0.00",
                            style: speedValueTextStyle,
                          );
                        }),
                        Text(
                          "km/h",
                          style: speedTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(MediaQuery.of(context).size.width * 0.05),
            ],
          ),
        )
      ],
    );
  }
}

class RowWidget extends StatefulWidget {
  const RowWidget({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  State<RowWidget> createState() => RowWidgetState();
}

class RowWidgetState extends State<RowWidget> {
  @override
  Widget build(BuildContext context) {
    TextStyle labelTextStyle = GoogleFonts.inter(
      fontSize: MediaQuery.textScalerOf(context).scale(16),
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            widget.label,
            style: labelTextStyle,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.21,
            height: (MediaQuery.of(context).size.width * 0.2) * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child:
                  Text(widget.value.toStringAsFixed(3), style: labelTextStyle),
            ),
          ),
        ],
      );
    });
  }
}
