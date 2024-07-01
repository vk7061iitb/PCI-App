import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Models/user_data.dart';

class UserPage extends StatefulWidget {
  final UserData user;

  const UserPage({
    super.key,
    required this.user,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildRow(
              'User ID',
              widget.user.userID!,
              const Icon(
                Icons.person,
                color: Colors.black87,
              ),
            ),
            const Gap(10),
            buildRow(
              'Phone',
              widget.user.phoneNumber,
              const Icon(
                Icons.phone,
                color: Colors.black87,
              ),
            ),
            const Gap(10),
            buildRow(
              'Email',
              widget.user.email,
              const Icon(
                Icons.email,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildRow(String title, String value, Icon icon) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const Gap(10),
      Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
      const Gap(10),
      Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    ],
  );
}
