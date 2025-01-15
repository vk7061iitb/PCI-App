import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../Objects/data.dart';
import '../../../../Utils/format_chainage.dart';
import '../../../../Utils/set_road_stats.dart';
import '../../../Models/stats_data.dart';
import '../../Controllers/map_page_controller.dart';
import '../../Controllers/user_data_controller.dart';

class RoadStatisticsPdfPage extends StatefulWidget {
  final int id;
  final String filename;
  final String planned;
  final String vehicleType;
  final String time;
  final Uint8List img1Byte;
  final Uint8List img2Byte;

  const RoadStatisticsPdfPage({
    super.key,
    required this.id,
    required this.filename,
    required this.planned,
    required this.time,
    required this.vehicleType,
    required this.img1Byte,
    required this.img2Byte,
  });

  @override
  RoadStatisticsPdfPageState createState() => RoadStatisticsPdfPageState();
}

class RoadStatisticsPdfPageState extends State<RoadStatisticsPdfPage> {
  late Future<pw.Document> _pdfDocumentFuture;
  late final Map<String, dynamic> user;
  late pw.MemoryImage image1;
  late pw.MemoryImage image2;

  @override
  void initState() {
    super.initState();
    getUser();
    _pdfDocumentFuture = _generatePdfDocument();
  }

  void getUser() {
    final userDataController = UserDataController();
    user = userDataController.storage.read('user');
  }

  Future<pw.Document> _generatePdfDocument() async {
    // Fetch road statistics (similar to previous implementations)
    final mapPageController = Get.find<MapPageController>();
    image1 = pw.MemoryImage(widget.img1Byte);
    image2 = pw.MemoryImage(widget.img2Byte);
    // Clear previous data
    mapPageController.roadOutputData = [];
    List<Map<String, dynamic>> res =
        await localDatabase.queryRoadOutputData(jouneyID: widget.id);
    mapPageController.roadOutputData.add(res);

    if (mapPageController.roadStats.isNotEmpty) {
      mapPageController.roadStats.clear();
      mapPageController.segStats.clear();
    }
    for (var journey in res) {
      final completeStats =
          setRoadStatistics(journeyData: journey, filename: widget.filename);
      mapPageController.roadStats.add(completeStats[0] as List<RoadStats>);
      mapPageController.segStats.add(completeStats[1] as List<SegStats>);
    }

    // Create PDF document
    final pdf = pw.Document();

    // Add content to PDF
    pdf.addPage(
      pw.MultiPage(
        maxPages: 100,
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildPdfContent(mapPageController),
        header: (context) => _buildPdfHeader(),
        footer: (context) => _buildPdfFooter(context),
      ),
    );
    return pdf;
  }

