import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'Objects/data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pci_app/firebase_options.dart';
import 'Functions/init_download_folder.dart';
import 'src/Presentation/Controllers/location_permission.dart';
import 'src/Presentation/Controllers/user_data_controller.dart';
import 'src/Presentation/Screens/UnsedData/unsend_data.dart';
import 'src/Presentation/Screens/UserProfile/user_page.dart';
import 'src/Presentation/Controllers/map_page_controller.dart';
import 'src/Presentation/Controllers/output_data_controller.dart';
import 'src/Presentation/Controllers/sensor_controller.dart';
import 'package:pci_app/src/Presentation/Screens/HomePage/home_screen.dart';
import 'src/Presentation/Screens/Login/login_screen.dart';
import 'src/Presentation/Screens/SignUp/signup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  Get.lazyPut(() => LocationController());
  Get.lazyPut(() => AccDataController());
  Get.lazyPut(() => MapPageController());
  Get.lazyPut(() => UserDataController());
  Get.lazyPut(() => OutputDataController());

  await GetStorage.init();
  await localDatabase.initDB();
  await initializeDirectory();

  final userDataController = Get.find<UserDataController>();
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

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFF3EDF5),
          systemNavigationBarColor: Color(0xFFF3EDF5),
          systemNavigationBarIconBrightness: Brightness.dark),
    );
    return GetMaterialApp(
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
          name: myRoutes.unsentDataRoute,
          page: () => const UnsendData(),
        )
      ],
    );
  }
}
