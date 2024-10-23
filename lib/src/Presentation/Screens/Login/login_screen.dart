import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/src/Presentation/Controllers/login_controller.dart';
import 'package:pci_app/src/Presentation/Screens/Login/roles_dropdown.dart';
import 'package:pci_app/src/Presentation/Widgets/snackbar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.put(LoginController());
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(
              children: [
                const Gap(50),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome Back!",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Gap(10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign in to your account to continue",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Gap(50),
                Form(
                  key: loginController.loginFormKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Gap(10),
                      TextFormField(
                        controller: loginController.emailController,
                        autocorrect: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
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
                          isDense: false,
                          contentPadding: const EdgeInsets.all(15),
                          prefixIcon: const Icon(Icons.mail_outline),
                          hintText: "Enter Your Email Address",
                          hintStyle: GoogleFonts.inter(
                            color: Colors.black54,
                          ),
                        ),
                        validator: (value) {
                          if (value!.length < 6 || !value.contains("@")) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const Gap(20),
                      // Phone Number Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Phone",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Gap(10),
                      TextFormField(
                        controller: loginController.phoneController,
                        autocorrect: true,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
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
                          isDense: false,
                          contentPadding: const EdgeInsets.all(15),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          hintText: "Enter Your Phone Number",
                          hintStyle: GoogleFonts.inter(
                            color: Colors.black54,
                          ),
                        ),
                        validator: (value) {
                          if (value!.length != 10) {
                            return "Please enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      const Gap(20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Choose your role",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const Gap(10),
                      const Row(
                        children: [
                          Expanded(child: RolesDropdown()),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(50),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // sign in logic
                          if (loginController.loginFormKey.currentState!
                              .validate()) {
                            await loginController.loginUser().then((_) {
                              if (loginController.isLoggedIn) {
                                Get.offNamed(myRoutes.homeRoute);
                              } else {
                                Get.showSnackbar(
                                  customGetSnackBar(
                                      "User not found", Icons.error),
                                );
                              }
                            });
                          } else {
                            Get.showSnackbar(
                              customGetSnackBar(
                                  "Please enter valid details", Icons.error),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text("Sign In",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(myRoutes.signUpRoute);
                        },
                        child: Text(
                          "Create one",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
