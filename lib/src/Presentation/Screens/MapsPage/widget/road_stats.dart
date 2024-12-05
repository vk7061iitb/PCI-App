import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/road_stats_controller.dart';
import '../../../../../Functions/set_road_stats.dart';
import '../../../../../Objects/data.dart';
import '../../../../Models/stats_data.dart';

class MapPageRoadStatistics extends StatelessWidget {
  const MapPageRoadStatistics(
      {required this.roadStats, required this.roadOutputData, super.key});

  final List<Map<String, dynamic>> roadOutputData;
  final List<RoadStats> roadStats;

  @override
  Widget build(BuildContext context) {
    RoadStatsController roadStatsController = Get.find<RoadStatsController>();
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
                  final outputStats = roadStats[roadIndex].predStats;
                  final velBasedStats = roadStats[roadIndex].velStats;
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
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Obx(
                                () => Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        roadStatsController.showPredPCI = true;
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                          roadStatsController.showPredPCI
                                              ? Colors.deepPurple
                                                  .withOpacity(0.1)
                                              : Colors.black.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Text(
                                        "PCI-Prediction Based",
                                        style: GoogleFonts.inter(
                                          color: roadStatsController.showPredPCI
                                              ? Colors.blue
                                              : Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    TextButton(
                                      onPressed: () {
                                        roadStatsController.showPredPCI = false;
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                          roadStatsController.showPredPCI
                                              ? Colors.black.withOpacity(0.1)
                                              : Colors.blue.withOpacity(0.1),
                                        ),
                                      ),
                                      child: Text(
                                        "PCI-Velocity Based",
                                        style: GoogleFonts.inter(
                                          color: roadStatsController.showPredPCI
                                              ? Colors.black
                                              : Colors.blue,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => FittedBox(
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
                                      'Velocity(kmph)',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: (roadStatsController.showPredPCI)
                                    ? <DataRow>[
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
                                      ]
                                    : <DataRow>[
                                        for (var stats in velBasedStats)
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
    RoadStatsController roadStatsController = Get.find<RoadStatsController>();
    Future<List<Map<String, dynamic>>> getRoadStats(int id) async {
      mapPageController.roadOutputData = [];
      List<Map<String, dynamic>> res =
          await localDatabase.queryRoadOutputData(jouneyID: id);
      mapPageController.roadOutputData.add(res);
      if (mapPageController.roadStats.isNotEmpty) {
        mapPageController.roadStats.clear();
      }
      mapPageController.roadStats.add(setRoadStatistics(journeyData: res));
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
                    "Detailed breakdown of the road conditions by PCI value",
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: mapPageController.roadStats.length,
                        itemBuilder: (context, roadIndex) {
                          final outputStats =
                              mapPageController.roadStats[roadIndex].predStats;
                          final velStats =
                              mapPageController.roadStats[roadIndex].velStats;
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
                                Obx(
                                  () => SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              roadStatsController.showPredPCI =
                                                  true;
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                roadStatsController.showPredPCI
                                                    ? Colors.deepPurple
                                                        .withOpacity(0.1)
                                                    : Colors.black
                                                        .withOpacity(0.1),
                                              ),
                                            ),
                                            child: Text(
                                              "PCI-Prediction Based",
                                              style: GoogleFonts.inter(
                                                color: roadStatsController
                                                        .showPredPCI
                                                    ? Colors.blue
                                                    : Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const Gap(10),
                                          TextButton(
                                            onPressed: () {
                                              roadStatsController.showPredPCI =
                                                  false;
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                roadStatsController.showPredPCI
                                                    ? Colors.black
                                                        .withOpacity(0.1)
                                                    : Colors.blue
                                                        .withOpacity(0.1),
                                              ),
                                            ),
                                            child: Text(
                                              "PCI-Velocity Based",
                                              style: GoogleFonts.inter(
                                                color: roadStatsController
                                                        .showPredPCI
                                                    ? Colors.black
                                                    : Colors.blue,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => FittedBox(
                                    fit: BoxFit.fill,
                                    child: DataTable(
                                      clipBehavior: Clip.antiAlias,
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
                                            'Velocity(kmph)',
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: (roadStatsController.showPredPCI)
                                          ? <DataRow>[
                                              for (var stats in outputStats)
                                                DataRow(
                                                  cells: <DataCell>[
                                                    DataCell(
                                                      Text(
                                                        stats.pci.toString(),
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                      Text((double.parse(stats
                                                                  .avgVelocity) *
                                                              3.6)
                                                          .toStringAsFixed(3)),
                                                    ),
                                                  ],
                                                ),
                                            ]
                                          : <DataRow>[
                                              for (var stats in velStats)
                                                DataRow(
                                                  cells: <DataCell>[
                                                    DataCell(
                                                      Text(
                                                        stats.pci.toString(),
                                                        style:
                                                            GoogleFonts.inter(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                      Text((double.parse(stats
                                                                  .avgVelocity) *
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
