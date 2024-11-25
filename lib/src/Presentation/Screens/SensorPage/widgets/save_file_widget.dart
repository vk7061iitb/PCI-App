import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/response_controller.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/SensorPage/widgets/vehicle_type_dropdown.dart';

class SaveFile extends StatelessWidget {
  const SaveFile({super.key});

  @override
  Widget build(BuildContext context) {
    ResponseController responseController = Get.put(ResponseController());
    AccDataController accDataController = Get.find();
    return Container(
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
                        fontSize: MediaQuery.textScalerOf(context).scale(26),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Choose how'd you like to save the recording.",
                      style: GoogleFonts.inter(
                        fontSize: MediaQuery.textScalerOf(context).scale(16),
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Text(
                          "Save Locally",
                          style: GoogleFonts.inter(
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(18),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Gap(10),
                        Obx(() {
                          return Switch(
                            value: responseController.isSaveLocally,
                            onChanged: (bool value) {
                              responseController.isSaveLocally = value;
                            },
                            thumbIcon: WidgetStateProperty.all(
                              responseController.isSaveLocally
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.close),
                            ),
                          );
                        })
                      ],
                    ),
                    const Gap(10),
                    Text(
                      "Vehicle Type",
                      style: GoogleFonts.inter(
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(10),
                    VehicleType(
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                    const Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recording Name",
                          style: GoogleFonts.inter(
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(18),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Gap(10),
                        Obx(() {
                          return Form(
                            key: responseController.formKey,
                            child: TextFormField(
                              controller: responseController.fileNameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a file name';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                prefixIcon:
                                    Icon(Icons.drive_file_rename_outline),
                                labelText: 'Enter the file name',
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
                    const Gap(10),
                    // Notes
                    Text(
                      "Notes",
                      style: GoogleFonts.inter(
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(10),
                    Form(
                      child: TextFormField(
                        expands: false,
                        maxLines: 2,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.notes),
                          enabled: false,
                          hintText:
                              'Add any additional notes about the recording',
                          isDense: true,
                          labelStyle: GoogleFonts.inter(
                            color: Colors.black54,
                          ),
                          focusedBorder: const OutlineInputBorder(
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
                    const Gap(15),
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
                                      responseController.savingData = true;
                                      logger.d("Saving Data..");
                                      await responseController.saveData(
                                          accDataController
                                              .downSampledDatapoints);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      responseController.isSaveLocally
                                          ? "Submit and Save"
                                          : "Submit",
                                      style: GoogleFonts.inter(
                                        fontSize:
                                            MediaQuery.textScalerOf(context)
                                                .scale(18),
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
    );
  }
}
