// Function to get road color based on quality

import 'package:flutter/material.dart';

Color getRoadColor(String quality) {
  switch (quality) {
    case '1':
      return Colors.red;
    case '2':
      return Colors.orange;
    case '3':
      return Colors.yellow;
    case '4':
      return Colors.blue;
    case '5':
      return Colors.green;
    default:
      return Colors.black; 
  }
}
