import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactive_zoo_catalog_using_qr_code/login_screen.dart';
import 'dart:math';

import 'qrScan.dart';
import 'credits.dart';

void main() => runApp(MaterialApp(
  home: Home(),
  debugShowCheckedModeBanner: false,
));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int countClicker = 0;
  String wallpaper = "";

  @override
  void initState() {
    super.initState();
    // List of possible wallpapers
    List<String> wallp = [
      'images/wallp1.jpg',
      'images/wallp2.jpg',
      'images/wallp3.jpg',
      'images/wallp4.jpg',
      'images/wallp5.jpg',
      'images/wallp6.jpg'
    ];
    final random = Random();
    int rand = random.nextInt(wallp.length);
    wallpaper = wallp[rand];
  }

  void clickedCount() {
    setState(() {
      countClicker++;
      if (countClicker == 7) {
        showWindow();
        countClicker = 0;
      }
    });
  }

  void showWindow() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => adminLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // To remove notification and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(wallpaper),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: clickedCount,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Zoo Catalogue',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 150.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  double totalPadding = 64.0;
                  double availableWidth = constraints.maxWidth - totalPadding;
                  double imageSize = availableWidth * 0.75;

                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Image(
                      image: AssetImage('images/qr-icon.png'),
                      width: imageSize,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> QRScanner()));
                    },
                    child: Text(
                      'SCAN QR',
                      style: TextStyle(fontSize: 30),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Credits(wallpaper: wallpaper)),
                );
              },
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 40,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}