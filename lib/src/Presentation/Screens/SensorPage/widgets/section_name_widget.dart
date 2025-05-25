import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';

class SectionName extends StatelessWidget {
  final double totalH;
  final double width;
  final String label;
  const SectionName({
    super.key,
    required this.totalH,
    required this.width,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    FontSize fs = getFontSize(width);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: SizedBox(
          height: totalH * 0.05, // 5% of total height
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AutoSizeText(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: fs.heading2FontSize,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
