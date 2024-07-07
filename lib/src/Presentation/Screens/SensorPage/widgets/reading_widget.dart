import 'package:flutter/material.dart';
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
      fontSize: MediaQuery.textScalerOf(context).scale(18),
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    TextStyle labelTextStyle = GoogleFonts.inter(
      fontSize: MediaQuery.textScalerOf(context).scale(16),
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );

    TextStyle speedTextStyle = GoogleFonts.inter(
      fontSize: MediaQuery.textScalerOf(context).scale(16),
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    TextStyle speedValueTextStyle = GoogleFonts.inter(
      fontSize: MediaQuery.textScalerOf(context).scale(24),
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Accelerometer Reading
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.width * 0.45,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(15)),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 0.15 * constraints.maxWidth,
                                height: 0.15 * constraints.maxHeight,
                                child: Image.asset(assetsPath.accelerometer),
                              ),
                              const Gap(2),
                              Text(
                                "Acceleration",
                                style: sensorNameStyle,
                              ),
                            ],
                          ),
                        ),
                        // X - Acceleration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "X",
                              style: labelTextStyle,
                            ),
                            Container(
                              width: 80,
                              height: 25,
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
                        // Y - Acceleration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Y",
                              style: labelTextStyle,
                            ),
                            Container(
                              width: 80,
                              height: 25,
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
                        // Z - Acceleration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Z",
                              style: labelTextStyle,
                            ),
                            Container(
                              width: 80,
                              height: 25,
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
                      ],
                    );
                  }),
                );
              },
            ),
            // Gyroscope Reading
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.width * 0.45,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(15)),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5, left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 0.15 * constraints.maxWidth,
                                height: 0.15 * constraints.maxHeight,
                                child: Image.asset(assetsPath.gyroscope),
                              ),
                              const Gap(2),
                              Text(
                                "Gyroscope",
                                style: sensorNameStyle,
                              ),
                            ],
                          ),
                        ),
                        const RowWidget(label: "X", value: 0),
                        const RowWidget(label: "Y", value: 0),
                        const RowWidget(label: "Z", value: 0),
                      ],
                    );
                  }),
                );
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 5, left: 5),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 0.15 * constraints.maxWidth,
                                  height: 0.15 * constraints.maxHeight,
                                  child: Image.asset(
                                    assetsPath.location,
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  "Location",
                                  style: sensorNameStyle,
                                ),
                              ],
                            ),
                          ),
                          Obx(() {
                            return RowWidget(
                                label: "Lat",
                                value: accDataController.isRecordingData
                                    ? accDataController.devicePosition.latitude
                                    : 0.000);
                          }),
                          Obx(() {
                            return RowWidget(
                                label: "Lon",
                                value: accDataController.isRecordingData
                                    ? accDataController.devicePosition.longitude
                                    : 0.000);
                          }),
                          Obx(() {
                            return RowWidget(
                                label: "Acc",
                                value: accDataController.isRecordingData
                                    ? accDataController.devicePosition.accuracy
                                    : 0.000);
                          }),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
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
                const Gap(20),
              ],
            ),
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
            width: 80,
            height: 25,
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
