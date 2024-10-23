import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Screens/OutputData/output_data_tile.dart';

class OutputDataPage extends StatefulWidget {
  const OutputDataPage({super.key});

  @override
  State<OutputDataPage> createState() => _OutputDataPageState();
}

class _OutputDataPageState extends State<OutputDataPage> {
  late Future<List<Map<String, dynamic>>> outputDataFile;
  Future<List<Map<String, dynamic>>> getData() async {
    List<Map<String, dynamic>> outputData = [];
    outputData = await localDatabase.queryTable('outputData');
    return outputData;
  }

  @override
  void initState() {
    super.initState();
    outputDataFile = getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: AppBar(
        title: Text(
          'Journey History',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF3EDF5),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: outputDataFile,
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
            List<Map<String, dynamic>> outputData = snapshot.data!;

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: outputData.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: OutputDataItem(
                    filename: outputData[index]["filename"],
                    vehicleType: outputData[index]["vehicleType"],
                    time: outputData[index]["Time"],
                    id: outputData[index]["id"],
                    onDeleteTap: () {
                      localDatabase.deleteOutputData(outputData[index]["id"]);
                      localDatabase
                          .deleteRoadOutputData(outputData[index]["id"]);
                      setState(() {
                        outputDataFile = getData();
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
