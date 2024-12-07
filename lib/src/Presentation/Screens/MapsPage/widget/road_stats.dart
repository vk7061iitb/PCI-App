import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import '../../../../../Utils/set_road_stats.dart';
import '../../../../../Objects/data.dart';
import '../../../../Models/stats_data.dart';

class MapPageRoadStatistics extends StatefulWidget {
  const MapPageRoadStatistics(
      {required this.roadStats, required this.roadOutputData, super.key});

  final List<Map<String, dynamic>> roadOutputData;
  final List<RoadStats> roadStats;

  @override
  State<MapPageRoadStatistics> createState() => _MapPageRoadStatisticsState();
}

class _MapPageRoadStatisticsState extends State<MapPageRoadStatistics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: context.height * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          const Gap(12),
          Text(
            'Road Statistics',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 26,
            ),
          ),
          const Gap(8),
          Text(
            "Overview of road conditions based on PCI and velocity data",
            style: GoogleFonts.inter(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const Gap(10),
          Expanded(
            child: ListView.builder(
                itemCount: widget.roadStats.length,
                itemBuilder: (context, roadIndex) {
                  final outputStats = widget.roadStats[roadIndex].predStats;
                  final velBasedStats = widget.roadStats[roadIndex].velStats;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: ExpansionTile(
                        collapsedBackgroundColor:
                            Colors.black.withOpacity(0.05),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text(
                          widget.roadStats[roadIndex].roadName,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          widget.roadOutputData[roadIndex]['filename'],
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        children: [
                          // TabBar to switch between Prediction-Based and Velocity-Based stats
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Prediction Based'),
                              Tab(text: 'Velocity Based'),
                            ],
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.black,
                            indicatorColor: Colors.blue,
                            indicatorWeight: 3.0,
                            labelStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            unselectedLabelStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),

                          // Content for the selected tab
                          SizedBox(
                            height: context.height * 0.4,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Prediction-Based stats
                                _buildDataTable(outputStats),

                                // Velocity-Based stats
                                _buildDataTable(velBasedStats),
                              ],
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

class _RoadStatisticsState extends State<RoadStatistics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Road Statistics',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 26,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    "Overview of road conditions based on PCI and velocity data",
                    style: GoogleFonts.inter(
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(20),

                  // TabBar to switch between Prediction-Based and Velocity-Based stats
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Prediction Based'),
                      Tab(text: 'Velocity Based'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 3.0,
                    labelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),

                  // Content for the selected tab
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Prediction-Based stats
                        _buildDataTable(
                            mapPageController.roadStats[0].predStats),

                        // Velocity-Based stats
                        _buildDataTable(
                            mapPageController.roadStats[0].velStats),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

Widget _buildDataTable(List<dynamic> statsList) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      clipBehavior: Clip.antiAlias,
      columns: <DataColumn>[
        DataColumn(
          label: Text(
            'PCI',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Distance(km)',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Velocity(kmph)',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
      rows: <DataRow>[
        for (var stats in statsList)
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text(
                  stats.pci.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              DataCell(
                Text(
                  (double.parse(stats.distanceTravelled) / 1000)
                      .toStringAsFixed(3),
                ),
              ),
              DataCell(
                Text(
                  (double.parse(stats.avgVelocity) * 3.6).toStringAsFixed(3),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}
