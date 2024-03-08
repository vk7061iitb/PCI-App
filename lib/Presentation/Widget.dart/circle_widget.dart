import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            duration: const Duration(seconds: 1),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                border: Border.all(
                  width: 15,
                ),
                boxShadow: [
                  BoxShadow(
                    color: sensorScreencolor.shadowColor,
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]),
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
                border: Border.all(
                  color: sensorScreencolor.startCircle,
                  width: 15,
                ),
              ),
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
