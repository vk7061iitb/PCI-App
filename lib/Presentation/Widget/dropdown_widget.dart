import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Objects/data.dart';

class VehicleTypeDropdown extends StatefulWidget {
  final ValueChanged<String> onPressed;
  final String dropdownValue;
  const VehicleTypeDropdown(
      {required this.onPressed, required this.dropdownValue, super.key});

  @override
  State<VehicleTypeDropdown> createState() => _VehicleTypeDropdownState();
}

class _VehicleTypeDropdownState extends State<VehicleTypeDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      value: widget.dropdownValue,
      alignment: Alignment.center,
      onChanged: (String? newValue) {
        widget.onPressed(newValue!);
      },
      elevation: 1,
      underline: Container(
        height: 0,
      ),
      borderRadius: BorderRadius.circular(15),
      items: vehicleType.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          alignment: AlignmentDirectional.centerStart,
          value: value,
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        );
      }).toList(),
    );
  }
}
