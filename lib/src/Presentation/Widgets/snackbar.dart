import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Creates a custom GetSnackBar widget with a title, message, and icon.
///
/// The GetSnackBar is a widget from the GetX package that displays a
/// temporary notification at the bottom of the screen.
///
/// Parameters:
/// - `title` (String): The title text to display in the snackbar.
/// - `message` (String): The message text to display in the snackbar.
/// - `icon` (IconData): The icon to display in the snackbar.
///
/// Returns:
/// - `GetSnackBar`: A configured GetSnackBar widget.
GetSnackBar customGetSnackBar(String title, String message, IconData icon) {
  Color boxColor = Colors.blueAccent;
  return GetSnackBar(
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.white,
    borderRadius: 15,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: const Duration(seconds: 4), // Dismiss after 4 seconds
    isDismissible: true,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2), // Subtle shadow
        spreadRadius: 0,
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],

    titleText: Padding(
      padding: const EdgeInsets.only(bottom: 4), // Add some spacing
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: 28, // Slightly larger icon
          ),
          const Gap(10),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ],
      ),
    ),
    messageText: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.fade, // Truncate long messages
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: message));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "Copy",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
