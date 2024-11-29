import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

GetSnackBar customGetSnackBar(String title, String message, IconData icon) {
  return GetSnackBar(
    icon: Icon(
      icon,
      color: Colors.black,
    ),
    titleText: Text(
      title,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.inter(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ),
    isDismissible: true,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.white,
    margin: const EdgeInsets.all(15),
    duration: const Duration(seconds: 5),
    borderRadius: 15,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
      ),
    ],
  );
}
