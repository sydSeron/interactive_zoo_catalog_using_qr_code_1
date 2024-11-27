import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactive_zoo_catalog_using_qr_code/login_screen.dart'; // import AdminLogin or whichever screen
import 'dart:math';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'accessories.dart'; // Import connectivity service

import 'qrScan.dart';
import 'credits.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int countClicker = 0;
  String wallpaper = "";
  bool isConnected = true;
  bool Connectionbanner = true;

  @override
  void initState() {
    super.initState();

    // Set a random wallpaper
    List<String> wallp = [
      'images/wallp1.jpg',
      'images/wallp2.jpg',
      'images/wallp3.jpg',
      'images/wallp4.jpg',
      'images/wallp5.jpg',
      'images/wallp6.jpg'
    ];
    final random = Random();
    wallpaper = wallp[random.nextInt(wallp.length)];

    connectivityService.connectionStatusStream.listen((status) {
      setState(() {
        isConnected = status;
        if (isConnected) {
          Connectionbanner = true;
          Future.delayed(Duration(seconds: 5), () {
            setState(() {
              Connectionbanner = false;
            });
          });
        }
        else {
          Future.delayed(Duration(seconds: 5), () {
            setState(() {
              Connectionbanner = true;
            });
          });
        }
      });
    });


    _checkInitialConnection();
  }

  void _checkInitialConnection() async {
    bool status = await connectivityService.checkConnection();
    setState(() {
      isConnected = status;
      if (isConnected) {
        Connectionbanner = true;
        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            Connectionbanner = false;
          });
        });
      }
      else {
        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            Connectionbanner = true;
          });
        });
      }
    });
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
          // Wallpaper background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(wallpaper),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (Connectionbanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: isConnected ? Colors.green : Colors.red,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  isConnected ? "Connected to the Internet" : "No Internet Connection",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => QRScanner()));
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
