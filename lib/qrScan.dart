import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_windows/camera_windows.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:zxing2/zxing2.dart';
import 'dart:typed_data';
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
  CameraController? cameraController;
  bool isCameraInitialized = false;
  FirebaseFirestore? firestore;
  late Image image;
  bool isConnected = true;

  String qrCode = "";

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    setupCamera();
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

  Future<void> setupCamera() async {
    try {
      // First check if cameraController exists, and dispose of it if so
      if (cameraController != null) {
        await cameraController!.dispose(); // Dispose of the previous controller
      }

      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Initialize a new camera controller
        cameraController = CameraController(cameras[0], ResolutionPreset.high);

        // Wait for the camera to initialize
        await cameraController!.initialize();

        // Start streaming images for QR code detection
        cameraController!.startImageStream((image) {
          // Process the frame for QR code detection here
          // Add your QR code detection logic
        });

        setState(() {
          isCameraInitialized = true;
        });
      } else {
        throw Exception('No cameras found.');
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }


  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<Animal> fetch(String code) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    //Returns null members if no match found
    showLoadingDialog(context, 'Fetching...');
    Animal animal = Animal();
    QuerySnapshot querySnapshot = await firestore!.collection('animals')
        .where('qrcode', isEqualTo: code)
        .get();

    if (querySnapshot.docs.isEmpty) {
      Navigator.pop(context);
      animal = Animal(name: '');
      return animal;
    }

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
    Navigator.pop(context);

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
    Animal? animal = await fetch(code);

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    if (animal.name == '') {
      showOKDialog(context, 'Error finding the animal.', () {
        Navigator.pop(context);
        setState(() {});
      });
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
                Container(
                  color: Colors.black,
                    child: isCameraInitialized
                        ? CameraPreview(cameraController!)
                        : Center(child: CircularProgressIndicator()),
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
}
