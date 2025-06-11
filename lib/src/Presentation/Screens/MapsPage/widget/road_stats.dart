import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/src/Presentation/Controllers/map_page_controller.dart';
import 'package:pciapp/src/Presentation/Controllers/output_data_controller.dart';
import 'package:pciapp/src/Presentation/Screens/OutputData/map_screenshot.dart';
import '../../../../../Objects/data.dart';
import '../../../../Models/stats_data.dart';
import '../../../Widgets/snackbar.dart';

class RoadStatistics extends StatelessWidget {
  const RoadStatistics({
    required this.id,
    required this.filename,
    required this.planned,
    required this.time,
    required this.vehicleType,
    super.key,
  });

  final int id;
  final String filename;
  final String planned;
  final String time;
  final String vehicleType;

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find<MapPageController>();
    OutputDataController outputDataController =
        Get.find<OutputDataController>();

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: OutlinedButton(
        onPressed: () async {
          if (outputDataController.showProgressInStatsPage.value) {
            return;
          }
          outputDataController.slectedFiles.clear();
          outputDataController.slectedFiles.add(id);
          mapPageController.showPCIlabel = true;
          try {
            await outputDataController.plotRoads();
            Get.to(() => MapScreenshot(),
                transition: Transition.cupertino,
                arguments: {
                  "id": id,
                  "filename": filename,
                  "planned": planned,
                  "time": time,
                  "vehicleType": vehicleType,
                });
            outputDataController.slectedFiles.clear();
          } catch (e) {
            customGetSnackBar("Plotting Error",
                "Error in plotting the road data", Icons.error_outline);
            logger.e(e.toString());
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.black87),
        ),
        child: Text(
          "Download Report",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<dynamic>(
            future: outputDataController.setRoadStats(
                journeyID: id, filename: filename),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: activeColor,
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width * 0.05),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                            text:
                                "Showing the prediction and velocity based statistics of the file: ",
                            style: GoogleFonts.inter(
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                text: filename,
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                ),
                              )
                            ]),
                      ),
                      const Gap(15),
                      Expanded(
                        child: PageView.builder(
                          itemCount: mapPageController.roadStats.length,
                          itemBuilder: (context, index) {
                            return StatsPageView(index: index);
                          },
                        ),
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

class StatsPageView extends StatelessWidget {
  const StatsPageView({required this.index, super.key});
  final int index;

  @override
  Widget build(BuildContext context) {
    MapPageController mapPageController = Get.find();
    return Scaffold(
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: mapPageController.roadStats[index].length,
        itemBuilder: (context, roadIndex) {
          final outputStats = mapPageController
              .roadStats[index][roadIndex].overallStatsPredictionBased;
          final predSeg =
              mapPageController.segStats[index][0].chainageStatsPredictionBased;
          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Column(
              children: [
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
                OverallStatisticsTable(
                  statsList: outputStats,
                ),
                const Gap(20),
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
                ChainageStatisticTable(
                  stats: predSeg,
                ),
                const Gap(60),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OverallStatisticsTable extends StatelessWidget {
  final List<dynamic> statsList;
  const OverallStatisticsTable({super.key, required this.statsList});

  @override
  Widget build(BuildContext context) {
    TextStyle headerStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
    final ScrollController scrollController = ScrollController();
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: false,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          // Rest of your code remains the same
          clipBehavior: Clip.antiAlias,
          columnSpacing: 20.0,
          headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Colors.black.withValues(alpha: 0.05)),
          border: TableBorder.symmetric(
            inside: BorderSide(
              color: Colors.black.withValues(alpha: 0.1),
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
              if (double.parse(stats.pci.toString()) > 0)
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
                        (double.parse(stats.avgVelocity) * 3.6)
                            .toStringAsFixed(3),
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
      ),
    );
  }
}

class ChainageStatisticTable extends StatelessWidget {
  final List<RoadChainageStatistics> stats;
  const ChainageStatisticTable({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final ScrollController horizontalScrollController = ScrollController();
    final ScrollController verticalScrollController = ScrollController();

    TextStyle headerStyle = GoogleFonts.inter(
      color: Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
    return Scrollbar(
      controller: horizontalScrollController,
      thumbVisibility: true,
      trackVisibility: false,
      child: SingleChildScrollView(
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Scrollbar(
          controller: verticalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: verticalScrollController,
            child: DataTable(
                clipBehavior: Clip.antiAlias,
                columnSpacing: 20.0,
                headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.black.withValues(alpha: 0.05)),
                border: TableBorder.symmetric(
                  inside: BorderSide(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                ),
                columns: <DataColumn>[
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
                        DataCell(Text(seg.roadNo)),
                        DataCell(Text(seg.segmentNo)),
                        DataCell(Text(seg.from)),
                        DataCell(Text(seg.to)),
                        DataCell(Text(seg.distance)),
                        DataCell(Text((seg.pci < 0) ? "Pause" : '${seg.pci}')),
                        DataCell(Text(seg.remarks)),
                      ],
                    ),
                ]),
          ),
        ),
      ),
    );
  }
}
