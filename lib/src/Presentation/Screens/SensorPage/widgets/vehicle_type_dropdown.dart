import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pci_app/Utils/get_icon.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';

class VehicleType extends StatelessWidget {
  const VehicleType({required this.width, super.key});
  final double width;

  @override
  Widget build(BuildContext context) {
    ResponseController responseController = Get.find();
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
      child: Obx(
        () {
          return DropdownButton<String>(
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
            value: responseController.dropdownValue,
            items: ["Car", "Bike", "Auto", "Bus", "Walk"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(getIcon(value)),
                    const Gap(10),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              responseController.dropdownValue = newValue!;
            },
          );
        },
      ),
    );
  }
}
