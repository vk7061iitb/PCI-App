import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';

import '../../../../Utils/get_icon.dart';

class UnsentFileTile extends StatelessWidget {
  const UnsentFileTile({
    super.key,
    required this.filename,
    required this.vehicleType,
    required this.time,
    required this.id,
    required this.onDeleteTap,
  });
  final String filename;
  final String time;
  final String vehicleType;
  final int id;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    ResponseController responseController = Get.find();
    OutputDataController outputDataController =
        Get.find<OutputDataController>();
    double left = 0, right = 0, top = 0, bottom = 0;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    TextStyle pupUpMenuTextStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 16,
    );

    return InkWell(
      onTapDown: (TapDownDetails details) {
        // do something
        left = details.globalPosition.dx;
        top = details.globalPosition.dy;
        overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        right = overlay.size.width - left;
        bottom = overlay.size.height - top;
      },
      onTap: () {
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
              onTap: () async {
                // Send the data to the server
                List<Map<String, dynamic>> data =
                    await localDatabase.queryUnsentData(id);
                DateTime unsentTime =
                    dateTimeParser.parseDateTime(time, 'dd-MMM-yyyy HH:mm')!;
                int res = await responseController.reSendData(
                    data, filename, unsentTime);
                if (res == 200) {
                  Get.showSnackbar(
                    customGetSnackBar(
                      "Submission Successful",
                      "Data sent successfully",
                      Icons.check_circle_outline,
                    ),
                  );
                  await localDatabase.deleteUnsentData(id);
                  await localDatabase.deleteUnsentDataInfo(id);
                  onDeleteTap();
                  outputDataController.fetchData();
                  return;
                }
                Get.showSnackbar(
                  customGetSnackBar(
                    "Submission Failed",
                    "Failed to send data",
                    Icons.error_outline,
                  ),
                );
              },
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.send_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Submit",
                    style: pupUpMenuTextStyle,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDeleteTap,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
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
                        getIcon(vehicleType),
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
                      child: Text(
                        filename,
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
                          time,
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
