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
      elevation: 0,
      title: Text(
        'PCI App',
        style: titleTextStyle,
      ),
      backgroundColor: const Color(0xFFF3EDF5),
      actions: [
        PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    Get.toNamed(myRoutes.userProfileRoute);
                  },
                  child: Text(
                    "Profile",
                    style: actionTextStyle,
                  ),
                ),
                PopupMenuItem(
                  child: Text(
                    "Settings",
                    style: actionTextStyle,
                  ),
                ),
              ];
            })
      ],
    );
  }
}
