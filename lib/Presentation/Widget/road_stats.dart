import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Objects/stats_object.dart';

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
            'Road Stats',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const Gap(10),
          Expanded(
            child: ListView.builder(
                itemCount: outputStats.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                        ),
                        child: Row(
                          children: [
                            const Gap(10),
                            Text(
                              "PCI",
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
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(10),
                      buildInfoRow("Average velocity",
                          outputStats[index].avgVelocity.toString()),
                      const Divider(
                        color: Colors.black38,
                        thickness: 1,
                      ),
                      buildInfoRow("Distance travelled",
                          outputStats[index].distanceTravelled.toString()),
                      const Divider(
                        color: Colors.black38,
                        thickness: 1,
                      ),
                      buildInfoRow("Number of segments",
                          outputStats[index].numberOfSegments.toString()),
                      const Gap(10),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}

Widget buildInfoRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const Gap(10),
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
      const Gap(20),
      Text(
        double.parse(value).toStringAsFixed(2),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    ],
  );
}
