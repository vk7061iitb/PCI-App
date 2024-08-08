import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Utils/get_icon.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';

class VehicleType extends StatelessWidget {
  const VehicleType({required this.width, super.key});
  final double width;

  @override
  Widget build(BuildContext context) {
    ResponseController responseController = Get.find();
    return Center(
      child: DropdownMenu<String>(
        width: width,
        leadingIcon: Obx(() {
          return Icon(
            getIcon(responseController.dropdownValue),
            color: Colors.black,
          );
        }),
        initialSelection: vehicleType.first,
        onSelected: (String? value) {
          responseController.dropdownValue = value!;
        },
        dropdownMenuEntries:
            vehicleType.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
        textStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: 18,
        ),
        menuHeight: 200,
        menuStyle: MenuStyle(
          elevation: const WidgetStatePropertyAll(1),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          constraints: BoxConstraints(
            maxHeight: 50,
            minWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          labelStyle: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            gapPadding: 1,
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
