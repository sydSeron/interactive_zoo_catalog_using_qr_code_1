import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart';
import 'accessories.dart'; // Import connectivity service
import 'qrScan.dart';
import 'credits.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'classes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  FirebaseFirestore? firestore;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    checkOrCreateUniqueIdFile();

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

  void initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    setState(() {
      firestore = FirebaseFirestore.instance;
    });
  }

  Future<void> checkOrCreateUniqueIdFile() async {
    try {
      // Get the desktop directory from USERPROFILE
      final String userProfile = Platform.environment['USERPROFILE']!;
      final String desktopDir = path.join(userProfile, 'Documents');

      // Ensure the desktop directory exists (for safety)
      final Directory docuDirectory = Directory(desktopDir);
      if (!docuDirectory.existsSync()) {
        throw Exception("Desktop directory not found.");
      }

      // Define the file path
      final String filePath = '${docuDirectory.path}/MZQRID_unique_regis.txt';

      // Check if the file exists
      final File file = File(filePath);
      if (file.existsSync()) {
        print("File already exists: ${file.path}");
        // Read the content if needed
        final content = await file.readAsString();
        print("File Content: $content");
      } else {
        // File doesn't exist, create it and write a unique ID
        String random = generateRandomString(20);
        String uniqueId = "MZQRID_${random}";
        await file.writeAsString(uniqueId);
        print("Unique ID file created at: ${file.path}");

        Visitor visitor = Visitor(id: uniqueId);
        await firestore?.collection('visitors').add({
          'userId': visitor.id,
          'day': visitor.day,
          'month': visitor.month,
          'year': visitor.year,
        });
      }
    } catch (e) {
      print("An error occurred: $e");
    }
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
              Text(
                'MZQR',
                style: TextStyle(
                  fontSize: 60,
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
              Text(
                'Manila Zoo Interactive QR Catalog',
                style: TextStyle(
                  fontSize: 20,
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
              SizedBox(height: 80.0),
              LayoutBuilder(
                builder: (context, constraints) {
                  double totalPadding = 64.0;
                  double availableWidth = constraints.maxWidth - totalPadding;
                  double imageSize = min(availableWidth * 0.75, 200.0); // Set a max size

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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => QRScanner(wallpaper: wallpaper,)));
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
