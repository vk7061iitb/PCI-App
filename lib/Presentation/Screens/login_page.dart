import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Functions/login_user.dart';
import 'package:pci_app/Objects/data.dart';
import 'package:pci_app/Presentation/Widget/snackbar.dart';
import '../../Objects/user_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              Gap(MediaQuery.of(context).size.height * 0.1),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Welcome Back Glad to see you, Again!",
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Gap(40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: _phoneFocusNode,
                      controller: _phoneController,
                      autocorrect: true,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        isDense: false,
                        contentPadding: EdgeInsets.all(15),
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Enter Your Phone Number",
                      ),
                      validator: (value) {
                        if (value!.length != 10) {
                          return "Please enter a valid phone number";
                        }
                        return null;
                      },
                    ),
                    const Gap(20),
                    TextFormField(
                      focusNode: _emailFocusNode,
                      controller: _emailController,
                      autocorrect: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        isDense: false,
                        contentPadding: EdgeInsets.all(15),
                        prefixIcon: Icon(Icons.mail_outline),
                        hintText: "Enter Your Email Address",
                      ),
                      validator: (value) {
                        if (value!.length < 6 || !value.contains("@")) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const Gap(20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _phoneFocusNode.unfocus();
                        _emailFocusNode.unfocus();
                        if (_formKey.currentState!.validate()) {
                          Map<String, dynamic> message = await loginUser(
                            UserData(
                                phoneNumber: _phoneController.text,
                                email: _emailController.text),
                          );
                          debugPrint(message.toString());
                          if (message['User_Id'] == 'null' || message.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(
                                  "User Not Found! Please Sign Up!",
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  myRoutes.homeRoute, (route) => false);
                              await localDatabase.deleteUserData();
                              await localDatabase.insertUserData(
                                UserData(
                                  userID: message['User_Id'].toString(),
                                  phoneNumber: _phoneController.text,
                                  email: _emailController.text,
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                customSnackBar(
                                  "Logged In Successfully!",
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor:
                            const WidgetStatePropertyAll(Colors.blueAccent),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      Navigator.pushNamed(context, myRoutes.signUpRoute);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "create one",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
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
    );
  }
}
