import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HistoryDataPage extends StatefulWidget {
  const HistoryDataPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryDataPageState createState() => _HistoryDataPageState();
}

class _HistoryDataPageState extends State<HistoryDataPage> {
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
      // ignore: deprecated_member_use
      await Share.shareFiles([file.path]);
    } catch (e) {
      if (kDebugMode) {
        print("Error sharing file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Data',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
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
          } else {
            List<File> savedFiles = snapshot.data ?? [];

            return ListView.builder(
              itemCount: savedFiles.length,
              itemBuilder: (context, index) {
                File file = savedFiles[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFF3EDF5),
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      title: Text(file.path.split('/').last),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => shareFile(file),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteFile(file),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
