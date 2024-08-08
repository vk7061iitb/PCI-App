import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

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
      scrolledUnderElevation: 0,
      elevation: 0,
      forceMaterialTransparency: true,
      title: Text(
        'PCI App',
        style: titleTextStyle,
      ),
      backgroundColor: const Color(0xFFF3EDF5),
      actions: [
        PopupMenuButton(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.4,
            ),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    Get.toNamed(myRoutes.userProfileRoute);
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
                    Get.toNamed(myRoutes.unsentDataRoute);
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
            })
      ],
    );
  }
}
