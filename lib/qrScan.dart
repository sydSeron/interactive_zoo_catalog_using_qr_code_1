import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classes.dart';
import 'accessories.dart';
import 'viewer.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late final MobileScannerController cameraController;
  bool isScanning = false;
  FirebaseFirestore? firestore;

  late Image image;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    cameraController = MobileScannerController();
    startScanning();
    _checkConnection();
  }

  void initializeFirebase() async
  {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
    await Firebase.initializeApp(); // Initialize Firebase
    setState(() {
      firestore = FirebaseFirestore.instance;
    });
  }

  void startScanning() {
    cameraController.start();
    setState(() {
      isScanning = true;
    });
  }

  void stopScanning() {
    cameraController.stop();
    setState(() {
      isScanning = false;
    });
  }

  Future<Animal> fetch(String code) async {
    //Returns null members if no match found
    Animal animal = Animal();
    QuerySnapshot querySnapshot = await firestore!.collection('animals')
        .where('qrcode', isEqualTo: code)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      animal = Animal(
        //Dateadded missing, converted into string when uploaded to database, so dateAdded: ... not working
          name: querySnapshot.docs[0]['name'],
          sciname: querySnapshot.docs[0]['sciname'],
          zookeepername: querySnapshot.docs[0]['zookeepername'],
          feedingtime: querySnapshot.docs[0]['feedingtime'],
          diet: querySnapshot.docs[0]['diet'],
          behavior: querySnapshot.docs[0]['behavior'],
          quantity: querySnapshot.docs[0]['quantity'],
          population: querySnapshot.docs[0]['population'],
          conservestatus: querySnapshot.docs[0]['conservestatus'],
          naturalhabitat: querySnapshot.docs[0]['naturalhabitat'],
          imageurl: querySnapshot.docs[0]['imageurl'],
          qrcode: querySnapshot.docs[0]['qrcode'],
      );
    }

    image = Image.network(animal.imageurl ?? '');
    await _loadImage(image);

    return animal;
  }

  // Helper function to load image and wait for it to complete
  Future<void> _loadImage(Image image) async {
    final Completer<void> completer = Completer<void>();

    final ImageStreamListener listener = ImageStreamListener(
          (ImageInfo info, bool sync) {
        completer.complete(); // Image is loaded, complete the future
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception); // Handle loading error
      },
    );

    image.image.resolve(ImageConfiguration()).addListener(listener);
    await completer.future; // Wait until image is fully loaded
  }

  Future<void> onSubmit(String code) async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No Internet Connection')),
      );
      return;
    }
    showLoadingDialog(context, 'Fetching...');
    Animal animal = await fetch(code);
    Navigator.of(context).pop();

    if (animal.name == null) {
      Navigator.pop(context);
      showOKDialog(context, 'Error finding the animal.', () {setState((){});});
    }
    else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Viewer(animal: animal))
      );
    }
  }

  void _checkConnection() async {
    bool connectionStatus = await connectivityService.checkConnection();
    setState(() {
      isConnected = connectionStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Scan QR Code'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            stopScanning();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (barcode, arguments) {
                    if (barcode.rawValue != null) {
                      final String qrData = barcode.rawValue!;
                      stopScanning();
                      //Scanning success
                      //Checks if qr is valid in firebase
                      onSubmit(qrData);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to scan QR Code')),
                      );
                    }
                  },
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 2,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  //
}
