import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';

class RoadTypeButton extends StatelessWidget {
  final double width;
  final double height;
  final String tooltipMessage;
  final String buttonImgPath;
  final String label;
  final RxString selectedRoadType;
  final VoidCallback onTap;
  const RoadTypeButton(
      {super.key,
      required this.width,
      required this.height,
      required this.buttonImgPath,
      required this.tooltipMessage,
      required this.label,
      required this.selectedRoadType,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    FontSize fs = getFontSize(width);
    return SizedBox(
      width: 0.3 * width,
      child: Tooltip(
        message: tooltipMessage,
        child: InkWell(
          onTap: onTap,
          radius: 25,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                SizedBox(
                  width: (width > 600)
                      ? width * 0.12
                      : width * 0.1, // Larger icon size for wide screens
                  height: (width > 600) ? width * 0.12 : width * 0.1,
                  child: RepaintBoundary(
                    child: Obx(
                      () => SvgPicture.asset(
                        buttonImgPath,
                        colorFilter: ColorFilter.mode(
                          (selectedRoadType.value == label)
                              ? activeColor
                              : Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(height * 0.01),
                Center(
                    child: RepaintBoundary(
                  child: Obx(
                    () => AutoSizeText(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: fs.bodyTextFontSize,
                        fontWeight: (selectedRoadType.value == label)
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: (selectedRoadType.value == label)
                            ? activeColor
                            : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
