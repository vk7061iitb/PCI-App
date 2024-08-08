import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Models/stats_data.dart';

class RoadStats extends StatelessWidget {
  const RoadStats({required this.outputStats, super.key});
  final List<OutputStats> outputStats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          const Gap(10),
          Text(
            'Road Statistics',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const Gap(5),
          Text(
            'Detailed breakdown of the road conditions by pavement value',
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const Gap(10),
          Expanded(
            child: ListView.builder(
                itemCount: outputStats.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black26,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(10),
                        Row(
                          children: [
                            const Gap(10),
                            Text(
                              "PCI :",
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              outputStats[index].pci.toString(),
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        distanceRow("Distance Travelled",
                            outputStats[index].distanceTravelled.toString()),
                        const Gap(10),
                        speedRow("Average Speed",
                            outputStats[index].avgVelocity.toString()),
                        const Gap(10),
                        segmentRow("Number of Segments",
                            outputStats[index].numberOfSegments.toString()),
                        const Gap(10),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

Widget speedRow(String label, String value) {
  return Row(
    children: [
      const Gap(20),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      const Spacer(),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          "${(double.parse(value) * 3.6).toStringAsFixed(2)} km/hr",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      const Gap(20),
    ],
  );
}

Widget distanceRow(String label, String value) {
  return Row(
    children: [
      const Gap(20),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      const Spacer(),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          "${(double.parse(value) / 1000).toStringAsFixed(3)} km",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      const Gap(20),
    ],
  );
}

Widget segmentRow(String label, String value) {
  return Row(
    children: [
      const Gap(20),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      const Spacer(),
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          double.parse(value).toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      const Gap(20),
    ],
  );
}
