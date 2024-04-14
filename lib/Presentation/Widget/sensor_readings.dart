import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveSensorReadings extends StatelessWidget {
  final String iconPath;
  final String name;
  final double xValue;
  final double yValue;
  final double zValue;
  const LiveSensorReadings(
      {required this.iconPath,
      required this.name,
      required this.xValue,
      required this.yValue,
      required this.zValue,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      height: 175,
      decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          const Gap(12),
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
          const Gap(12),
          rowWidget('X', xValue),
          const Gap(12),
          rowWidget('Y', yValue),
          const Gap(12),
          rowWidget('Z', zValue),
        ],
      ),
    );
  }
}

class PositionReadings extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double locationAcurrary;
  const PositionReadings(
      {required this.latitude,
      required this.longitude,
      required this.locationAcurrary,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(15),
      ),

    );
  }
}

Widget rowWidget(String label, double value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text(
        label,
        style: style2,
      ),
      Container(
        width: 90,
        height: 25,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Text(
            value.toStringAsFixed(3),
            style: style2,
          ),
        ),
      ),
    ],
  );
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
