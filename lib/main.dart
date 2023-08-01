import 'package:color_gamut/color_coordinate_converter.dart';
import 'package:color_gamut/color_gamut_calculator.dart';
import 'package:color_gamut/informations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'
    show LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
        'ios': 'ca-app-pub-2310830332665506/7806370348',
        'android': 'ca-app-pub-2310830332665506/7806370348',
        //Todo: 광고단위 내 ID 확인필요(iOS, android)
      }
    : {
        'ios': 'ca-app-pub-3940256099942544/2934735716',
        'android': 'ca-app-pub-3940256099942544/6300978111',
      };

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Space',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

BannerAd? banner;

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TargetPlatform os = Theme.of(context).platform;
      // Load ads
      banner = BannerAd(
        adUnitId: UNIT_ID[os == TargetPlatform.iOS ? 'ios' : 'android']!,
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(),
      )..load();
    });

    final BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );
  }

  final List<Widget> _pages = [
    ColorSpacePage(),
    ColorCoordinateConverter(),
    Informations()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showSuggestionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이메일로 제안하기'),
          content: GestureDetector(
            onTap: () async {
              const mailtoLink = 'mailto:namseok.yoo@gmail.com';
              try {
                await launchUrl(Uri.parse(mailtoLink));
              } catch (e) {
                print('Could not launch $mailtoLink');
              }
            },
            child: Text(
              'namseok.yoo@gmail.com',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: 'Color Space',
          applicationVersion: '1.0.0',
          // Add any additional About information here
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Color Space'),
          actions: [
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'suggest') {
                  _showSuggestionPopup();
                } else if (value == 'about') {
                  _showAboutDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'suggest',
                  child: Text('제안하기'),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: Text('About'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _pages[_currentIndex]),
            Container(
                height: 50,
                child: banner != null ? AdWidget(ad: banner!) : Container()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Color Gamut',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.transform),
              label: 'Color Convert',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              label: 'Info',
            ),
          ],
        ),
      ),
    );
  }
}
