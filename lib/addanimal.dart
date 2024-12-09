import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qrcode_component/qr_code.dart';
import 'classes.dart';
import 'accessories.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

class AddAnimal extends StatefulWidget {
  // Wallpaper
  final String wallpaper;
  final String logged;
  const AddAnimal({Key? key, required this.wallpaper, required this.logged}) : super(key: key);


  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

class _AddAnimalState extends State<AddAnimal> {
  final TextEditingController nameCont = TextEditingController();
  final TextEditingController scinameCont = TextEditingController();
  final TextEditingController zookeepernameCont = TextEditingController();
  final TextEditingController feedingtimeCont = TextEditingController();
  final TextEditingController dietCont = TextEditingController();
  final TextEditingController behaviorCont = TextEditingController();
  final TextEditingController quantityCont = TextEditingController();
  final TextEditingController populationCont = TextEditingController();
  final TextEditingController conservestatusCont = TextEditingController();
  final TextEditingController naturalhabitatCont = TextEditingController();

  XFile? _image;
  FirebaseFirestore? firestore;
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    setState(() {
      firestore = FirebaseFirestore.instance;
    });
  }

  Future<void> _pickerImage() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void submit() async {
    bool isConnected = await connectivityService.checkConnection();

    if (!isConnected) {
      showOKDialog(context, 'No internet connection. Please try again', () {
        Navigator.pop(context);
      });
      return;
    }

    showLoadingDialog(context, 'Rechecking credentials...');
    isLoggedCorrectly(widget.logged).then((isCorrect) async {
      if (!isCorrect) {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOKDialog(context, 'Please login again.', () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      }
      else {
        Navigator.pop(context);
        List<TextEditingController> conts = [
          nameCont,
          scinameCont,
          zookeepernameCont,
          feedingtimeCont,
          dietCont,
          behaviorCont,
          quantityCont,
          populationCont,
          conservestatusCont,
          naturalhabitatCont
        ];
        List<TextEditingController> numConts = [quantityCont, populationCont];

        //Checking for empty fields
        for (TextEditingController cont in conts) {
          if (cont.text.trim().isEmpty) {
            showOKDialog(context, 'Some fields are empty.', () {
              for (TextEditingController cont1 in conts) {
                cont1.clear();
              }
            });
            return;
          }
        }

        //Checking for numeric fields
        for (TextEditingController cont in numConts) {
          if (int.tryParse(cont.text) == null && double.tryParse(cont.text) == null) {
            showOKDialog(context, 'Some fields require numeric data.', () {
              for (TextEditingController cont1 in numConts) {
                cont1.clear();
              }
            });
            return;
          }
        }

        if (_image != null) {
          showLoadingDialog(context, 'Uploading...');
          WidgetsFlutterBinding.ensureInitialized();
          await Firebase.initializeApp();
          FirebaseStorage storage = FirebaseStorage.instance;

          File file = File(_image!.path);
          String url = "";
          try {
            String filePath = 'images/${DateTime.now()}.png';
            await storage.ref(filePath).putFile(file);
            url = await storage.ref(filePath).getDownloadURL();
          } catch (e) {
            print("Error: $e");
            return;
          }

          Animal animal = Animal(
            name: nameCont.text,
            sciname: scinameCont.text,
            zookeepername: zookeepernameCont.text,
            feedingtime: feedingtimeCont.text,
            diet: dietCont.text,
            behavior: behaviorCont.text,
            quantity: int.tryParse(quantityCont.text),
            population: int.tryParse(populationCont.text),
            conservestatus: conservestatusCont.text,
            naturalhabitat: naturalhabitatCont.text,
            imageurl: url,
            qrcode: generateRandomString(20),
            dateadded: DateTime.now(),
          );

          await firestore?.collection('animals').add({
            'name': animal.name,
            'sciname': animal.sciname,
            'zookeepername': animal.zookeepername,
            'feedingtime': animal.feedingtime,
            'diet': animal.diet,
            'behavior': animal.behavior,
            'quantity': animal.quantity,
            'population': animal.population,
            'conservestatus': animal.conservestatus,
            'naturalhabitat': animal.naturalhabitat,
            'imageurl': animal.imageurl,
            'qrcode': animal.qrcode,
            'dateadded': animal.dateadded
          });
          Log log = Log(type: 'Animal', account: widget.logged, action: 'Add', name: animal.name, dateandtime: DateTime.now().toString());
          firestore?.collection('logs').add({
            'type': log.type,
            'account': log.account,
            'action': log.action,
            'name': log.name,
            'dateandtime': log.dateandtime
          });

          Navigator.pop(context);
          showLoadingDialog(context, 'Generating QR Code...');
          await Future.delayed(Duration(seconds: 1), () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('QR Code'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (animal.qrcode != null)
                      RepaintBoundary(
                        key: globalKey,
                        child: QRCodeComponent(
                          qrData: animal.qrcode ?? '',
                          color: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                      )
                    else
                      Text('No QR code available.'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (animal.qrcode != null)
                        var status = await Permission.storage.request();
                      var status = await Permission.manageExternalStorage.request();
                      try {
                        final boundary = globalKey.currentContext
                            ?.findRenderObject() as RenderRepaintBoundary?;
                        if (boundary != null) {
                          final image = await boundary.toImage(pixelRatio: 3.0);
                          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                          if (byteData != null) {
                            Directory? picturesDirectory = await getExternalStorageDirectory();
                            if (picturesDirectory != null) {
                              final qrFolder = Directory('/storage/emulated/0/Download');
                              if (!await qrFolder.exists()) {
                                await qrFolder.create(recursive: true);
                              }
                              final qrImageFile = File('${qrFolder.path}/${animal.qrcode}.png');
                              await qrImageFile.writeAsBytes(byteData.buffer.asUint8List());
                              showOKDialog(context, "QR code saved to ${qrImageFile.path}", () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              });
                            }
                          }
                        }
                      } catch (e) {
                        print("Error saving QR code: $e");
                        showOKDialog(context, "Failed to save QR code.", () {});
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          });
        }

        showOKDialog(context, "Your image has been uploaded successfully.", () {
          setState(() {
            for (TextEditingController cont in conts) {
              cont.clear();
            }
            _image = null;
          });
        });
          }
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
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
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _image == null
                          ? Text('No image selected.', style: TextStyle(color: Colors.white),)
                          : Image.file(
                        File(_image!.path), // Display the selected image
                        height: 200, // Set a fixed height or modify as needed
                        width: 200, // Set a fixed width or modify as needed
                        fit: BoxFit.cover, // Adjust the image's fit
                      ),
                      TextButton(
                        onPressed: () {
                          _pickerImage();
                        },
                        child: Text('UPLOAD', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoCondensed',
                        ),),
                      ),
                      Divider(height: 20,),
                      TextField(
                        controller: nameCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Animal Name',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: scinameCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Scientific Name',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: zookeepernameCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Zoo Keeper\'s Name',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: feedingtimeCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Feeding Times',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: dietCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Diet',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: behaviorCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Animal\'s Behavior',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: quantityCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Quantity in the Zoo',
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: 'Enter a number',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: populationCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Animal Population',
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: 'Enter a number',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: conservestatusCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Conservation Status',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: naturalhabitatCont,
                        maxLines: null,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Natural Habitat',
                            labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          submit();
                        },
                        child: Text('Submit', style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}