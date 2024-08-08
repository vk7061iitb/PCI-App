import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class UnsentFileTile extends StatefulWidget {
  const UnsentFileTile({
    super.key,
    required this.filename,
    required this.vehicleType,
    required this.time,
    required this.id,
  });
  final String filename;
  final String time;
  final String vehicleType;
  final int id;

  @override
  State<UnsentFileTile> createState() => _UnsentFileTileState();
}

class _UnsentFileTileState extends State<UnsentFileTile> {
  @override
  Widget build(BuildContext context) {
    TextStyle pupUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    Icon getIcon(String vehicleType) {
      if (vehicleType == 'Car') {
        return const Icon(
          Icons.directions_car,
          size: 40,
          color: Colors.black87,
        );
      } else if (vehicleType == 'Bike') {
        return const Icon(
          Icons.motorcycle,
          size: 40,
          color: Colors.black87,
        );
      } else if (vehicleType == 'Auto') {
        return const Icon(
          Icons.electric_rickshaw_outlined,
          size: 40,
          color: Colors.black87,
        );
      } else if (vehicleType == 'Bus') {
        return const Icon(
          Icons.directions_bus,
          size: 40,
          color: Colors.black87,
        );
      } else {
        return const Icon(
          Icons.directions_walk,
          size: 40,
          color: Colors.black87,
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: getIcon(widget.vehicleType),
              ),
            ),
          ),
          const Gap(5),
          Container(
            height: 50,
            width: 1,
            color: Colors.black26,
          ),
          const Gap(10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Text(
                  widget.filename,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.time,
                    style: GoogleFonts.inter(
                      color: Colors.teal,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    // Submit the data to the server
                  },
                  child: Text(
                    "Submit",
                    style: pupUpMenuTextStyle,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
