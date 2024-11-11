import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rewardrangerapp/helper_function/dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../helper_function/api_service.dart';
import '../helper_function/utility.dart';
import '../model/quote_motivation.dart';
import '../model/sign_up_model.dart';
import '../service_locator.dart';
import '../widget/drawer_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;
  int _score = 0; // Local score variable
  String? _firstName = '';
  bool? _isVerified;
  String? _lastname;
  late Timer _timer;
  double _currentIndex = 0;
  bool _firstAnimationComplete = false;
  bool _quoteAnimationStarted = false;
  String _currentQuote = '';
  bool _isAnimating = false;
  UserInfo? _userInfo;

  final ApiService _apiService = locator<ApiService>();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _currentIndex = Random().nextInt(quotes.length).toDouble();
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      _nextQuote();
    });
    _loadBannerAd();
    _loadRewardedAd();
    // Fetch user info after login

    // Initialize animation controller
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Initialize scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize color animation
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 255, 255, 255),
      end: const Color.fromARGB(255, 7, 230, 230),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller.forward();
  }

  void _toggleAnimation() {
    if (_isVerified == false) {
      _showAlertDialog('Please verify your email.');
      return; // Exit the function to avoid running the setState call
    }

    setState(() {
      _isAnimating = true;
    });

    // Play animation once and hide it after completion
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Verify'),
              onPressed: () {
                // Add your verify action here
                Navigator.of(context).pop();
                _verifyEmail();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyEmail() async {
    try {
      final result = await _apiService.verifyEmail();

      if (result['status'] == true) {
        setState(() {
          _isVerified = true;
        });
        // Show success snackbar only if the widget is still mounted
        if (mounted) {
          DialogUtil.showSuccessSnackbar(
              context, 'Verification Link has been sent to your email');
        }
      } else {
        // Show error snackbar only if the widget is still mounted
        if (mounted) {
          DialogUtil.showErrorSnackbar(context, 'Failed to verify email');
        }
      }
    } catch (e) {
      logger.e('Failed to verify email: $e');
      // Show error snackbar only if the widget is still mounted
      if (mounted) {
        DialogUtil.showErrorSnackbar(
            context, 'An error occurred while verifying email');
      }
    }
  }

  void _nextQuote() {
    setState(() {
      _currentIndex =
          Random().nextInt(quotes.length).toDouble(); // Get a random index
    });
  }

  void _previousQuote() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + quotes.length) % quotes.length;
    });
  }

  Future<void> _fetchUserInfo() async {
    try {
      UserInfo? userInfo = await _apiService.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _userInfo = userInfo;
          _score = userInfo
              .score; // Update the local score variable with the fetched score
          _firstName = userInfo.firstName;
          _isVerified = userInfo.isVerified;
          _lastname = userInfo.lastName;
        });
      }
    } catch (e) {
      logger.e('Failed to fetch user info: $e');
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Replace with your ad unit ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/5224354917', // Replace with your ad unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady) {
      _rewardedAd.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          logger.f('User earned reward: ${reward.amount} ${reward.type}');
          _updateScore(100); // Update score by 100 for the rewarded ad
        },
      );

      _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AdWithoutView ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (AdWithoutView ad, AdError error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );

      setState(() {
        _isRewardedAdReady = false;
      });
    } else {}
  }

  void _updateScore(int increment) {
    setState(() {
      _score += increment;
      _controller.reset();
      _controller.forward();
    });
    _postScoreToApi(increment); // Post the updated score to the API
  }

  void _handleReferAndEarn() {
    const increment1 = 500; // Increment for Refer & Earn
    _updateScore(increment1); // Add increment for Refer & Earn
  }

  Future<void> _postScoreToApi(int increment) async {
    try {
      final response = await _apiService.postScore(increment);
      if (response['status']) {
        logger.f('Score updated successfully: ${response['message']}');
      } else {
        throw Exception('Failed to update score: ${response['message']}');
      }
    } catch (e) {
      print('Error posting score: $e');
      // Handle error (e.g., show snackbar)
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd.dispose();
    _controller.dispose(); // Dispose the animation controller
    _timer.cancel();
    super.dispose();
  }

  // Inside the build method, modify the padding, text sizes, and button paddings:

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawerEdgeDragWidth: 100.0.w,
      drawer: DrawerScreen(
        firstName: _firstName ?? "",
        lastName: _lastname ?? "",
      ),
      drawerEnableOpenDragGesture: true,
      drawerScrimColor: Colors.black54,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(208, 6, 0, 42),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(223, 6, 0, 42),
        centerTitle: true,
        excludeHeaderSemantics: true,
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedTextKit(
                    isRepeatingAnimation: true,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Welcome, $_firstName!',
                        textStyle: TextStyle(
                          fontSize: 24.sp, // Reduced font size
                          fontWeight: FontWeight.bold,
                        ),
                        colors: const [
                          Color.fromARGB(255, 0, 234, 255),
                          Colors.blue,
                          Colors.green,
                          Colors.purple,
                          Colors.red,
                          Colors.deepPurple,
                        ],
                        speed: const Duration(milliseconds: 600),
                      ),
                    ],
                    repeatForever: true,
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    height: 50.h, // Reduced height
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 50.sp, // Reduced font size
                        fontFamily: 'Canterbury',
                        color: const Color.fromARGB(255, 0, 234, 255),
                      ),
                      child: AnimatedTextKit(
                        totalRepeatCount: 1,
                        isRepeatingAnimation: false,
                        animatedTexts: [
                          ScaleAnimatedText('Watch'),
                          ScaleAnimatedText('Earn'),
                          ScaleAnimatedText('Grow'),
                        ],
                        onFinished: () {
                          setState(() {
                            _firstAnimationComplete = true;
                          });
                        },
                      ),
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.paid_outlined,
                              color: _colorAnimation.value,
                              size: 30.sp, // Reduced size
                            ),
                            Text(
                              ' $_score',
                              style: TextStyle(
                                color: _colorAnimation.value,
                                fontSize: 30.sp, // Reduced font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 100.h), // Reduced spacing

                  Flexible(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 18.sp, // Reduced font size
                        fontFamily: 'Canterbury',
                      ),
                      child: AnimatedTextKit(
                        totalRepeatCount: 1,
                        isRepeatingAnimation: false,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            textAlign: TextAlign.center,
                            cursor: "  <",
                            curve: Curves.easeInOutCubic,
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 0, 234, 255),
                            ),
                            _quoteAnimationStarted
                                ? _currentQuote
                                : quotes[_currentIndex.toInt()],
                            speed: const Duration(milliseconds: 100),
                          ),
                        ],
                        onFinished: () {
                          setState(() {
                            _quoteAnimationStarted = true;
                            _currentQuote = quotes[_currentIndex.toInt()];
                          });
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  // SizedBox(height: 100.h), // Reduced height
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: _showRewardedAd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(20, 34, 74, 1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w, // Reduced horizontal padding
                          vertical: 6.h, // Reduced vertical padding
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Earn Coin',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp, // Reduced font size
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h), // Reduced spacing
                  ElevatedButton(
                    onPressed: _toggleAnimation,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: WidgetStateProperty.all(0),
                      padding: WidgetStateProperty.all(
                        EdgeInsets.only(bottom: 15.h), // Reduced padding
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.yellow, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.transparent,
                          width: 0,
                        ),
                      ),
                      child: Shimmer.fromColors(
                        period: const Duration(seconds: 2),
                        enabled: _score >= 600,
                        baseColor: const Color.fromARGB(255, 0, 43, 54),
                        highlightColor: const Color.fromARGB(255, 234, 234, 12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.2,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h), // Reduced vertical padding
                          alignment: Alignment.center,
                          child: Text(
                            'REDEEM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                              fontSize: 18.sp, // Reduced font size
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isBannerAdReady)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
            if (_isAnimating)
              Container(
                color: Colors.transparent.withOpacity(0.9),
                child: Center(
                  child: Lottie.asset('assets/animation/reward_animation.json'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
