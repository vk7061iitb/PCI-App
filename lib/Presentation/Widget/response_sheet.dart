import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Functions/send_data_to_server.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Presentation/Widget/dropdown_widget.dart';
import '../../Objects/data_points.dart';
import 'snackbar.dart';

class ResponseSheet extends StatefulWidget {
  const ResponseSheet(
      {required this.onPressed, required this.filteredAccData, super.key});

  final List<AccData> filteredAccData;
  final VoidCallback onPressed;

  @override
  State<ResponseSheet> createState() => _ResponseSheetState();
}

class _ResponseSheetState extends State<ResponseSheet> {
  String dbMessage = " ";
  TextEditingController fileNameController = TextEditingController();
  bool saveLocally = true;
  String serverMessage = " ";
  bool show = true;

  bool _savingData = false;

  IconData getIcon(String dropdownValue) {
    switch (dropdownValue) {
      case 'Bike':
        return Icons.directions_bike_rounded;
      case 'Car':
        return Icons.directions_car_rounded;
      case 'Bus':
        return Icons.directions_bus_rounded;
      case 'Auto':
        return Icons.electric_rickshaw_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  Future<void> _saveData() async {
    await localDatabase.insertData(widget.filteredAccData, gyroDataList);
    serverMessage = await sendDataToServer(widget.filteredAccData);

    if (saveLocally) {
      dbMessage = await localDatabase.exportToCSV(
          fileNameController.text, dropdownValue);
      fileNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: show
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(10),
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const Gap(20),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Do you want to save the collected readings?',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.green),
                            ),
                            onPressed: () {
                              // Save the readings
                              show = false;
                              setState(() {});
                            },
                            child: Text('Yes',
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                            ),
                            onPressed: () {
                              // Discard the readings
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Discard the readings?',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              MediaQuery.textScalerOf(context)
                                                  .scale(22),
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to discard the readings? If you discard the file, any recorded data will be lost.',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {});
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Yes',
                                            style: GoogleFonts.inter(
                                                color: Colors.red,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'No',
                                            style: GoogleFonts.inter(
                                                color: Colors.blue,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Text('No',
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : Column(
                  children: [
                    const Gap(10),
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12,
                          ),
                          child: Row(
                            children: [
                              const Gap(15),
                              Icon(
                                getIcon(dropdownValue),
                                weight: 10,
                                size: 30,
                              ),
                              const Gap(5),
                              VehicleTypeDropdown(
                                  onPressed: (String value) {
                                    setState(() {
                                      dropdownValue = value;
                                    });
                                  },
                                  dropdownValue: dropdownValue),
                              const Gap(15),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12,
                          ),
                          child: Row(
                            children: [
                              const Gap(15),
                              Text(
                                "Save Locally",
                                style: GoogleFonts.inter(
                                    color: Colors.black, fontSize: 18),
                              ),
                              const Gap(5),
                              // Switch to save the readings locally
                              Switch(
                                value: saveLocally,
                                onChanged: (bool value) {
                                  saveLocally = !saveLocally;
                                  setState(() {});
                                },
                                activeColor: Colors.blue.shade800,
                                activeTrackColor: Colors.blue.shade200,
                              ),
                              const Gap(15),
                            ],
                          ),
                        ),
                      ],
                    ),
                    saveLocally
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 25.0,
                            ),
                            child: TextFormField(
                              controller: fileNameController,
                              decoration: const InputDecoration(
                                labelText: 'Enter the file name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.green),
                            ),
                            onPressed: () async {
                              setState(() {
                                _savingData = true;
                              });
                              _saveData().then((_) {
                                setState(() {
                                  _savingData = false;
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  customSnackBar(serverMessage),
                                );

                                if (saveLocally) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    customSnackBar(dbMessage),
                                  );
                                }
                              });
                            },
                            child: Text(
                              'Save',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.red),
                            ),
                            onPressed: () {
                              // Discard the readings
                              if (_savingData) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Discard the readings?',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              MediaQuery.textScalerOf(context)
                                                  .scale(22),
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to discard the readings? If you discard the file, any recorded data will be lost.',
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {});
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Yes',
                                            style: GoogleFonts.inter(
                                                color: Colors.red,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'No',
                                            style: GoogleFonts.inter(
                                                color: Colors.blue,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text('Discard',
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                    if (_savingData)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Saving Data...',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Gap(MediaQuery.of(context).viewInsets.bottom)
                  ],
                ),
        ),
      ),
    );
  }
}
