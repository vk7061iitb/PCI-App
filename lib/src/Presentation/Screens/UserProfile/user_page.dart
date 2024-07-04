import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Models/user_data.dart';

class UserPage extends StatelessWidget {
  final UserData user;

  const UserPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Info',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildRow(
                  'User ID',
                  user.userID!,
                  Icons.person,
                ),
                const Divider(),
                buildRow(
                  'Phone',
                  user.phoneNumber,
                  Icons.phone,
                ),
                const Divider(),
                buildRow(
                  'Email',
                  user.email,
                  Icons.email,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, IconData iconData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, color: Colors.black54),
        const Gap(10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const Gap(5),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
