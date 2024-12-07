// Function to get road color based on quality
import 'package:flutter/material.dart';

Color getRoadColor(double quality) {
  switch (quality) {
    case 1:
      return Colors.red;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.yellow;
    case 4:
      return Colors.blue;
    case 5:
      return Colors.green;
    default:
      return Colors.black;
  }
}

Color getVelocityColor(double velocity) {
  if (velocity >= 30) {
    return Colors.green;
  } else if (velocity > 20) {
    return Colors.blue;
  } else if (velocity > 10) {
    return Colors.yellow;
  } else if (velocity > 5) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
