import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/Objects/data.dart';
import 'package:pciapp/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pciapp/src/Presentation/Widgets/snackbar.dart';
import '../../../../../Utils/font_size.dart';

class PauseResume extends StatefulWidget {
  const PauseResume({super.key});

  @override
  State<PauseResume> createState() => _PauseResumeState();
}

class _PauseResumeState extends State<PauseResume> {
  AccDataController accDataController = Get.find();
  @override
  Widget build(BuildContext context) {
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
                        "Reason for Pause",
                        style: GoogleFonts.inter(
                          fontSize: fs.heading2FontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(20),
                      Form(
                        key: accDataController.pauseFormKey,
                        child: TextFormField(
                          controller: accDataController.pauseReasonController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the form';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Enter the details',
                            alignLabelWithHint: true,
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
                          maxLines: null,
                          minLines: 1,
                        ),
                      ),
                      const Gap(20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                if (!accDataController
                                    .pauseFormKey.currentState!
                                    .validate()) {
                                  return;
                                }
                                accDataController.remarks.value =
                                    accDataController
                                        .pauseReasonController.text;
                                Future.delayed(const Duration(seconds: 1))
                                    .then((_) {
                                  Get.back();
                                  Get.showSnackbar(
                                    customGetSnackBar(
                                      "Submitted",
                                      "Pause details recorded successfully",
                                      Icons.check,
                                    ),
                                  );
                                }).onError((error, stackTrace) {
                                  logger.f(error);
                                  logger.d(stackTrace);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: GoogleFonts.inter(
                                  fontSize: fs.appBarFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
        title: const Text('Empty form'),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        content:
            const Text('The form cannot be empty, please enter the reason.'),
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
              'Ok',
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
