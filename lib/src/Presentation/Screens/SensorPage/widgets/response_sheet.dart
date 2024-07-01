import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Functions/send_data_to_server.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/vehicle_dropdown_widget.dart';
import '../../../../../Utils/get_icon.dart';
import '../../../../Models/data_points.dart';
import '../../../Widgets/snackbar.dart';

class ResponseSheet extends StatefulWidget {
  const ResponseSheet(
      {required this.onPressed,
      required this.filteredAccData,
      required this.userID,
      super.key});

  final List<AccData> filteredAccData;
  final VoidCallback onPressed;
  final String userID;

  @override
  State<ResponseSheet> createState() => _ResponseSheetState();
}

class _ResponseSheetState extends State<ResponseSheet> {
  String _dbMessage = " ";
  String _serverMessage = " ";
  bool _show = true;
  bool _saveLocally = true;
  bool _savingData = false;
  TextEditingController fileNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Save the data to the local database and send it to the server
  Future<void> _saveData() async {
    await localDatabase.insertAccData(widget.filteredAccData);
    _serverMessage = await sendDataToServer(
        accData: widget.filteredAccData, userID: widget.userID);

    // Save the data locally
    if (_saveLocally) {
      _dbMessage = await localDatabase.exportToCSV(
          fileNameController.text, dropdownValue);
      fileNameController.clear();
      localDatabase.deleteAcctables();
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
          child: _show
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    const Gap(10),
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
                              _show = false;
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
                                      'Are you sure? If you discard the file, any recorded data will be lost',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal),
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'No',
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 18),
                            ),
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
                                value: _saveLocally,
                                onChanged: (bool value) {
                                  _saveLocally = !_saveLocally;
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
                    _saveLocally
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 25.0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: fileNameController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a file name';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Enter the file name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(50),
                                    ),
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
                              if (_saveLocally &&
                                  !_formKey.currentState!.validate()) {
                                return;
                              }
                              setState(() {
                                _savingData = true;
                              });
                              _saveData().then((_) {
                                setState(() {
                                  _savingData = false;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  customSnackBar(_serverMessage),
                                );
                                if (_saveLocally) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    customSnackBar(_dbMessage),
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
