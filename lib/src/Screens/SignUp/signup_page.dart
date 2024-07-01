import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pci_app/Objects/data.dart';
import '../../../Functions/signup_user.dart';
import '../../Widgets/snackbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  Future<void> _signupFunction(BuildContext context) async {
    _nameFocusNode.unfocus();
    _phoneFocusNode.unfocus();
    _emailFocusNode.unfocus();
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> message = {};
      await signUp(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
      ).then((data) {
        message = data;
        debugPrint("Message From the server : ${message.toString()}");
      });
      if (context.mounted) {
        if (message.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar("Failed to Sign Up!"),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            customSnackBar("Signed Up Successfully!"),
          );
          Navigator.popAndPushNamed(
            context,
            myRoutes.loginRoute,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                    "Please Sign Up to Continue!",
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
                      focusNode: _nameFocusNode,
                      controller: _nameController,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        isDense: false,
                        contentPadding: EdgeInsets.all(15),
                        prefixIcon: Icon(Icons.perm_identity),
                        hintText: "Enter Your Name",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const Gap(10),
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
                        await _signupFunction(context);
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor:
                            const WidgetStatePropertyAll(Colors.blueAccent),
                      ),
                      child: Text(
                        "Sign Up",
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
            ],
          ),
        ),
      ),
    );
  }
}
