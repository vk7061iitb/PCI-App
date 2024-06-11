import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Presentation/Widget/output_data_tile.dart';

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
      appBar: AppBar(
        title: Text(
          'Output Data',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
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
              return const Center(child: Text('No data available'));
            }
            List<Map<String, dynamic>> outputData = snapshot.data!;

            return ListView.builder(
              itemCount: outputData.length,
              itemBuilder: (BuildContext context, int index) {
                return OutputDataItem(
                  filename: outputData[index]["filename"],
                  vehicleType: outputData[index]["vehicleType"],
                  time: outputData[index]["Time"],
                  id: outputData[index]["id"],
                  deletefunction: () {
                    localDatabase.deleteOutputData(outputData[index]["id"]);
                    setState(() {
                      outputDataFile = getData();
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
