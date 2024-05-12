import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';

class SensorReading extends StatelessWidget {
  final List<double> accData;
  final List<double> gyroData;
  const SensorReading({required this.accData, required this.gyroData, super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LiveSensorReadings(
            iconPath: accelerationImgPath,
            name: "Acceleration",
            dataList: accData,
          ),
          const Gap(5),
          LiveSensorReadings(
            iconPath: gyroscopeImgPath,
            name: "Gyroscope",
            dataList: gyroData,
          ),
        ],
      ),
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
      width: 165,
      height: 175,
      decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(iconPath),
                ),
                Text(
                  name,
                  style: style1,
                )
              ],
            ),
            RowWidget(label: "X", value: dataList[0]),
            RowWidget(label: "Y", value: dataList[1]),
            RowWidget(label: "Z", value: dataList[2]),
          ],
        ),
      ),
    );
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
  void changeState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(widget.label, style: style2),
        Container(
          width: 90,
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
