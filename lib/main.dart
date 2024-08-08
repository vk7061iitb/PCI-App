import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pci_app/src/Models/user_data.dart';
import 'package:pci_app/src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/HomePage/home_screen.dart';
import 'package:pci_app/src/Presentation/Screens/Login/login_screen.dart';
import 'package:pci_app/src/Presentation/Screens/SignUp/signup_screen.dart';
import 'Objects/data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pci_app/firebase_options.dart';
import 'Functions/init_download_folder.dart';
import 'Functions/request_storage_permission.dart';
import 'src/Presentation/Controllers/location_permission.dart';
import 'src/Presentation/Screens/UnsedData/unsend_data.dart';
import 'src/Presentation/Screens/UserProfile/user_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => LocationController());
  Get.lazyPut(() => AccDataController());
  await localDatabase.initDB();
  await initializeDirectory();
  bool isLoggedIn = await localDatabase.queryUserData().then(
    (user) {
      if (user.userID == 'null') {
        return false;
      } else {
        return true;
      }
    },
  );
  debugPrint('Is Logged In: $isLoggedIn');
  UserData currentUser = await localDatabase.queryUserData();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(
    MainApp(
      isLoggedIn: isLoggedIn,
      currentUser: currentUser,
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp(
      {required this.currentUser, required this.isLoggedIn, super.key});

  final UserData currentUser;
  final bool isLoggedIn;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    checkPermission();
  }

  void checkPermission() async {
    await requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF3EDF5),
          systemNavigationBarColor: Color(0xFFF3EDF5),
          systemNavigationBarIconBrightness: Brightness.dark),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:
          widget.isLoggedIn ? myRoutes.homeRoute : myRoutes.loginRoute,
      getPages: [
        GetPage(
          name: myRoutes.homeRoute,
          page: () => HomeScreen(),
        ),
        GetPage(
          name: myRoutes.userProfileRoute,
          page: () => UserPage(user: widget.currentUser),
        ),
        GetPage(
          name: myRoutes.loginRoute,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: myRoutes.signUpRoute,
          page: () => const SignupScreen(),
        ),
        GetPage(
          name: myRoutes.unsentDataRoute,
          page: () => const UnsendData(),
        )
      ],
    );
  }
}
