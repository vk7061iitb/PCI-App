import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pciapp/firebase_options.dart';
import 'Objects/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/Presentation/About/about_app.dart';
import 'src/Presentation/Controllers/location_permission.dart';
import 'src/Presentation/Controllers/response_controller.dart';
import 'src/Presentation/Controllers/user_data_controller.dart';
import 'src/Presentation/Screens/HomePage/home_screen.dart';
import 'src/Presentation/Screens/UserProfile/user_page.dart';
import 'src/Presentation/Controllers/map_page_controller.dart';
import 'src/Presentation/Controllers/output_data_controller.dart';
import 'src/Presentation/Controllers/sensor_controller.dart';
import 'src/Presentation/Screens/Login/login_screen.dart';
import 'src/Presentation/Screens/SignUp/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // debugRepaintRainbowEnabled = true;
  // debugPaintSizeEnabled = false;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Get.lazyPut(() => LocationController(), fenix: true);
  Get.lazyPut(() => MapPageController(), fenix: true);
  Get.lazyPut(() => OutputDataController(), fenix: true);
  Get.lazyPut(() => ResponseController(), fenix: true);
  Get.lazyPut(() => AccDataController(), fenix: true);

  await GetStorage.init();
  await localDatabase.initDB();
  await localDatabase.initializeDirectory();
  final userDataController = UserDataController();
  final user = userDataController.storage.read('user');
  bool isLoggedIn = false;

  if (user != null) {
    isLoggedIn = user['isLoggedIn'] ?? false;
  }
  logger.i('Is Logged In: $isLoggedIn');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    MainApp(
      isLoggedIn: isLoggedIn,
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({required this.isLoggedIn, super.key});

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
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // showPerformanceOverlay: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: backgroundColor,
          textStyle: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
      supportedLocales: const [
        Locale('en', 'US'),
      ],
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
          page: () => UserPage(),
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
          name: myRoutes.abouApp,
          page: () => const AboutApp(),
        ),
      ],
    );
  }
}
