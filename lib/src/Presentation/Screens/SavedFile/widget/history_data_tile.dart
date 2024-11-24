import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryDataItem extends StatefulWidget {
  const HistoryDataItem({
    super.key,
    required this.file,
    required this.shareFile,
    required this.deleteFile,
  });
  final File file;
  final VoidCallback shareFile;
  final VoidCallback deleteFile;

  @override
  State<HistoryDataItem> createState() => _HistoryDataItemState();
}

class _HistoryDataItemState extends State<HistoryDataItem> {
  @override
  Widget build(BuildContext context) {
    FileInfo getFileInfo(String input) {
      String fileName = input.split('#')[0];
      String dataType = 'AccData';
      String timeString = input.split('#')[2];
      String vehicleType = input.split('#').last.split('.csv').first;

      return FileInfo(
        fileName: fileName,
        dataType: dataType,
        time: timeString,
        vehicleType: vehicleType,
      );
    }

    TextStyle pupUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    FileInfo fileInfo = getFileInfo(widget.file.path.split('/').last);
// Function to get the icon for the vehicle type
    Icon getIcon(String vehicleType) {
      if (vehicleType == 'Car') {
        return const Icon(
          Icons.directions_car_filled_outlined,
          size: 40,
          color: Colors.black87,
        );
      } else if (vehicleType == 'Bike') {
        return const Icon(
          Icons.motorcycle_outlined,
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
          Icons.directions_bus_outlined,
          size: 40,
          color: Colors.black87,
        );
      } else {
        return const Icon(
          Icons.directions_run_outlined,
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
                child: getIcon(fileInfo.vehicleType),
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
                  fileInfo.fileName,
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
                    fileInfo.time,
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
                  onTap: widget.shareFile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.black87,
                      ),
                      Text(
                        "Share",
                        style: pupUpMenuTextStyle,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: widget.deleteFile,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.black87,
                      ),
                      Text(
                        "Delete",
                        style: pupUpMenuTextStyle,
                      ),
                    ],
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

class FileInfo {
  final String fileName;
  String dataType;
  final String time;
  final String vehicleType;

  FileInfo({
    required this.fileName,
    required this.dataType,
    required this.time,
    required this.vehicleType,
  });
}
