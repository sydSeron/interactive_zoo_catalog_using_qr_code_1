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

class Editanimal extends StatefulWidget {
  final String wallpaper;
  final Animal animal;
  const Editanimal({Key? key, required this.wallpaper, required this.animal}) : super(key: key);

  @override
  State<Editanimal> createState() => _EditanimalState();
}

class _EditanimalState extends State<Editanimal> {
  late final TextEditingController nameCont = TextEditingController(text: widget.animal.name);
  late final TextEditingController scinameCont = TextEditingController(text: widget.animal.sciname);
  late final TextEditingController zookeepernameCont = TextEditingController(text: widget.animal.zookeepername);
  late final TextEditingController feedingtimeCont = TextEditingController(text: widget.animal.feedingtime);
  late final TextEditingController dietCont = TextEditingController(text: widget.animal.diet);
  late final TextEditingController behaviorCont = TextEditingController(text: widget.animal.behavior);
  late final TextEditingController quantityCont = TextEditingController(text: widget.animal.quantity.toString());
  late final TextEditingController populationCont = TextEditingController(text: widget.animal.population.toString());
  late final TextEditingController conservestatusCont = TextEditingController(text: widget.animal.conservestatus);
  late final TextEditingController naturalhabitatCont = TextEditingController(text: widget.animal.naturalhabitat);

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

    String url = "";
    bool hasError = false;
    showLoadingDialog(context, 'Uploading...');
    if (_image?.path != null && _image!.path.isNotEmpty) {
      FirebaseStorage storage = FirebaseStorage.instance;
      File file = File(_image!.path);

      try {
        //Upload new photo
        String filePath = 'images/${DateTime.now()}.png';
        await storage.ref(filePath).putFile(file);
        url = await storage.ref(filePath).getDownloadURL();

        //Delete old photo
        String oldfile = linkToFileName(widget.animal.imageurl ?? '');
        Reference ref = storage.ref().child(oldfile);
        await ref.delete();

      } catch (e) {
        print("Error: $e");
        hasError = true;
      }
    }
    else {
      url = widget.animal.imageurl ?? '';
    }

    if (hasError) {
      return;
    }

    Navigator.of(context).pop();

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
      qrcode: widget.animal.qrcode,
    );

    // Query Firestore for documents where the field matches the value
    QuerySnapshot querySnapshot = (await firestore?.collection('animals')
        .where('qrcode', isEqualTo: animal.qrcode ?? '')
        .get()) as QuerySnapshot<Object?>;

    // Check if any documents match the query
    if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update({
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
        });
      }
      print("Animal(s) updated successfully.");
    } else {
      print("No animals found matching the criteria.");
    }

    showOKDialog(context, "Your changes saved successfully.", () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  Future<void> regenqr () async {
    showLoadingDialog(context, 'Generating QR Code...');

    await Future.delayed(Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.animal.qrcode != null)
                RepaintBoundary(
                  key: globalKey,
                  child: QRCodeComponent(
                    qrData: widget.animal.qrcode ?? '',
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
                if (widget.animal.qrcode != null)
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
                        final qrImageFile = File('${qrFolder.path}/${widget.animal.qrcode}.png');
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
                  Navigator.pop(context);
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

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.animal.name ?? '', style: TextStyle(color: Colors.white),),
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
                          ? Image.network(widget.animal.imageurl ?? '', height: 200, width: 200, fit: BoxFit.cover,) // Display the db's version image
                          : Image.file(
                        File(_image!.path), // Display the selected image
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
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
                      ElevatedButton(
                        onPressed: () {
                          regenqr();
                        },
                        child: Text('Regenerate QR Code', style: TextStyle(color: Colors.white),),
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
