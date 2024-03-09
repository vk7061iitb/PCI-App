import 'package:flutter/material.dart';

import 'Presentation/Screens.dart/sensor_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      showSemanticsDebugger: false,
      home: HomePage(),
    );
  }
}
