import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rewardrangerapp/helper_function/theme.dart';
import 'package:rewardrangerapp/helper_function/utility.dart';
import 'package:rewardrangerapp/service_locator.dart';
import 'package:rewardrangerapp/screen/signup_option.dart';
import 'package:rewardrangerapp/screen/dashboard_screen.dart'; // Add the Dashboard screen import
import 'package:rewardrangerapp/helper_function/security_service.dart';
import 'package:rewardrangerapp/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _securityService = GetIt.instance<SecurityService>();
    _securityService.startSecurityCheck(context);
    _checkInternetConnection();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = (result != ConnectivityResult.none);
      });
    });
  }

  void _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _isOnline = (connectivityResult != ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _securityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        print('Connection State: ${snapshot.connectionState}');
        print('Is Logged In: ${snapshot.data}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'Reward Ranger App',
            theme: ThemeData(
              colorSchemeSeed: Colors.black,
            ),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          final bool isLoggedIn = snapshot.data ?? false;
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Reward Ranger',
                theme: darkTheme,
                themeMode: ThemeMode.dark,
                home: _isOnline
                    ? (isLoggedIn
                        ? const DashboardScreen()
                        : const SignUpOptionsScreen())
                    : _buildNoInternetScreen(),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildNoInternetScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no-internet.svg',
              width: 200.w, // Using ScreenUtil for responsive sizing
            ),
            SizedBox(height: 20.h),
            Text(
              'No internet connection',
              style: TextStyle(fontSize: 18.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      logger.f('Token retrieved: $token');
      return token != null;
    } catch (e) {
      logger.e('Error retrieving token: $e');
      return false;
    }
  }
}
