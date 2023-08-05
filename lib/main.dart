import 'package:color_gamut/color_coordinate_converter.dart';
import 'package:color_gamut/color_gamut_calculator.dart';
import 'package:color_gamut/informations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'
    show LicenseRegistry, LicenseEntryWithLineBreaks;

void main() {
  runApp(MyApp());
}

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

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

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
        return const AboutDialog(
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
