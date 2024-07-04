import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

GetSnackBar customGetSnackBar(String message) {
  return GetSnackBar(
    messageText: Text(
      message,
      style: GoogleFonts.inter(
        color: Colors.black87,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    ),
    isDismissible: true,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFF3EDF5),
    margin: const EdgeInsets.all(12),
    duration: const Duration(seconds: 5),
    borderRadius: 20,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
      ),
    ],
  );
}
