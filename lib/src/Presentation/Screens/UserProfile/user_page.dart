import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/src/Presentation/Controllers/user_data_controller.dart';
import 'package:pciapp/src/Presentation/Screens/Login/login_screen.dart';

import '../../../../Utils/font_size.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller
    UserDataController userDataController = UserDataController();
    userDataController.getUserData();
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'User Profile',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: fs.appBarFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: SvgPicture.asset(
                  assetsPath.profile,
                  height: 60,
                  width: 60,
                ),
              ),
              const Gap(12),
              // User Name
              Text(
                'User ${userDataController.user["ID"]}',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Gap(8),
              Divider(color: Colors.grey[300], thickness: 1),
              const Gap(12),
              // User Information Card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      buildInfoRow(
                        'Role',
                        userDataController.user["role"],
                        Icons.person_outline,
                      ),
                      buildInfoRow(
                        'Phone',
                        userDataController.user["phone"],
                        Icons.phone_outlined,
                      ),
                      buildInfoRow(
                        'Email',
                        userDataController.user["email"],
                        Icons.email_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(10),
              OutlinedButton(
                onPressed: () async {
                  await _showconfirmDialog(context).then((value) async {
                    if (value == true) {
                      // logout the user
                      await userDataController.deleteUser();
                      Get.offAll(
                        () => LoginScreen(),
                        transition: Transition.cupertino,
                      );
                    }
                  });
                },
                child: Text(
                  "Log Out",
                  style: GoogleFonts.inter(
                    fontSize: fs.bodyTextFontSize,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Build information rows with icons
  Widget buildInfoRow(String title, String value, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(iconData, color: Colors.blueGrey, size: 24),
          const Gap(12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Get alert dialog for the user to confirm the deletion of the data
Future<bool?> _showconfirmDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content: const Text('Are you sure you want to logout?'),
        contentTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    },
  );
}
