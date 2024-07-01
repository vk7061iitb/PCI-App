import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../Utils/sensor_page_color.dart';

class StartEndButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool showStartButton;
  const StartEndButton(
      {required this.label,
      required this.onPressed,
      required this.showStartButton,
      super.key});

  @override
  Widget build(BuildContext context) {
    SensorPageColor sensorScreencolor = SensorPageColor();
    return Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              boxShadow: [
                BoxShadow(
                  color: sensorScreencolor.shadowColor,
                  blurRadius: 2,
                  spreadRadius: 0,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(85),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: showStartButton
                        ? sensorScreencolor.startCircle
                        : sensorScreencolor.endCircle,
                    width: MediaQuery.of(context).size.width * 0.06,
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignInside),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: MediaQuery.textScalerOf(context).scale(36),
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
