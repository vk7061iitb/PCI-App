import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Saved Files',
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
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
          return FutureBuilder<List<File>>(
            future: savedFileController.savedFiles.value,
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
                      width: 50,
                    ),
                    Center(
                      child: Text(
                        'There are no files to display',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                );
              } else {
                List<File> savedFiles = snapshot.data ?? [];
                return RefreshIndicator(
                  key: savedFileController.refreshKey,
                  onRefresh: () async {
                    savedFileController.refreshData();
                    savedFileController.loadSavedFiles();
                  },
                  child: ListView.builder(
                    itemCount: savedFiles.length,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemBuilder: (context, index) {
                      File file = savedFiles[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: HistoryDataItem(
                          file: file,
                          deleteFile: () {
                            _showDeleteDialog(context, file).then((value) {
                              if (value != null && value) {
                                savedFileController.deleteFile(file);
                              }
                            });
                          },
                          shareFile: () {
                            savedFileController.shareFile(file);
                          },
                          unsentData: savedFileController.unsentFiles,
                        ),
                      );
                    },
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
Future<bool?> _showDeleteDialog(BuildContext context, File file) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete File?'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content: const Text('Are you sure you want to delete this file?'),
        contentTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(
              'No',
              style: GoogleFonts.inter(
                fontSize: 16,
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
                fontSize: 16,
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
