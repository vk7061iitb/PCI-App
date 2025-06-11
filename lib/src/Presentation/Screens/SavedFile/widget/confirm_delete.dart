import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pciapp/Utils/text_styles.dart';

class ConfirmDelete extends StatelessWidget {
  const ConfirmDelete({super.key});
  static const title = "Delete File?";
  static const content = "Are you sure you want to delete this file?";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(title),
      titleTextStyle: dialogTitleStyle,
      content: const Text(content),
      contentTextStyle: dialogContentStyle,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text('No', style: dialogButtonStyle),
        ),
        TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text('Yes',
                style: dialogButtonStyle.copyWith(color: Colors.red))),
      ],
    );
  }
}