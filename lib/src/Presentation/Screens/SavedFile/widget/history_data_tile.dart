import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/saved_file_controller.dart';
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
              onTap: shareFile,
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
            if ((file['status'] != 1))
              PopupMenuItem(
                onTap: () async {
                  await savedFileController.searchUnsentData(file);
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.replay_outlined,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Re-Submit",
                      style: pupUpMenuTextStyle,
                    ),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: deleteFile,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Align all children to center
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.15,
                    height: MediaQuery.sizeOf(context).width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(
                        getIcon(file['vehicleType']),
                        size: MediaQuery.sizeOf(context).width * 0.1,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Gap(MediaQuery.sizeOf(context).width * 0.05),
                  Expanded(
                    // Ensures the second column takes available space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align children to the left
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Space between file name and status
                          children: [
                            FittedBox(
                              child: Text(
                                file['filename'],
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            FittedBox(
                              child: Container(
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
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              file['time'],
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
                  ),
                ],
              ),
              Divider(
                color: Colors.black12,
                thickness: 0.5,
                indent: MediaQuery.sizeOf(context).width * 0.2,
              ),
            ],
          )),
    );
  }
}
