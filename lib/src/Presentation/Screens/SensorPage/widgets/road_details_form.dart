import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Objects/data.dart';
import '../../../../../Utils/font_size.dart';

class RoadDetailsForm extends StatelessWidget {
  const RoadDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(5),
              Text(
                "Road Details",
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const Gap(10),
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Carriage width",
                      style: GoogleFonts.inter(
                        fontSize: fs.appBarFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Carriage width',
                        labelStyle: GoogleFonts.inter(
                          fontSize: fs.bodyTextFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Text(
                      "Left Shoulder",
                      style: GoogleFonts.inter(
                        fontSize: fs.appBarFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Left Shoulder',
                        labelStyle: GoogleFonts.inter(
                          fontSize: fs.bodyTextFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Text(
                      "Right Shoulder",
                      style: GoogleFonts.inter(
                        fontSize: fs.appBarFontSize,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Right Shoulder',
                        labelStyle: GoogleFonts.inter(
                          fontSize: fs.bodyTextFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        isDense: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Text(
                          "Total width",
                          style: GoogleFonts.inter(
                            fontSize: fs.appBarFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          "500 m",
                          style: GoogleFonts.inter(
                            fontSize: fs.appBarFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
