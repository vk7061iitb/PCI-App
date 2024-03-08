import 'package:flutter/material.dart';

class ReadingsWidget extends StatelessWidget {
  final String iconPath;
  final String name;
  final double xValue;
  final double yValue;
  final double zValue;
  const ReadingsWidget(
      {required this.iconPath,
      required this.name,
      required this.xValue,
      required this.yValue,
      required this.zValue,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
