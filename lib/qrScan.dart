import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:zxing2/zxing2.dart';
import 'package:zxing2/qrcode.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classes.dart';
import 'accessories.dart';
import 'viewer.dart';

class QRScanner extends StatefulWidget {
  @override
  final String wallpaper;
  const QRScanner({Key? key, required this.wallpaper}) : super(key: key);

  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  FirebaseFirestore? firestore;
  bool isConnected = true;

  final ImagePicker _picker = ImagePicker();
  File? _storedImage;
  String? path;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
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

  // Function to pick an image and save it
  Future<void> pickAndSaveImage() async {
    try {
      // Let the user pick an image from their gallery
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Get the directory where the app can store files on Windows
        final Directory appDir = await getApplicationSupportDirectory();

        // Define a subfolder named "uploaded_images"
        final Directory imagesDir = Directory('${appDir.path}\\uploaded_images');
        if (!imagesDir.existsSync()) {
          await imagesDir.create(recursive: true); // Create folder if it doesn't exist
        }

        // Create a unique file name in the subfolder
        final File imageFile = File(pickedFile.path);
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
        final String savedPath = '${imagesDir.path}\\$fileName';
        path = savedPath;

        //Delete previous pics to save space
        for (var file in imagesDir.listSync()) {
          if (file is File) {
            file.deleteSync(); // Delete the file
          }
        }

        // Copy the selected image to the subfolder
        final File savedImage = await imageFile.copy(savedPath);

        setState(() {
          _storedImage = savedImage; // Update UI with the saved image
        });

        print('Image saved at: $savedPath');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking and saving image: $e');
    }
  }

  String? qrToString(String path) {
    try {
      var image = img.decodePng(File(path).readAsBytesSync())!;

      LuminanceSource source = RGBLuminanceSource(
          image.width,
          image.height,
          image
              .convert(numChannels: 4)
              .getBytes(order: img.ChannelOrder.abgr)
              .buffer
              .asInt32List());
      var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

      var reader = QRCodeReader();
      var result = reader.decode(bitmap);

      return result.text; // Return the QR code text
    } catch (e) {
      print('Error decoding QR code: $e');
      return null; // Return null if decoding fails
    }
  }

  void conv() {
    if (path == null) {
      showOKDialog(context, "No image uploaded, or no QR in the image.", (){});
      return;
    }
    var res = qrToString(path!);
    if (res == null) {
      showOKDialog(context, "No image uploaded, or no QR in the image.", (){});
    } else {
      onSubmit(res.toString());
    }
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

    var images = Image.network(animal.imageurl ?? '');
    await _loadImage(images);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.wallpaper),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            SafeArea(
              child: Column(
                children: [
                  _storedImage != null
                      ? Image.file(
                    _storedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                    : Column(
                    children: [
                      Image.asset(
                        'images/qr-icon.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20,),
                      Text('No image selected.', style: TextStyle(color: Colors.white),)
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      pickAndSaveImage();
                    },
                    child: Text('Upload Image', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () {
                      conv();
                    },
                    child: Text('Scan', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
