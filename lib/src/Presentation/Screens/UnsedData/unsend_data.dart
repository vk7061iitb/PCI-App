import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/src/Presentation/Screens/UnsedData/unsent_file_tile.dart';
import '../../../../Objects/data.dart';

class UnsendData extends StatefulWidget {
  const UnsendData({super.key});

  @override
  State<UnsendData> createState() => _UnsendDataState();
}

class _UnsendDataState extends State<UnsendData> {
  late Future<List<Map<String, dynamic>>> unsentData;
  Future<List<Map<String, dynamic>>> getUnsentData() async {
    return localDatabase.queryTable('unsendDataInfo');
  }

  @override
  void initState() {
    super.initState();
    unsentData = getUnsentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      appBar: AppBar(
        title: Text(
          'Unsent Data',
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
          future: unsentData,
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No data available',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
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
                      id: unsentData[index]['id']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
