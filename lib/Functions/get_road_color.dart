// Function to get road color based on quality
import 'package:flutter/material.dart';

Color getRoadColor(String quality) {
  switch (quality) {
    case '1':
      return const Color(0xFF388E3C); // Best quality
    case '2':
      return const Color(0xFFCDDC39);
    case '3':
      return const Color(0xFF1A237E);
    case '4':
      return const Color(0xFF795548);
    case '5':
      return const Color(0xFFF44336);
    case '6':
      return const Color(0xFF448AFF); // Worst quality
    default:
      return Colors.black; // Default color
  }
}
