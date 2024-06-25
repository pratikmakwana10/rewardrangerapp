import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:audioplayers/audioplayers.dart'; // Import the audioplayers package
import '../helper_function/api_service.dart';
import '../helper_function/utility.dart';
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
  String _firstName = '';

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  final ApiService _apiService = locator<ApiService>();

  @override
  void initState() {
    super.initState();
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
            end: const Color.fromARGB(255, 6, 183, 183))
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller.forward();
  }

  void _fetchUserInfo() async {
    try {
      final userData = await _apiService.getUserInfo();
      setState(() {
        _firstName = userData['first_name'];
        _score = userData['score'];
      });
    } catch (e) {
      logger.e('Error fetching user info: $e');
      // Handle error (e.g., show snackbar)
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
          logger.i("Banner Ad Loaded");
        },
        onAdFailedToLoad: (ad, error) {
          logger.e('BannerAd failed to load: $error');
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
          logger.i('Rewarded Ad Loaded');
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          logger.e('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady) {
      _rewardedAd.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          logger.i('User earned reward: ${reward.amount} ${reward.type}');
          _updateScore(100); // Update score by 100 for refer & earn
        },
      );

      _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AdWithoutView ad) {
          logger.i('Rewarded Ad dismissed');
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (AdWithoutView ad, AdError error) {
          logger.e('Rewarded Ad failed to show: $error');
          ad.dispose();
          _loadRewardedAd();
        },
      );

      setState(() {
        _isRewardedAdReady = false;
      });
    } else {
      logger.e('Rewarded Ad is not ready yet');
    }
  }

  void _updateScore(int increment) {
    setState(() {
      _score += increment;
    });
  }

  void _handleReferAndEarn() {
    const increment1 = 500; // Increment for Refer & Earn
    setState(() {
      _score += increment1; // Add increment for Refer & Earn
    });
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('audio/boom_audio.mp3'));
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd.dispose();
    _audioPlayer.dispose(); // Dispose the audio player
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Building DashboardScreen');

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
        title: Text(
          'Welcome, $_firstName!',
          style: const TextStyle(color: Color.fromARGB(255, 0, 234, 255)),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100.0, // The height of the AnimatedTextKit widget
                  child: Center(
                    child: SizedBox(
                      width: 250.0,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 70.0,
                          fontFamily: 'Canterbury',
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          animatedTexts: [
                            ScaleAnimatedText(' Watch'),
                            ScaleAnimatedText('  Earn'),
                            ScaleAnimatedText('  Grow'),
                          ],
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
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
                ), // Display the current score
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: _showRewardedAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 21, 23, 182), // Background color
                      minimumSize: const Size(200, 50), // Width and height
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // Horizontal padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        // Rounded corners
                      ),
                    ),
                    child: const Text(
                      'Update Score',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: _handleReferAndEarn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 110, 32, 227), // Background color
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
                const Spacer(),
                ElevatedButton(
                  onPressed: _playSound, // Play sound on button tap
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    elevation: WidgetStateProperty.all(0),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.only(
                        bottom: 60,
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
                        color: const Color.fromARGB(255, 247, 219, 34),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: const Text(
                        'Redeem',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}
