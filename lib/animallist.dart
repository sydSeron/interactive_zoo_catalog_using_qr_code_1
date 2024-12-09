import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'accessories.dart';
import 'editanimal.dart';
import 'classes.dart';

class Animallist extends StatefulWidget {
  final String wallpaper;
  final String logged;
  const Animallist({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<Animallist> createState() => _AnimallistState();
}

class _AnimallistState extends State<Animallist> {
  FirebaseFirestore? firestore;

  Future<List<Animal>> fetch() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    List<Animal> animals = [];
    QuerySnapshot querySnapshot = await firestore!.collection('animals').get();

    for (var doc in querySnapshot.docs) {
      animals.add(Animal(
        name: doc['name'],
        sciname: doc['sciname'],
        zookeepername: doc['zookeepername'],
        feedingtime: doc['feedingtime'],
        diet: doc['diet'],
        behavior: doc['behavior'],
        quantity: doc['quantity'],
        population: doc['population'],
        conservestatus: doc['conservestatus'],
        naturalhabitat: doc['naturalhabitat'],
        imageurl: doc['imageurl'],
        qrcode: doc['qrcode'],
      ));
    }

    return animals;
  }

  Future<void> delete(animal) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Are you sure you want to delete this? This is irreversible.'),
          actions: [
            TextButton(
              child: Text('YES'),
              onPressed: () async {
                showLoadingDialog(context, 'Rechecking credentials...');
                isLoggedCorrectly(widget.logged).then((isCorrect) async {
                  if (!isCorrect) {
                    Navigator.pop(context);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showOKDialog(context, 'Please login again.', () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    });
                  }
                  else {
                    Navigator.pop(context);
                    showLoadingDialog(context, 'Deleting...');

                    //For the image file
                    FirebaseStorage storage = FirebaseStorage.instance;
                    String oldfile = linkToFileName(animal.imageurl);
                    Reference ref = storage.ref().child(oldfile);

                    //For firebase
                    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                        .collection('animals')
                        .where('qrcode', isEqualTo: animal.qrcode)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      for (var doc in querySnapshot.docs) {
                        await doc.reference.delete();
                        await ref.delete();

                        Log log = Log(type: 'Animal', account: widget.logged, action: 'Delete', name: doc['name'], dateandtime: DateTime.now().toString());
                        firestore?.collection('logs').add({
                          'type': log.type,
                          'account': log.account,
                          'action': log.action,
                          'name': log.name,
                          'dateandtime': log.dateandtime
                        });

                        Navigator.pop(context);
                        showOKDialog(context, 'Successfully deleted.', () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      }
                    }
                  }
                });
              },
            ),
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  Widget animalCard(animal) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.9),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: NetworkImage(animal.imageurl),
                      height: 100,
                      width: 100,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(animal.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25
                          ),),
                        Text(animal.sciname,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontStyle: FontStyle.italic
                          ),),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Editanimal(wallpaper: widget.wallpaper, animal: animal, logged: widget.logged)));
                              },
                              child: Text('EDIT', style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'RobotoCondensed',
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                            Text(' | ', style: TextStyle(color: Colors.white),),
                            TextButton(
                              onPressed: () {
                                delete(animal);
                              },
                              child: Text('DELETE', style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'RobotoCondensed',
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

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

  @override
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
          FutureBuilder<List<Animal>>(
            future: fetch(),
            builder: (context, snapshot) {
              //Needed checker to avoid redscreen while loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              // Create a list of Animal cards
              List<Widget> animalCards = snapshot.data!.map((animal) {
                return animalCard(animal);
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  children: animalCards,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
