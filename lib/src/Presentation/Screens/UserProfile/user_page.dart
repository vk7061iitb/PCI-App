import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
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
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFF3EDF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SvgPicture.asset(
                assetsPath.profile,
                height: 100,
                width: 1,
              ),
              const Gap(10),
              Text(
                'User ${user.userID}',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    buildRow(
                      'Name',
                      "User Name",
                      Icons.person_2_outlined,
                    ),
                    const Gap(10),
                    buildRow(
                      'Phone',
                      user.phoneNumber,
                      Icons.phone_outlined,
                    ),
                    const Gap(10),
                    buildRow(
                      'Email',
                      user.email,
                      Icons.email_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, IconData iconData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          iconData,
          color: Colors.black54,
          size: 24,
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
        ),
      ],
    );
  }
}
