import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pciapp/Objects/data.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appbar;
  final Widget? bottomNavigationBar;
  const BaseScaffold({super.key, required this.body, this.appbar, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle globalOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: backgroundColor,
      systemNavigationBarColor: backgroundColor,
      systemNavigationBarDividerColor: backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
    return AnnotatedRegion(
      value: globalOverlayStyle,
      child: Scaffold(
        appBar: appbar,
        body: body,
        backgroundColor: backgroundColor,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
