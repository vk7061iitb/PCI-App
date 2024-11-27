import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../Utils/get_icon.dart';

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
    double left = 0, right = 0, top = 0, bottom = 0;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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

    return InkWell(
      onTapDown: (TapDownDetails details) {
        left = details.globalPosition.dx;
        top = details.globalPosition.dy;
        overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        right = overlay.size.width - details.globalPosition.dx;
        bottom = overlay.size.height - details.globalPosition.dy;
      },
      onTap: () {
        // do something
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            left,
            top,
            right,
            bottom,
          ),
          items: [
            PopupMenuItem(
              onTap: widget.shareFile,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.share,
                      color: Colors.black87,
                    ),
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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Delete",
                    style: pupUpMenuTextStyle,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          right: 10,
          left: 10,
          top: 2,
          bottom: 2,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.15,
                  height: MediaQuery.sizeOf(context).width * 0.15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                        getIcon(fileInfo.vehicleType),
                        size: MediaQuery.sizeOf(context).width * 0.1,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Gap(MediaQuery.sizeOf(context).width * 0.05),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
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
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
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
              ],
            ),
            Divider(
              color: Colors.black12,
              thickness: 0.5,
              indent: MediaQuery.sizeOf(context).width * 0.2,
            ),
          ],
        ),
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
