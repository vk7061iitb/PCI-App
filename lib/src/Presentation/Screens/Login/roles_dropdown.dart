import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pci_app/Objects/data.dart';

import '../../Controllers/login_controller.dart';

class RolesDropdown extends StatelessWidget {
  const RolesDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.put(LoginController());
    return Container(
      padding: const EdgeInsets.only(
          left: 15.0, right: 15.0, top: 12.0, bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Obx(() {
        return DropdownButton<String>(
          value: loginController.userRole,
          borderRadius: BorderRadius.circular(15),
          isDense: true,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_outlined,
            color: Colors.black,
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          underline: Container(
            height: 0, // Removes default underline
          ),
          items: <String>['Admin', 'Engineer', 'Public']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            loginController.userRole = newValue!;
            logger.i('User Role: ${loginController.userRole}');
          },
        );
      }),
    );
  }
}
