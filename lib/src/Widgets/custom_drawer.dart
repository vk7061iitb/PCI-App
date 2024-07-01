import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Screens/Settings/settings.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle drawerTitleStyle = GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: Colors.black,
    );
    TextStyle drawerSubtitleStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.blueGrey,
    );
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Text(
              'PCI App',
              style: drawerTitleStyle,
            ),
          ),
          ListTile(
            title: Text(
              'Home',
              style: drawerSubtitleStyle,
            ),
            onTap: () {
              // Navigate to Home
            },
          ),
          ListTile(
            title: Text('Settings', style: drawerSubtitleStyle),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
