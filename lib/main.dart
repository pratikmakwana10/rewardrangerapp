import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rewardrangerapp/screen/dashboard_screen.dart';
import 'package:rewardrangerapp/screen/logIn_screen.dart';
import 'package:rewardrangerapp/screen/signup_screen.dart';
import 'package:rewardrangerapp/service_locator.dart';
import 'package:rewardrangerapp/helper_function/security_service.dart';
import 'package:rewardrangerapp/firebase_options.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetIt for service locator
  GetIt.instance.registerLazySingleton(() => SecurityService());

  // Initialize Google Mobile Ads
  MobileAds.instance.initialize();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SecurityService _securityService;

  @override
  void initState() {
    super.initState();
    _securityService = GetIt.instance<SecurityService>();
    _securityService.startSecurityCheck(context);
  }

  @override
  void dispose() {
    _securityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 64, 114, 252)),
      useMaterial3: true,
    );

    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 14, 211, 237),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'Reward Ranger App',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.dark,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final bool isLoggedIn = snapshot.data ?? false;
          return MaterialApp(
              title: 'Reward Ranger App',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeMode.dark,
              home:
                  //  isLoggedIn ?
                  const SignUpPage()
              // : const Login(),
              );
        }
      },
    );
  }

  Future<bool> _isUserLoggedIn() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    return token != null;
  }
}
