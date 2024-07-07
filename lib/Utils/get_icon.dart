import 'package:flutter/material.dart';

IconData getIcon(String dropdownValue) {
  switch (dropdownValue) {
    case 'Bike':
      return Icons.directions_bike_rounded;
    case 'Car':
      return Icons.directions_car_rounded;
    case 'Bus':
      return Icons.directions_bus_rounded;
    case 'Auto':
      return Icons.electric_rickshaw_rounded;
    default:
      return Icons.directions_run_rounded;
  }
}
