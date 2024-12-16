import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Utils/font_size.dart';
import '../../../Controllers/sensor_controller.dart';

class MessageWidget extends StatefulWidget {
  const MessageWidget({
    super.key,
  });

  @override
  MessageWidgetState createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCountAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller to animate dots' change
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration to change dots
    )..repeat(reverse: true); // Repeat animation back and forth

    // Create an animation that changes dot count from 1 to 3 and back
    _dotCountAnimation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AccDataController accDataController = Get.find();
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    return Center(
      child: FittedBox(
        child: AnimatedBuilder(
          animation: _dotCountAnimation,
          builder: (context, child) {
            String dots = ('.' * _dotCountAnimation.value).padRight(4);
            return Text(
              accDataController.showStartButton
                  ? 'Tap "Start" to collect data'
                  : 'Collecting the data $dots',
              style: GoogleFonts.inter(
                color: accDataController.sensorScreencolor.updateMessage,
                fontWeight: FontWeight.w500,
                fontSize: fs.appBarFontSize,
              ),
            );
          },
        ),
      ),
    );
  }
}
