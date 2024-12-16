FontSize getFontSize(double screenWidth) {
  double appBarFontSize;
  double heading1FontSize;
  double heading2FontSize;
  double bodyTextFontSize;

  // Define font sizes based on screen width
  if (screenWidth <= 320) {
    // Small screen (e.g., small phones)
    appBarFontSize = 18.0;
    heading1FontSize = 22.0;
    heading2FontSize = 20.0;
    bodyTextFontSize = 14.0;
  } else if (screenWidth <= 480) {
    // Medium screen (e.g., large phones)
    appBarFontSize = 20.0;
    heading1FontSize = 26.0;
    heading2FontSize = 24.0;
    bodyTextFontSize = 16.0;
  } else if (screenWidth <= 720) {
    // Tablets or larger screens
    appBarFontSize = 22.0;
    heading1FontSize = 30.0;
    heading2FontSize = 28.0;
    bodyTextFontSize = 18.0;
  } else {
    // Very large screens (e.g., large tablets, laptops)
    appBarFontSize = 24.0;
    heading1FontSize = 36.0;
    heading2FontSize = 32.0;
    bodyTextFontSize = 20.0;
  }
  FontSize f = FontSize(
      appBarFontSize: appBarFontSize,
      heading1FontSize: heading1FontSize,
      heading2FontSize: heading2FontSize,
      bodyTextFontSize: bodyTextFontSize);
  return f;
}

IconsSize getIconSize(double screenWidth) {
  double appBarIconSize;
  double buttonIconSize;
  double generalIconSize;

  // Define icon sizes based on screen width
  if (screenWidth <= 320) {
    // Small screen (e.g., small phones)
    appBarIconSize = 20.0;
    buttonIconSize = 24.0;
    generalIconSize = 18.0;
  } else if (screenWidth <= 480) {
    // Medium screen (e.g., large phones)
    appBarIconSize = 24.0;
    buttonIconSize = 28.0;
    generalIconSize = 22.0;
  } else if (screenWidth <= 720) {
    // Tablets or larger screens
    appBarIconSize = 28.0;
    buttonIconSize = 32.0;
    generalIconSize = 26.0;
  } else {
    // Very large screens (e.g., large tablets, laptops)
    appBarIconSize = 32.0;
    buttonIconSize = 36.0;
    generalIconSize = 30.0;
  }
  IconsSize iS = IconsSize(
      appBarIconSize: appBarIconSize,
      buttonIconSize: buttonIconSize,
      generalIconSize: generalIconSize);
  return iS;
}

class FontSize {
  final double appBarFontSize;
  final double heading1FontSize;
  final double heading2FontSize;
  final double bodyTextFontSize;

  FontSize({
    required this.appBarFontSize,
    required this.heading1FontSize,
    required this.heading2FontSize,
    required this.bodyTextFontSize,
  });
}

class IconsSize {
  final double appBarIconSize;
  final double buttonIconSize;
  final double generalIconSize;
  IconsSize({
    required this.appBarIconSize,
    required this.buttonIconSize,
    required this.generalIconSize,
  });
}
