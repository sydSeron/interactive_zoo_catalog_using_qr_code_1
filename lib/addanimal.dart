import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qrcode_component/qr_code.dart';
import 'classes.dart';
import 'accessories.dart';

class AddAnimal extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  const AddAnimal({Key? key, required this.wallpaper}) : super(key: key);

  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

class _AddAnimalState extends State<AddAnimal> {
  @override

  //Add here
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

  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
    await Firebase.initializeApp(); // Initialize Firebase
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
      } else {
        return;
      }
    } catch (e) {
      print("Errors. $e");
    }
  }

  void submit() async {
    // Add here
    List<TextEditingController> conts = [nameCont, scinameCont, zookeepernameCont, feedingtimeCont, dietCont, behaviorCont, quantityCont, populationCont, conservestatusCont, naturalhabitatCont];
    List<TextEditingController> numConts = [quantityCont, populationCont];

    //Check for empty fields
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

    //Checks for numeric fields
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
      FirebaseStorage storage = FirebaseStorage.instance;

      //image
      File file = File(_image!.path);
      String url = "";
      try {
        String filePath = 'images/${DateTime.now()}.png';
        await storage.ref(filePath).putFile(file);
        url = await storage.ref(filePath).getDownloadURL();
      } catch (e) {
        print("Errors. $e");
      } finally {
        Navigator.of(context).pop();
        showOKDialog(context, "Your image has been uploaded successfully.", () {
          //Clears text fields
          setState(() {
            for (TextEditingController cont in conts) {
              cont.clear();
            }
            _image = null;
          });
        });
      }

      // Add here
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
        dateadded: DateTime.now()
      );

      // Store the animal details in Firestore
      // Add here
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

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('QR Code'),
          content: animal.qrcode != null
              ? Container(
              width: 200,
              height: 200,
              child: QRCodeComponent(
              qrData: animal.qrcode ?? '',
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          )
              : Text('No QR code available.'),
        ),
      );
    }
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