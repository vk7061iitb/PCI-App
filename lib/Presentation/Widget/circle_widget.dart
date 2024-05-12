import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import '../Themes/sensor_page_color.dart';

class CircleWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const CircleWidget({required this.label, required this.onPressed, super.key});

  @override
  State<CircleWidget> createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget> {
  @override
  Widget build(BuildContext context) {
    SensorPageColor sensorScreencolor = SensorPageColor();
    return Stack(
      children: [
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                width: 25,
              ),
              boxShadow: [
                BoxShadow(
                  color: sensorScreencolor.shadowColor,
                  blurRadius: 5,
                  spreadRadius: 0,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: InkWell(
            onTap: widget.onPressed,
            radius: 50,
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: showStartButton
                      ? sensorScreencolor.startCircle
                      : sensorScreencolor.endCircle,
                  width: 25,
                  style: BorderStyle.solid,
                  strokeAlign: BorderSide.strokeAlignInside
                ),
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
