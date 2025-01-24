import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Utils/font_size.dart';
import 'package:pciapp/src/Presentation/Controllers/saved_file_controller.dart';
import '../../../../../Utils/get_icon.dart';

class HistoryDataItem extends StatelessWidget {
  const HistoryDataItem({
    super.key,
    required this.file,
    required this.shareFile,
    required this.deleteFile,
    required this.unsentData,
  });
  final Map<String, dynamic> file;
  final List<Map<String, dynamic>> unsentData;
  final VoidCallback shareFile;
  final VoidCallback deleteFile;
  @override
  Widget build(BuildContext context) {
    double left = 0, right = 0, top = 0, bottom = 0;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    TextStyle pupUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );
    SavedFileController savedFileController = Get.find<SavedFileController>();
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          items: [
            PopupMenuItem(
              onTap: shareFile,
              child: Text(
                "Share",
                style: pupUpMenuTextStyle,
              ),
            ),
            if ((file['status'] != 1))
              PopupMenuItem(
                onTap: () async {
                  await savedFileController.searchUnsentData(file);
                },
                child: Text(
                  "Re-Submit",
                  style: pupUpMenuTextStyle,
                ),
              ),
            PopupMenuItem(
              onTap: deleteFile,
              child: Text(
                "Delete",
                style: pupUpMenuTextStyle,
              ),
            ),
          ],
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: (MediaQuery.sizeOf(context).width * 0.15 < 80)
                      ? MediaQuery.sizeOf(context).width * 0.15
                      : 80,
                  height: (MediaQuery.sizeOf(context).width * 0.15 < 80)
                      ? MediaQuery.sizeOf(context).width * 0.15
                      : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Icon(
                        getIcon(file['vehicleType']),
                        size: (MediaQuery.sizeOf(context).width * 0.1 < 50)
                            ? MediaQuery.sizeOf(context).width * 0.1
                            : 50,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Gap(MediaQuery.sizeOf(context).width * 0.05),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              file['filename'],
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: fs.bodyTextFontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (file['status'] != 1)
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              (file['status'] != 1)
                                  ? "Not Submitted"
                                  : "Submitted",
                              style: GoogleFonts.inter(
                                color: (file['status'] != 1)
                                    ? Colors.red.shade900
                                    : Colors.green.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        file['time'],
                        style: GoogleFonts.inter(
                          color: Colors.teal,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
