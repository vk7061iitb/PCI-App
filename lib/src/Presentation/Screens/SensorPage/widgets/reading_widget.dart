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
    TextStyle style1 = GoogleFonts.inter(
      fontSize: MediaQuery.textScalerOf(context).scale(18),
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    TextStyle style2 = GoogleFonts.inter(
      fontSize: MediaQuery.textScalerOf(context).scale(16),
      fontWeight: FontWeight.w500,
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
                                style: style1,
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
                              style: style2,
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
                                    style: style2,
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
                              style: style2,
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
                                    style: style2,
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
                              style: style2,
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
                                    style: style2,
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
                                style: style1,
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
                                  style: style1,
                                ),
                              ],
                            ),
                          ),
                          RowWidget(
                              label: "Lat",
                              value: accDataController.isRecordingData
                                  ? devicePosition.latitude
                                  : 0.000),
                          RowWidget(
                              label: "Lon",
                              value: accDataController.isRecordingData
                                  ? devicePosition.longitude
                                  : 0.000),
                          RowWidget(
                              label: "Acc",
                              value: accDataController.isRecordingData
                                  ? devicePosition.accuracy
                                  : 0.000),
                        ],
                      );
                    },
                  ),
                ),
                const SpeedWidget(),
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
    TextStyle style2 = GoogleFonts.inter(
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
            style: style2,
          ),
          Container(
            width: 80,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(widget.value.toStringAsFixed(3), style: style2),
            ),
          ),
        ],
      );
    });
  }
}

class SpeedWidget extends StatefulWidget {
  const SpeedWidget({super.key});

  @override
  State<SpeedWidget> createState() => _SpeedWidgetState();
}

class _SpeedWidgetState extends State<SpeedWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
