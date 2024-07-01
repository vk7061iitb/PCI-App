import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

SnackBar customSnackBar(String message) {
  return SnackBar(
    content: Text(
      message,
      style: GoogleFonts.inter(
        color: Colors.black87,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
    showCloseIcon: true,
    behavior: SnackBarBehavior.floating,
    closeIconColor: Colors.black87,
    backgroundColor: const Color(0xFFF3EDF5),
    padding: const EdgeInsets.all(12),
    duration: const Duration(seconds: 5),
    elevation: 2.0,
    shape: const RoundedRectangleBorder(
      side: BorderSide.none,
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
  );
}
