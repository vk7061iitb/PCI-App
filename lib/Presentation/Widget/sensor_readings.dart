import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';

class SensorReading extends StatelessWidget {
  final List<double> accData;
  final List<double> gyroData;
  const SensorReading(
      {required this.accData, required this.gyroData, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LiveSensorReadings(
              iconPath: accelerationImgPath,
              name: "Acceleration",
              dataList: accData,
            ),
            LiveSensorReadings(
              iconPath: gyroscopeImgPath,
              name: "Gyroscope",
              dataList: gyroData,
            ),
          ],
        ),
        const Gap(5),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          const Gap(15),
                          SizedBox(
                              width: 25,
                              height: 25,
                              child: Image.asset(locationImgPath)),
                          const Gap(10),
                          Text(
                            "Location",
                            style: style1,
                          ),
                        ],
                      ),
                      RowWidget(
                          label: "Lat",
                          value: isRecordingData
                              ? devicePosition.latitude
                              : 0.000),
                      RowWidget(
                          label: "Lon",
                          value: isRecordingData
                              ? devicePosition.longitude
                              : 0.000),
                      RowWidget(
                          label: "Acc",
                          value: isRecordingData
                              ? devicePosition.accuracy
                              : 0.000),
                    ],
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

class LiveSensorReadings extends StatelessWidget {
  final String iconPath;
  final String name;
  final List<double> dataList;
  const LiveSensorReadings(
      {required this.iconPath,
      required this.name,
      required this.dataList,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(15)),
        child: LayoutBuilder(builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 0.15 * constraints.maxWidth,
                      height: 0.15 * constraints.maxHeight,
                      child: Image.asset(iconPath),
                    ),
                    const Gap(2),
                    Text(
                      name,
                      style: style1,
                    ),
                  ],
                ),
                RowWidget(label: "X", value: dataList[0]),
                RowWidget(label: "Y", value: dataList[1]),
                RowWidget(label: "Z", value: dataList[2]),
              ],
            ),
          );
        }));
  }
}

class RowWidget extends StatefulWidget {
  final String label;
  final double value;

  const RowWidget({super.key, required this.label, required this.value});

  @override
  State<RowWidget> createState() => RowWidgetState();
}

class RowWidgetState extends State<RowWidget> {
  @override
  Widget build(BuildContext context) {
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

TextStyle style1 = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

TextStyle style2 = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.black,
);
