import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Screens/SavedFile/widget/history_data_tile.dart';
import 'package:share_plus/share_plus.dart';

class HistoryDataPage extends StatefulWidget {
  const HistoryDataPage({super.key});

  @override
  HistoryDataPageState createState() => HistoryDataPageState();
}

class HistoryDataPageState extends State<HistoryDataPage> {
  bool isSelected = false;

  late Future<List<File>> _savedFilesFuture;

  @override
  void initState() {
    super.initState();
    _savedFilesFuture = loadSavedFiles();
  }

  Future<List<File>> loadSavedFiles() async {
    Directory? appExternalStorageDir = await getExternalStorageDirectory();
    Directory accDataDirectory =
        Directory(join(appExternalStorageDir!.path, "Acceleration Data"));

    List<FileSystemEntity> files = await accDataDirectory.list().toList();
    return files.whereType<File>().toList();
  }

  Future<void> deleteFile(File file) async {
    try {
      await file.delete();
      setState(() {
        _savedFilesFuture = loadSavedFiles();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting file: $e");
      }
    }
  }

  Future<void> shareFile(File file) async {
    try {
      XFile xFile = XFile(file.path);
      await Share.shareXFiles([xFile]);
    } catch (e) {
      if (kDebugMode) {
        print("Error sharing file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: AppBar(
        title: Text(
          'Saved Files',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF3EDF5),
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
      body: FutureBuilder<List<File>>(
        future: _savedFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
              onRefresh: () async {
                setState(() {
                  _savedFilesFuture = loadSavedFiles();
                });
              },
              child: ListView.builder(
                itemCount: savedFiles.length,
                itemBuilder: (context, index) {
                  File file = savedFiles[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    child: HistoryDataItem(
                      file: file,
                      deleteFile: () {
                        deleteFile(file);
                      },
                      shareFile: () {
                        shareFile(file);
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