  List<pw.Widget> _buildPdfContent(MapPageController mapPageController) {
    final List<pw.Widget> content = [];
    // calculate total legth
    double totalLegth = 0;
    for (int i = 0; i < mapPageController.segStats.length; i++) {
      String chainage =
          mapPageController.segStats[i].last.predictedStats.last.to;
      totalLegth += chainageToLegth(chainage);
    }
    // Title
    content.add(
      pw.Align(
        child: pw.Text(
          'Road Statistics Report',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
    content.add(
      pw.SizedBox(height: 20),
    );
    content.add(
      pw.Table(
        columnWidths: {
          0: pw.FlexColumnWidth(),
          1: pw.FlexColumnWidth(),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        border: pw.TableBorder.all(color: PdfColors.grey900),
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.Text(
                  'Journey Name/From-To',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: widget.filename,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.Text(
                  'Journey Generated By',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: '${user['email']} (${user['role']})',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.Text(
                  'Total Journey Length',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: '${formatChainage(totalLegth * 1000)} km',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.Text(
                  'Journey Date and Time',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: widget.time,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.Text(
                  'Type of Vehicle Used',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: widget.vehicleType,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.Text(
                  'Journey Type (Planned/Unplanned)',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: widget.planned,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    content.add(pw.SizedBox(height: 20));
    // Iterate through road stats
    for (int i = 0; i < mapPageController.roadStats.length; i++) {
      final journeyStats = mapPageController.roadStats[i];
      final segmentsStatsList = mapPageController.segStats[i];
      int noOfRoads = journeyStats.length;
      for (int j = 0; j < noOfRoads; j++) {
        final rs = journeyStats[j].predStats;
        final vs = journeyStats[j].velStats;
        final ss = segmentsStatsList[j];
        // Road Name Section
        content.add(
          pw.Text(
            journeyStats[j].roadName,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        content.add(pw.SizedBox(height: 10));

        // Overall Summary
        content.add(
          pw.Text(
            'Overall Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        content.add(pw.SizedBox(height: 5));
        // Prediction based
        content.add(
          pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'Prediction Based',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blue,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        );
        content.add(pw.SizedBox(height: 5));
        content.add(_buildStatTable(rs));
        content.add(pw.SizedBox(height: 20));
        // Velocity Based
        content.add(
          pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'Velocity Based',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blue,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        );
        content.add(pw.SizedBox(height: 5));
        content.add(_buildStatTable(vs));
        // Page break between overall and chainage stats
        content.add(pw.NewPage());
        content.add(
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Row(
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      padding:
                          pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        'Prediction Based',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.blue,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Image(
                      image1,
                      height: 800,
                      width: 250,
                    ),
                  ],
                ),
                pw.SizedBox(width: 5),
                pw.Column(
                  children: [
                    pw.Container(
                      padding:
                          pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        'Velocity Based',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.blue,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Image(
                      image2,
                      height: 800,
                      width: 250,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        content.add(pw.NewPage());
        // Segment-wise Details
        content.add(
          pw.Text(
            'Chainage-wise Statistics',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        content.add(pw.SizedBox(height: 5));
        // Prediction Based
        content.add(
          pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'Prediction Based',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blue,
                fontWeight: pw.FontWeight.normal,
              ),
            ),
          ),
        );
        content.add(pw.SizedBox(height: 5));
        content.add(_buildSegmentTable(ss.predictedStats));
        // Page break between roads
        // if the road is already last then don't add new page
        content.add(pw.NewPage());
      }
    }
    return content;
  }

  pw.Widget _buildStatTable(List<dynamic> statsList) {
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.center,
      context: null,
      data: [
        ['PCI', 'Distance (km)', 'Velocity (kmph)', 'No. of Segments'],
        ...statsList.map((stats) => [
              stats.pci.toString(),
              (double.parse(stats.distanceTravelled) / 1000).toStringAsFixed(3),
              (double.parse(stats.avgVelocity) * 3.6).toStringAsFixed(3),
              stats.numberOfSegments.toString(),
            ]),
      ],
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 12,
      ),
      cellStyle: pw.TextStyle(
        fontSize: 10,
      ),
      border: pw.TableBorder.all(color: PdfColors.black),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
    );
  }

  pw.Widget _buildSegmentTable(List<SegmentStats> stats) {
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.center,
      context: null,
      data: [
        [
          'Segment\nNo.',
          'From',
          'To',
          'Distance\n(km)',
          'Prediction\nPCI',
          'Velocity\nPCI',
          'Minimum\nPCI',
          'Remarks'
        ],
        ...stats.map((seg) => [
              seg.segmentNo,
              seg.from,
              seg.to,
              seg.distance,
              seg.pci,
              seg.velocityPCI,
              min(seg.pci, seg.velocityPCI),
              seg.remarks,
            ]),
      ],
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 12,
      ),
      cellStyle: pw.TextStyle(
        fontSize: 10,
      ),
      border: pw.TableBorder.all(color: PdfColors.black),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
    );
  }

  pw.Widget _buildPdfHeader() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        'Report Generated on: ${DateFormat('dd-MMM-yyyy HH:mm').format(DateTime.now())}',
        style: pw.TextStyle(
          fontSize: 12,
          color: PdfColors.grey,
        ),
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Road Statistics PDF',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          /* IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final pdf = await _pdfDocumentFuture;
              final path = await localDatabase.getReportDir();
              final file = File('$path/${widget.filename}.pdf');
              file.writeAsBytesSync(await pdf.save());
            },
          ), */
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.share,
              color: Colors.black,
            ),
            onPressed: () async {
              final pdf = await _pdfDocumentFuture;
              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename: '${widget.filename}_road_statistics.pdf',
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<pw.Document>(
        future: _pdfDocumentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return PdfPreview(
            build: (format) async {
              final pdf = snapshot.data!;
              return pdf.save();
            },
            onShared: (context) {
              //
            },
            allowPrinting: false,
            useActions: false,
            allowSharing: true,
            scrollViewDecoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            pdfPreviewPageDecoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}
