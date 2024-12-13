import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Screens/UnsedData/unsend_data.dart';
import 'package:pci_app/src/Presentation/Screens/UserProfile/user_page.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle titleTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.w800,
      fontSize: MediaQuery.textScalerOf(context).scale(32),
    );
    TextStyle actionTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: MediaQuery.textScalerOf(context).scale(16),
    );

    return AppBar(
      title: Text(
        'PCI App',
        style: titleTextStyle,
      ),
      backgroundColor: backgroundColor,
      scrolledUnderElevation: 0,
      elevation: 0,
      forceMaterialTransparency: false,
      actions: [
        PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                onTap: () {
                  Get.to(
                    () => UserPage(),
                    transition: Transition.cupertino,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.person_2_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Profile",
                      style: actionTextStyle,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  Get.to(
                    () => UnsendData(),
                    transition: Transition.cupertino,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.file_copy_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Unsent Files",
                      style: actionTextStyle,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.settings_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Settings",
                      style: actionTextStyle,
                    ),
                  ],
                ),
              ),
            ];
          },
        )
      ],
    );
  }
}

//

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle baseTitleTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );

    TextStyle actionTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: MediaQuery.textScalerOf(context).scale(16),
    );
    double h = MediaQuery.sizeOf(context).height;
    double w = MediaQuery.sizeOf(context).width;
    double totalH = h -
        MediaQuery.of(context).padding.top -
        kToolbarHeight -
        kBottomNavigationBarHeight -
        0.18 * w;
    return SliverAppBar(
      pinned: true,
      floating: true, // Disables floating behavior
      expandedHeight: totalH * 0.15, // Height when fully expanded
      collapsedHeight: 60.0, // App bar height when collapsed
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate font size based on scroll offset
          double maxHeight = totalH * 0.15;
          double minHeight = 60.0; // Collapsed height
          double currentHeight = constraints.maxHeight;
          double shrinkRatio =
              (currentHeight - minHeight) / (maxHeight - minHeight);
          double fontSize = 34 *
              shrinkRatio.clamp(0.8, 1.2); // Font size scales between 20-34
          // Use constraints to adjust behavior during scroll
          double shrinkOffset = constraints.maxHeight - kToolbarHeight;
          double scale = (1 - shrinkOffset / (totalH * 0.2)).clamp(0.7, 1.0);

          return FlexibleSpaceBar(
            titlePadding: EdgeInsetsDirectional.only(
              start: w * 0.05,
              bottom: 16,
            ),
            title: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: Text(
                'PCI App',
                style: baseTitleTextStyle.copyWith(
                  fontSize: fontSize,
                ),
              ),
            ),
            centerTitle: false,
          );
        },
      ),
      actions: [
        PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                onTap: () {
                  Get.to(() => UserPage(), transition: Transition.cupertino);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_2_outlined, color: Colors.black87),
                    SizedBox(width: 8),
                    Text("Profile", style: actionTextStyle),
                  ],
                ),
              ),
              PopupMenuItem(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings_outlined, color: Colors.black87),
                    SizedBox(width: 8),
                    Text("Settings", style: actionTextStyle),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
