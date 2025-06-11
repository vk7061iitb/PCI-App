import 'package:flutter/material.dart';

import '../../../../../Utils/text_styles.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const aboutPage = '''
      This page displays all recorded data. If any data was not submitted due to a network issue, you can resend it from here. 
      Note: Exported data will be in its raw, unprocessed format as originally recorded.
      ''';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("About Page"),
      titleTextStyle: dialogTitleStyle,
      content: const Text(aboutPage),
      contentTextStyle: dialogContentStyle,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text("Ok", style: dialogButtonStyle),
        )
      ],
    );
  }
}
