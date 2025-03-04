import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';
import 'package:pciapp/src/Presentation/About/about_app.dart';
import 'package:pciapp/src/Presentation/Screens/UnsedData/unsend_data.dart';
import 'package:pciapp/src/Presentation/Screens/UserProfile/user_page.dart';

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
      fontWeight: FontWeight.w600,
    );

    TextStyle actionTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: MediaQuery.textScalerOf(context).scale(16),
    );
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(
          start: w * 0.05,
          bottom: 16,
        ),
        title: Text(
          'PCI App',
          style: baseTitleTextStyle.copyWith(
            fontSize: fs.heading1FontSize,
          ),
        ),
        centerTitle: false,
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
                onTap: () {
                  Get.to(() => AboutApp(), transition: Transition.cupertino);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.black87),
                    SizedBox(width: 8),
                    Text("About app", style: actionTextStyle),
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
