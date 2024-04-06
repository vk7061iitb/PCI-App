import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Objects/data.dart';

class VehicleTypeDropdown extends StatefulWidget {
  const VehicleTypeDropdown({super.key});

  @override
  State<VehicleTypeDropdown> createState() => _VehicleTypeDropdownState();
}

class _VehicleTypeDropdownState extends State<VehicleTypeDropdown> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
            if (kDebugMode) {
              print('Vehicle Type: $dropdownValue');
            }
          });
        },
        elevation: 1,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(20),
        items: vehicleType.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
