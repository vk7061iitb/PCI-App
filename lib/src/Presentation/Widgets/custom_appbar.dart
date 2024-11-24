import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF3EDF5),
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

    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFFF3EDF5),
      title: Text(
        'PCI App',
        style: titleTextStyle,
      ),
      scrolledUnderElevation: 0,
      elevation: 0,
      forceMaterialTransparency: false,
      onStretchTrigger: () {
        return Future<void>.value();
      },
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
        ),
      ],
    );
  }
}
