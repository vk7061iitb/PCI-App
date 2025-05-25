import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';
import 'package:pciapp/Utils/text_styles.dart';
import 'package:pciapp/src/Presentation/Controllers/saved_file_controller.dart';
import 'package:pciapp/src/Presentation/Screens/SavedFile/widget/history_data_tile.dart';

String aboutPage = '''
This page displays all recorded data. If any data was not submitted due to a network issue, you can resend it from here. 
Note: Exported data will be in its raw, unprocessed format as originally recorded.
''';

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
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: textColor,
      fontWeight: FontWeight.normal,
      fontSize: fs.bodyTextFontSize,
    );
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
          PopupMenuButton<int>(
            icon: Icon(
              Icons.filter_list,
              size: iS.appBarIconSize,
              color: textColor,
            ),
            onSelected: (val) {
              savedFileController.selectedFilter.value = val;
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 0,
                onTap: () async {
                  savedFileController.showSubmitted.value = true;
                  savedFileController.showNotSubmitted.value = false;
                  savedFileController.showAll.value = false;
                  await savedFileController.refreshData();
                },
                child: Row(
                  children: [
                    Icon(
                      savedFileController.selectedFilter.value == 0
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: savedFileController.selectedFilter.value == 0
                          ? Colors.blue
                          : textColor,
                    ),
                    const Gap(4),
                    Text(
                      "Submitted",
                      style: popUpMenuTextStyle.copyWith(
                        color: savedFileController.selectedFilter.value == 0
                            ? Colors.blue
                            : textColor,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                onTap: () async {
                  savedFileController.showSubmitted.value = false;
                  savedFileController.showNotSubmitted.value = true;
                  savedFileController.showAll.value = false;
                  await savedFileController.refreshData();
                },
                child: Row(
                  children: [
                    Icon(
                        savedFileController.selectedFilter.value == 1
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: savedFileController.selectedFilter.value == 1
                            ? Colors.blue
                            : textColor),
                    const Gap(4),
                    Text(
                      "Not Submitted",
                      style: popUpMenuTextStyle.copyWith(
                        color: savedFileController.selectedFilter.value == 1
                            ? Colors.blue
                            : textColor,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                onTap: () async {
                  savedFileController.showSubmitted.value = false;
                  savedFileController.showNotSubmitted.value = false;
                  savedFileController.showAll.value = true;
                  await savedFileController.refreshData();
                },
                child: Row(
                  children: [
                    Icon(
                      savedFileController.selectedFilter.value == 2
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: savedFileController.selectedFilter.value == 2
                          ? Colors.blue
                          : textColor,
                    ),
                    const Gap(4),
                    Text(
                      "All Files",
                      style: popUpMenuTextStyle.copyWith(
                        color: savedFileController.selectedFilter.value == 2
                            ? Colors.blue
                            : textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // about page
          PopupMenuButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              itemBuilder: (context) => [
                    // info button
                    PopupMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('About the journey history',
                                style: dialogTitleStyle),
                            content: Text(aboutPage, style: dialogContentStyle),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'OK',
                                  style: dialogButtonStyle,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded),
                          const Gap(8),
                          Text(
                            "About Page",
                            style: popUpMenuTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ]),
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
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content: const Text('Are you sure you want to delete this file?'),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: textColor,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: 18,
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
                fontSize: 18,
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
