import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Objects/pci_object.dart';

class OutputDataItem extends StatelessWidget {
  const OutputDataItem({
    super.key,
    required this.filename,
    required this.vehicleType,
    required this.time,
    required this.deletefunction,
    required this.id,
  });

  final String filename;
  final String time;
  final String vehicleType;
  final int id;
  final VoidCallback deletefunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filename,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 5),
              Text(time),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 5),
                  child: Text(
                    vehicleType,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.location_on_outlined,
                  color: Colors.blue.shade400,
                  size: 25,
                ),
                onPressed: () async {
                  List<PciData2> pciDataOutput =
                      await localDatabase.queryPciData(id);
                  showModalBottomSheet(
                      isScrollControlled: false,
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3EDF5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('PCI')),
                              DataColumn(label: Text('Latitude')),
                              DataColumn(label: Text('Longitude')),
                            ],
                            rows: pciDataOutput.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(item.prediction.toString())),
                                DataCell(Text(item.latitude.toString())),
                                DataCell(Text(item.longitude.toString())),
                              ]);
                            }).toList(),
                          ),
                        );
                      });
                },
              ),
              IconButton(
                onPressed: deletefunction,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.black54,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
