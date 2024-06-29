import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../helper_function/api_service.dart';
import '../helper_function/utility.dart';
import '../model/quote_motivation.dart';
import '../model/sign_up_model.dart';
import '../service_locator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;
  int _score = 0; // Local score variable
  String? _firstName = '';
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
    _currentIndex = Random().nextInt(quotes.length).toDouble();
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      _nextQuote();
    });
    _loadBannerAd();
    _loadRewardedAd();
    _fetchUserInfo(); // Fetch user info after login

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize scale animation
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Initialize color animation
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 255, 255, 255),
      end: const Color.fromARGB(255, 6, 183, 183),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller.forward();
  }

  void _toggleAnimation() {
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

  void _nextQuote() {
    setState(() {
      _currentIndex = Random().nextInt(quotes.length).toDouble(); // Get a random index
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
          _score = userInfo.score; // Update the local score variable with the fetched score
          _firstName = userInfo.firstName;
        });
      }
    } catch (e) {
      logger.e('Failed to fetch user info: $e');
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Replace with your ad unit ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
          print("Banner Ad Loaded");
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Replace with your ad unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('Rewarded Ad Loaded');
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
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
          print('Rewarded Ad dismissed');
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (AdWithoutView ad, AdError error) {
          print('Rewarded Ad failed to show: $error');
          ad.dispose();
          _loadRewardedAd();
        },
      );

      setState(() {
        _isRewardedAdReady = false;
      });
    } else {
      print('Rewarded Ad is not ready yet');
    }
  }

  void _updateScore(int increment) {
    setState(() {
      _score += increment;
      _controller.reset();
      _controller.forward();
    });
    _postScoreToApi(_score); // Post the updated score to the API
  }

  void _handleReferAndEarn() {
    const increment1 = 500; // Increment for Refer & Earn
    _updateScore(increment1); // Add increment for Refer & Earn
  }

  Future<void> _postScoreToApi(int score) async {
    try {
      final response = await _apiService.postScore(score);
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

  @override
  Widget build(BuildContext context) {
    logger.w('$_firstName');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      // appBar: AppBar(
      //   backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      //   centerTitle: true,
      //   title: Text(
      //     'Welcome, $_firstName!',
      //     style: const TextStyle(color: Color.fromARGB(255, 0, 234, 255)),
      //   ),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 9, 81, 115), // start with black
              Color.fromARGB(255, 57, 106, 252), // blue-ish
              Color.fromARGB(255, 154, 17, 255), // purple-ish
              Colors.red, // red
            ],
            stops: [0.0, 0.3, 0.6, 1.0], // begin with black and end with the blue-ish
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 70,
                    ),
                    AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'Welcome, $_firstName!',
                          textStyle: const TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            const Color.fromARGB(255, 0, 234, 255),
                            Colors.blue,
                            Colors.green,
                            Colors.purple,
                            Colors.red,
                          ],
                          speed: const Duration(milliseconds: 500), // Adjust duration here
                        ),
                      ],
                      repeatForever: true,
                    ),

                    SizedBox(
                      height: 100.0, // The height of the AnimatedTextKit widget
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 70.0,
                          fontFamily: 'Canterbury',
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            ScaleAnimatedText('Watch'),
                            ScaleAnimatedText('Earn'),
                            ScaleAnimatedText('Grow'),
                          ],
                          displayFullTextOnTap: true,
                          onFinished: () {
                            setState(() {
                              _firstAnimationComplete = true;
                            });
                          },
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),

                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Text(
                            'Score: $_score',
                            style: TextStyle(color: _colorAnimation.value, fontSize: 24),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(height: 50.0),
                    SizedBox(
                      height: 100.0, // The height of the AnimatedTextKit widget
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontFamily: 'Canterbury',
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              textStyle: const TextStyle(color: Color.fromARGB(255, 0, 234, 255)),
                              _quoteAnimationStarted
                                  ? _currentQuote
                                  : quotes[_currentIndex.toInt()],
                              speed: const Duration(milliseconds: 100), // Adjust speed here
                            ),
                          ],
                          onFinished: () {
                            setState(() {
                              _quoteAnimationStarted = true;
                              _currentQuote = quotes[_currentIndex.toInt()]; // Update current quote
                            });
                          },
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                    ), // Display the current score
                    const Spacer(),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: _showRewardedAd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 132, 228, 16), // Background color
                          minimumSize: const Size(200, 50), // Width and height
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8), // Horizontal padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Earn Coin',
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _toggleAnimation,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        elevation: WidgetStateProperty.all(0),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.only(
                            bottom: 20,
                          ),
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
                            width: 2,
                          ),
                        ),
                        child: Shimmer.fromColors(
                          baseColor: const Color.fromARGB(255, 0, 0, 0),
                          highlightColor: const Color.fromARGB(255, 219, 219, 101),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    Colors.transparent, // Set to transparent to avoid double border
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: const Text(
                              'REDEEM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: _handleReferAndEarn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 14, 134, 164), // Background color
                          minimumSize: const Size(200, 50), // Width and height
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          // Horizontal padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Refer & Earn',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                ),
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
                color: Colors.transparent.withOpacity(0.9), // Adjust opacity here (0.0 - 1.0)
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
