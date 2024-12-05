import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Functions/get_road_color.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';

class PolylineBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  const PolylineBottomSheet({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();
    return Container(
      padding: const EdgeInsets.all(10),
      width: Get.width,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Features",
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                data['roadName'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  logger.i(
                      "Zooming to the location ${data['latlngs'][0]}, ${data['latlngs'][1]}");
                  mapPageController.animateToLocation(
                      data['latlngs'][0], data['latlngs'][1]);
                  Get.back();
                },
                icon: Icon(
                  Icons.zoom_in_outlined,
                  color: Colors.blue,
                  size: MediaQuery.sizeOf(context).width * 0.08,
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${data['filename']}',
                style: GoogleFonts.inter(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.black54,
                  ),
                  const Gap(5),
                  Text(
                    '${data['time']}',
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
          const Divider(),
          Row(
            children: [
              Text(
                "PCI",
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                data['pci'].toString(),
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(5),
              Expanded(
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: data['pci'] / 5,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    getRoadColor(data['pci']),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                "Avg Speed",
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "${data['avg_vel'].toStringAsFixed(2)} kmph",
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                "Length",
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "${data['distance'].toStringAsFixed(4)} km",
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
