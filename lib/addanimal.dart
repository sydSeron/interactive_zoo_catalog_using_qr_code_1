import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final TextEditingController populationCont = TextEditingController();

  XFile? _image;

  FirebaseFirestore? firestore;

  void initState()
  {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async
  {
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
      }
      else return;
    } catch (e) {
      print("Errors. $e");
    }
  }

  void submit() async
  {
    // Add here
    List<TextEditingController> conts = [nameCont, populationCont];
    List<TextEditingController> numConts = [populationCont];

    //Check for empty fields
    for (TextEditingController cont in conts) {
      if (cont.text.trim().isEmpty) {
        showOKDialog(context, 'Some fields are empty.', (){
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
        showOKDialog(context, 'Some fields require numeric data.', (){
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
          setState(() {
            nameCont.clear();
            populationCont.clear();
            _image = null;
          });
        });
      }

      // Add here
      Animal animal = Animal(
        name: nameCont.text,
        population: int.tryParse(populationCont.text),
        imageurl: url,
        qrcode: generateRandomString(20),
      );

      // Store the animal details in Firestore
      // Add here
      await firestore?.collection('animals').add({
        'name': animal.name,
        'population': animal.population,
        'imageurl': animal.imageurl,
        'qrcode': animal.qrcode
      });

      showOKDialog(context, animal.qrcode ?? 'QR Failed', (){});
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
                        decoration: InputDecoration(
                          labelText: 'Animal Name',
                          labelStyle: TextStyle(color: Colors.white)
                        ),
                      ),
                      TextField(
                        controller: populationCont,
                        decoration: InputDecoration(
                          labelText: 'Animal Population',
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: 'Enter a number',
                        ),
                        keyboardType: TextInputType.number,
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
