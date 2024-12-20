import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/map_page_controller.dart';
import '../../../../../Utils/set_road_stats.dart';
import '../../../../../Objects/data.dart';
import '../../../../Models/stats_data.dart';
import '../../OutputData/pdf_preview.dart';

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
            'Overall Statistics',
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
  const RoadStatistics({
    required this.id,
    required this.filename,
    required this.planned,
    required this.vehicleType,
    super.key,
  });

  final int id;
  final String filename;
  final String planned;
  final String vehicleType;

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

    Future<List<Map<String, dynamic>>> getRoadStats(
        int id, String filename) async {
      mapPageController.roadOutputData = [];
      List<Map<String, dynamic>> res =
          await localDatabase.queryRoadOutputData(jouneyID: id);
      mapPageController.roadOutputData.add(res);
      if (mapPageController.roadStats.isNotEmpty) {
        mapPageController.roadStats.clear();
        mapPageController.segStats.clear();
      }
      final completeStats =
          setRoadStatistics(journeyData: res, filename: filename);
      mapPageController.roadStats = completeStats[0] as List<RoadStats>;
      mapPageController.segStats = completeStats[1] as List<SegStats>;
      return res;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Road Statistics',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 26,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Get.to(
            () => RoadStatisticsPdfPage(
              id: widget.id,
              filename: widget.filename,
              planned : widget.planned,
              vehicleType : widget.vehicleType
            ),
            transition: Transition.cupertino,
          );
        },
        child: Icon(Icons.download),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: getRoadStats(widget.id, widget.filename),
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
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(10),
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
                            itemCount: mapPageController.roadStats.length,
                            itemBuilder: (context, roadIndex) {
                              final outputStats = mapPageController
                                  .roadStats[roadIndex].predStats;
                              final velBasedStats = mapPageController
                                  .roadStats[roadIndex].velStats;
                              final predSeg = mapPageController
                                  .segStats[roadIndex].predictedStats;
                              final velSeg = mapPageController
                                  .segStats[roadIndex].velocityStats;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Chainage-wise Statistics',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    ExpansionTile(
                                      initiallyExpanded: false,
                                      collapsedBackgroundColor:
                                          Colors.black.withOpacity(0.05),
                                      collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      title: Text(
                                        mapPageController
                                            .roadStats[roadIndex].roadName,
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: [
                                        // TabBar to switch between Prediction-Based and Velocity-Based stats
                                        TabBar(
                                          controller: _tabController,
                                          tabs: const [
                                            Tab(
                                              text: 'Prediction Based',
                                            ),
                                            Tab(
                                              text: 'Velocity Based',
                                            ),
                                          ],
                                          labelColor: Colors.blue,
                                          unselectedLabelColor: Colors.black,
                                          indicatorColor: Colors.blue,
                                          indicatorWeight: 3.0,
                                          labelStyle: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          unselectedLabelStyle:
                                              GoogleFonts.inter(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                        // Content for the selected tab
                                        SizedBox(
                                          height: context.height * 0.5,
                                          child: TabBarView(
                                            controller: _tabController,
                                            children: [
                                              // Prediction-Based stats
                                              _buildSegmentTable(predSeg),
                                              // Velocity-Based stats
                                              _buildSegmentTable(velSeg),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(20),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Overall summary',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const Gap(10),
                                    ExpansionTile(
                                        initiallyExpanded: false,
                                        collapsedBackgroundColor:
                                            Colors.black.withOpacity(0.05),
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        title: Text(
                                          mapPageController
                                              .roadStats[roadIndex].roadName,
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
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
                                            unselectedLabelStyle:
                                                GoogleFonts.inter(
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
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}

Widget _buildDataTable(List<dynamic> statsList) {
  TextStyle headerStyle = GoogleFonts.inter(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      clipBehavior: Clip.antiAlias,
      columnSpacing: 20.0,
      headingRowColor: WidgetStateProperty.resolveWith(
          (states) => Colors.black.withOpacity(0.05)),
      border: TableBorder.symmetric(
        inside: BorderSide(
          color: Colors.black.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      columns: <DataColumn>[
        DataColumn(
          label: Text('PCI', style: headerStyle),
        ),
        DataColumn(
          label: Text('Distance(km)', style: headerStyle),
        ),
        DataColumn(
          label: Text('Velocity(kmph)', style: headerStyle),
        ),
        DataColumn(
          label: Text('No. of segments', style: headerStyle),
        ),
      ],
      rows: <DataRow>[
        for (var stats in statsList)
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text(
                  stats.pci.toString(),
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
              DataCell(
                Text(
                  stats.numberOfSegments.toString(),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

Widget _buildSegmentTable(List<SegmentStats> stats) {
  TextStyle headerStyle = GoogleFonts.inter(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SingleChildScrollView(
      child: DataTable(
          clipBehavior: Clip.antiAlias,
          columnSpacing: 20.0,
          headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Colors.black.withOpacity(0.05)),
          border: TableBorder.symmetric(
            inside: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 1.0,
            ),
          ),
          columns: <DataColumn>[
            DataColumn(
              label: Text('Name', style: headerStyle),
            ),
            DataColumn(
              label: Text('Road No.', style: headerStyle),
            ),
            DataColumn(
              label: Text(
                'Seg No',
                style: headerStyle,
              ),
            ),
            DataColumn(
              label: Text('From', style: headerStyle),
            ),
            DataColumn(
              label: Text('To', style: headerStyle),
            ),
            DataColumn(
              label: Text('Distance (km)', style: headerStyle),
            ),
            DataColumn(
              label: Text('PCI', style: headerStyle),
            ),
            DataColumn(
              label: Text('Remark', style: headerStyle),
            ),
          ],
          rows: <DataRow>[
            for (var seg in stats)
              DataRow(
                cells: <DataCell>[
                  DataCell(Text(seg.name)),
                  DataCell(Text(seg.roadNo)),
                  DataCell(Text(seg.segmentNo)),
                  DataCell(Text(seg.from)),
                  DataCell(Text(seg.to)),
                  DataCell(Text(seg.distance)),
                  DataCell(Text(seg.pci)),
                  DataCell(Text(seg.remarks)),
                ],
              ),
          ]),
    ),
  );
}
