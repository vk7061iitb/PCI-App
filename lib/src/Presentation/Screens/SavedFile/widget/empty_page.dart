import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class EmptyPage extends StatelessWidget {
  final String iconPath;
  final double fontSize;
  final double iconSize;
  const EmptyPage({
    super.key,
    required this.iconPath,
    required this.fontSize,
    required this.iconSize,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          iconPath,
          width: iconSize,
        ),
        Center(
          child: Text(
            'There are no files to display',
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
