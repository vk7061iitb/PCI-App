import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

GetSnackBar customGetSnackBar(String message, IconData icon) {
  return GetSnackBar(
    icon: Icon(
      icon,
      color: Colors.white,
    ),
    messageText: Text(
      message,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ),
    isDismissible: true,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.black87,
    margin: const EdgeInsets.all(15),
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
