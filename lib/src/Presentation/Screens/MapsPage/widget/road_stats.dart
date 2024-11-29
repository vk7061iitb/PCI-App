import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import '../../../../../Objects/data.dart';
import '../../../../Models/stats_data.dart';

class MapPageRoadStatistics extends StatelessWidget {
  const MapPageRoadStatistics(
      {required this.roadStats, required this.roadOutputData, super.key});
  final List<RoadStats> roadStats;
  final List<Map<String, dynamic>> roadOutputData;

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
                itemCount: roadStats.length,
                itemBuilder: (context, roadIndex) {
                  final outputStats = roadStats[roadIndex].roadStatsData;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: ExpansionTile(
                        title: Text(
                          roadStats[roadIndex].roadName,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          roadOutputData[roadIndex]['filename'],
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          SingleChildScrollView(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: DataTable(
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      'PCI',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Distance(km)',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Velocity(km/hr)',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: [
                                  for (var stats in outputStats)
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text(
                                            stats.pci.toString(),
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text((double.parse(
                                                      stats.distanceTravelled) /
                                                  1000)
                                              .toStringAsFixed(3)),
                                        ),
                                        DataCell(
                                          Text(
                                              (double.parse(stats.avgVelocity) *
                                                      3.6)
                                                  .toStringAsFixed(3)),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class RoadStatistics extends StatefulWidget {
  const RoadStatistics({required this.id, super.key});
  final int id;

  @override
  State<RoadStatistics> createState() => _RoadStatisticsState();
}

class _RoadStatisticsState extends State<RoadStatistics> {
  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();
    Future<List<Map<String, dynamic>>> getRoadStats(int id) async {
      mapPageController.roadOutputData = [];
      List<Map<String, dynamic>> res =
          await localDatabase.queryRoadOutputData(id);
      mapPageController.roadOutputData.add(res);
      mapPageController.setRoadStatistics(res);
      return res;
    }

    return FutureBuilder(
        future: getRoadStats(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading files: ${snapshot.error}'),
            );
          } else {
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
                  const Gap(5),
                  Expanded(
                    child: ListView.builder(
                        itemCount: mapPageController.roadStats.length,
                        itemBuilder: (context, roadIndex) {
                          final outputStats = mapPageController
                              .roadStats[roadIndex].roadStatsData;
                          return ExpansionTile(
                              title: Text(
                                mapPageController.roadStats[roadIndex].roadName,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              children: [
                                SingleChildScrollView(
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: DataTable(
                                      columns: <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            'PCI',
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Distance(km)',
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Velocity(km/hr)',
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: [
                                        for (var stats in outputStats)
                                          DataRow(
                                            cells: <DataCell>[
                                              DataCell(
                                                Text(
                                                  stats.pci.toString(),
                                                  style: GoogleFonts.inter(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text((double.parse(stats
                                                            .distanceTravelled) /
                                                        1000)
                                                    .toStringAsFixed(3)),
                                              ),
                                              DataCell(
                                                Text((double.parse(
                                                            stats.avgVelocity) *
                                                        3.6)
                                                    .toStringAsFixed(3)),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]);
                        }),
                  ),
                ],
              ),
            );
          }
        });
  }
}
