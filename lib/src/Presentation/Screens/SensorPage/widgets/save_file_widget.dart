import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Utils/font_size.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/vehicle_type_dropdown.dart';

class SaveFile extends StatelessWidget {
  const SaveFile({super.key});

  @override
  Widget build(BuildContext context) {
    ResponseController responseController = Get.find();
    AccDataController accDataController = Get.find();
    double w = MediaQuery.sizeOf(context).width;
    FontSize fs = getFontSize(w);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showAlert(context) ?? false;
        if (shouldPop) {
          Get.back(result: false);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const Gap(10),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.1,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Save Recording",
                        style: GoogleFonts.inter(
                          fontSize: fs.heading2FontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Choose how'd you like to save the recording.",
                        style: GoogleFonts.inter(
                          fontSize: fs.bodyTextFontSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                      const Gap(20),
                      Obx(() {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {
                                  responseController.isPlanned.value = true;
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                  backgroundColor,
                                )),
                                child: Row(
                                  children: [
                                    Icon(
                                      responseController.isPlanned.value
                                          ? Icons.check
                                          : Icons.cancel_outlined,
                                    ),
                                    const Gap(10),
                                    Text(
                                      "Planned",
                                      style: GoogleFonts.inter(
                                        fontSize: fs.appBarFontSize,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            responseController.isPlanned.value
                                                ? Colors.deepPurple
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(20),
                              TextButton(
                                onPressed: () {
                                  responseController.isPlanned.value = false;
                                },
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                  backgroundColor,
                                )),
                                child: Row(
                                  children: [
                                    Icon(
                                      !responseController.isPlanned.value
                                          ? Icons.check
                                          : Icons.cancel_outlined,
                                    ),
                                    const Gap(10),
                                    Text(
                                      "Un-Planned",
                                      style: GoogleFonts.inter(
                                        fontSize: fs.appBarFontSize,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            !responseController.isPlanned.value
                                                ? Colors.deepPurple
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ]);
                      }),
                      const Gap(20),
                      Text(
                        "Vehicle Type",
                        style: GoogleFonts.inter(
                          fontSize: fs.appBarFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(10),
                      VehicleType(
                        width: MediaQuery.of(context).size.width * 0.9,
                      ),
                      const Gap(20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recording Name",
                            style: GoogleFonts.inter(
                              fontSize: fs.appBarFontSize,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const Gap(10),
                          Obx(() {
                            return Form(
                              key: responseController.formKey,
                              child: TextFormField(
                                controller:
                                    responseController.fileNameController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a file name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.drive_file_rename_outline),
                                  labelText: 'Enter the file name',
                                  labelStyle: GoogleFonts.inter(
                                    fontSize: fs.bodyTextFontSize,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  isDense: true,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                      const Gap(20),
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pedestrian reason
                            (accDataController.isPedestrianFound.value)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reason for Pedestrian",
                                        style: GoogleFonts.inter(
                                          fontSize: fs.appBarFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Gap(10),
                                      Form(
                                        key: responseController
                                            .pedestrianFormKey,
                                        child: TextFormField(
                                          controller: responseController
                                              .pedestianController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return "Please metion the reason";
                                            }
                                            return null;
                                          },
                                          expands: false,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.notes),
                                            enabled: true,
                                            hintText:
                                                'Describe why there was a Pedestrian area',
                                            isDense: true,
                                            labelStyle: GoogleFonts.inter(
                                              color: Colors.black54,
                                              fontSize: fs.bodyTextFontSize,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.black,
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15),
                                              ),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                          ],
                        );
                      }),
                      const Gap(20),
                      Obx(() {
                        return responseController.savingData
                            ? const SizedBox()
                            : Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        if (!responseController
                                            .formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        if (accDataController
                                                .isPedestrianFound.value &&
                                            !responseController
                                                .pedestrianFormKey.currentState!
                                                .validate()) {
                                          return;
                                        }
                                        responseController.savingData = true;
                                        logger.d("Saving Data..");
                                        await responseController.saveData(
                                          accData: accDataController
                                              .downSampledDatapoints,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        "Submit and Save",
                                        style: GoogleFonts.inter(
                                          fontSize: fs.appBarFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
              return responseController.savingData
                  ? LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color?>(
                        Colors.blue[900],
                      ),
                    )
                  : const SizedBox();
            }),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _showAlert(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content:
            const Text('Arey you sure you do not want to save the recording?'),
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
              'Save',
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
              'Discard',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    },
  );
}
