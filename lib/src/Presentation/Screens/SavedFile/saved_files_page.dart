import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Utils/font_size.dart';
import 'package:pci_app/src/Presentation/Controllers/saved_file_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SavedFile/widget/history_data_tile.dart';

class HistoryDataPage extends StatefulWidget {
  const HistoryDataPage({super.key});

  @override
  HistoryDataPageState createState() => HistoryDataPageState();
}

class HistoryDataPageState extends State<HistoryDataPage> {
  @override
  Widget build(BuildContext context) {
    SavedFileController savedFileController = Get.put(SavedFileController());
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    IconsSize iS = getIconSize(w);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: AutoSizeText(
          'Saved Files',
          style: GoogleFonts.inter(
            fontSize: fs.appBarFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              //localDatabase.deleteTable('savedData');
            },
            icon: Icon(
              Icons.search,
              size: iS.appBarIconSize,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (savedFileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: savedFileController.loadSavedFiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade900,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading files: ${snapshot.error}'),
                );
              } else if (snapshot.data!.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      assetsPath.emptyFile,
                      width: iS.buttonIconSize,
                    ),
                    Center(
                      child: Text(
                        'There are no files to display',
                        style: GoogleFonts.inter(
                          fontSize: fs.bodyTextFontSize,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                );
              } else {
                List<Map<String, dynamic>> savedFiles = snapshot.data ?? [];
                return RefreshIndicator(
                  key: savedFileController.refreshKey,
                  color: activeColor,
                  backgroundColor: backgroundColor,
                  onRefresh: () async {
                    savedFileController.refreshData();
                    savedFileController.loadSavedFiles();
                  },
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(
                        Color(0xFFc0c0c0),
                      ),
                      thickness: WidgetStateProperty.all(8.0),
                      radius: Radius.circular(10),
                      interactive: true,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: false,
                      child: ListView.builder(
                        itemCount: savedFiles.length,
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemBuilder: (context, index) {
                          Map<String, dynamic> file = savedFiles[index];
                          return HistoryDataItem(
                            file: file,
                            deleteFile: () {
                              _showDeleteDialog(context, w).then((value) {
                                if (value != null && value) {
                                  savedFileController.deleteFile(file);
                                }
                              });
                            },
                            shareFile: () {
                              savedFileController.shareFile(file);
                            },
                            unsentData: savedFileController.unsentFiles,
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }),
      ),
    );
  }
}

// Get alert dialog to confirm deletion of file
Future<bool?> _showDeleteDialog(BuildContext context, double w) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete File?'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: w * 0.06,
        ),
        content: const Text('Are you sure you want to delete this file?'),
        contentTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: w * 0.04,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: w * 0.04,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text(
              'Yes',
              style: GoogleFonts.inter(
                fontSize: w * 0.04,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    },
  );
}
