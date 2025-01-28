import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interactive_zoo_catalog_using_qr_code/classes.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'accessories.dart';
import 'qrScan.dart';
import 'credits.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCuK-iRFEdEns1uZACuhvBej3-7lMUY_BE",
        authDomain: "trials-b0b95.firebaseapp.com",
        projectId: "trials-b0b95",
        storageBucket: "trials-b0b95.appspot.com",
        messagingSenderId: "1682898445",
        appId: "1:1682898445:web:fc8582a9a7fc78885e9f44",
        measurementId: "G-5TE4GJX0JL",
      ),
    );
  } else {
    await Firebase.initializeApp(); // Default for mobile
  }

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
    initialize(); // Call the async initialization method

    // Wallpaper setup
    List<String> wallp = [
      'images/wallp1.jpg',
      'images/wallp2.jpg',
      'images/wallp3.jpg',
      'images/wallp4.jpg',
      'images/wallp5.jpg',
      'images/wallp6.jpg',
    ];
    final random = Random();
    wallpaper = wallp[random.nextInt(wallp.length)];

    // Connection status listener
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
        } else {
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

  Future<void> initialize() async {
    await initializeFirebase(); // Async Firebase initialization
    await checkOrCreateUniqueIdFile(); // Async file operation
  }

  Future<void> initializeFirebase() async { // Changed from void to Future<void>
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(); // Initialize Firebase
    setState(() {
      firestore = FirebaseFirestore.instance;
    });
  }

  Future<void> checkOrCreateUniqueIdFile() async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission is required to proceed.");
        return;
      }

      // Get the Downloads directory
      final Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      if (downloadsDir == null || !downloadsDir.existsSync()) {
        print("Downloads folder not found!");
        return;
      }

      // Define the file path
      final String filePath = '${downloadsDir.path}/MZQRID_unique_regis.txt';

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
