import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

import 'package:interactive_zoo_catalog_using_qr_code/qrScan.dart';

void main() => runApp(MaterialApp(
  home: Home(),
  debugShowCheckedModeBanner: false,
));

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //To remove notification and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    //List of possible wallpapers. To add, add asset to image folder, mention in pubspec, then add the name here
    List<String> wallp = ['images/wallp1.jpg', 'images/wallp2.jpg', 'images/wallp3.jpg', 'images/wallp4.jpg', 'images/wallp5.jpg', 'images/wallp6.jpg'];
    final random = Random();
    int rand = random.nextInt(wallp.length);

    //Image will change twice on hot reloads, this error is just on hot reload, and will work as expected when app is published
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(wallp[rand]),
                fit: BoxFit.cover
              )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double totalPadding = 64.0;
                  double availableWidth = constraints.maxWidth - totalPadding;
                  double imageSize = availableWidth * 0.75;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
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
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.1),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero
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
              onPressed: () {},
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 40,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            )
          ),
        ]
      ),
    );
  }
  //emman
  //rolan
}
