import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helper_function/api_service.dart';
import '../helper_function/utility.dart';
import '../service_locator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;
  int _score = 0; // Local score variable
  String _firstName = '';

  final ApiService _apiService = locator<ApiService>();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadRewardedAd();
    _fetchUserInfo(); // Fetch user info after login
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
          _updateScore();
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

  void _updateScore() {
    setState(() {
      _score += 10;
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('Building DashboardScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Content goes here'),
                Text('Welcome, $_firstName!'), // Display the first name
                Text('Score: $_score'), // Display the current score
                ElevatedButton(
                  onPressed: _showRewardedAd,
                  child: const Text('Update Score'),
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
