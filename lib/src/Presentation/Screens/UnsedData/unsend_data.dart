import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';
import 'package:pci_app/src/Presentation/Screens/UnsedData/unsent_file_tile.dart';
import '../../../../Objects/data.dart';

class UnsendData extends StatefulWidget {
  const UnsendData({super.key});

  @override
  State<UnsendData> createState() => _UnsendDataState();
}

class _UnsendDataState extends State<UnsendData> {
  late Future<List<Map<String, dynamic>>> unsentDataFiles;
  ResponseController responseController = Get.put(ResponseController());
  Future<List<Map<String, dynamic>>> getUnsentData() async {
    List<Map<String, dynamic>> unsendDataFiles = [];
    unsendDataFiles = await localDatabase.queryTable('unsendDataInfo');
    return unsendDataFiles;
  }

  @override
  void initState() {
    super.initState();
    unsentDataFiles = getUnsentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: AppBar(
        title: Text(
          'Unsend Files',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF3EDF5),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: unsentDataFiles,
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
            }
            List<Map<String, dynamic>> unsentData = snapshot.data!;
            return ListView.builder(
              itemCount: unsentData.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: UnsentFileTile(
                    filename: unsentData[index]['filename'],
                    vehicleType: unsentData[index]['vehicleType'],
                    time: unsentData[index]['Time'],
                    id: unsentData[index]['id'],
                    onDeleteTap: () {
                      localDatabase
                          .deleteUnsentDataInfo(unsentData[index]['id']);
                      localDatabase.deleteUnsentData(unsentData[index]['id']);
                      setState(() {
                        unsentDataFiles = getUnsentData();
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
