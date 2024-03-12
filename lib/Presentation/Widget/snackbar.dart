import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

SnackBar customSnackBar(String message) {
  return SnackBar(
    content: Text(
      message,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
    backgroundColor: Colors.black87,
    showCloseIcon: true,
    closeIconColor: Colors.white,
    duration: const Duration(seconds: 5),
  );
}
