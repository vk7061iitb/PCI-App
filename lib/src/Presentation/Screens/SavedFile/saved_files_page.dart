import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/Utils/font_size.dart';
import 'package:pciapp/src/Presentation/Controllers/saved_file_controller.dart';
import 'package:pciapp/src/Presentation/Screens/SavedFile/widget/history_data_tile.dart';
import 'widget/about_page.dart';
import 'widget/confirm_delete.dart';
import 'widget/empty_page.dart';

class HistoryDataPage extends StatefulWidget {
  const HistoryDataPage({super.key});

  @override
  HistoryDataPageState createState() => HistoryDataPageState();
}

class HistoryDataPageState extends State<HistoryDataPage> {
  @override
  Widget build(BuildContext context) {
    SavedFileController savedFileController = Get.put(SavedFileController());
    double screenWidth = MediaQuery.sizeOf(context).width;
    FontSize fontSize = getFontSize(screenWidth);
    IconsSize iconSize = getIconSize(screenWidth);
    TextStyle popUpMenuTextStyle = GoogleFonts.inter(
      color: textColor,
      fontWeight: FontWeight.normal,
      fontSize: fontSize.bodyTextFontSize,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: AutoSizeText(
          'Saved Files',
          style: GoogleFonts.inter(
            fontSize: fontSize.appBarFontSize,
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
              size: iconSize.appBarIconSize,
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
                      context: context, builder: (context) => AboutPage());
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
            ],
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
                    color: activeColor,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading files: ${snapshot.error}'),
                );
              } else if (snapshot.data!.isEmpty) {
                return EmptyPage(
                  iconPath: assetsPath.emptyFile,
                  fontSize: fontSize.bodyTextFontSize,
                  iconSize: iconSize.buttonIconSize,
                );
              } else {
                List<Map<String, dynamic>> savedFiles = snapshot.data ?? [];
                return RefreshIndicator(
                  key: savedFileController.refreshKey,
                  color: activeColor,
                  backgroundColor: backgroundColor,
                  onRefresh: () async {
                    await savedFileController.refreshData();
                    await savedFileController.loadSavedFiles();
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
                          Map<String, dynamic> savedFile = savedFiles[index];
                          return HistoryDataItem(
                            file: savedFile,
                            deleteFile: () async {
                              bool? value = await _showDeleteDialog(context);
                              if (value != null && value) {
                                savedFileController.deleteFile(savedFile);
                              }
                            },
                            shareFile: () {
                              savedFileController.shareFile(savedFile);
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

Future<bool?> _showDeleteDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const ConfirmDelete();
    },
  );
}
