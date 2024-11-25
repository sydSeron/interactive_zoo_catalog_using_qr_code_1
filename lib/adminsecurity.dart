import 'package:flutter/material.dart';
import 'classes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'accessories.dart';

class Adminsecurity extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  final String logged;
  const Adminsecurity({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<Adminsecurity> createState() => _AdminsecurityState();
}

class _AdminsecurityState extends State<Adminsecurity> {
  FirebaseFirestore? firestore;

  Future<List<Log>> fetch() async {
    List<Log> logs = [];
    QuerySnapshot querySnapshot = await firestore!.collection('logs').orderBy('dateandtime', descending: true).get();

    for (var doc in querySnapshot.docs) {
      logs.add(Log(
        type: doc['type'],
        account: doc['account'],
        action: doc['action'],
        name: doc['name'],
        dateandtime: doc['dateandtime']
      ));
    }

    return logs;
  }

  Widget logCard (log) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Container(
                color: Colors.black.withOpacity(0.9),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIME AND DATE: ${log.dateandtime}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'RobotoCondensed',
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Type: ${log.type}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),
                  ),
                  Text(
                    '${log.type} Name: ${log.name}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    ),
                  ),
                  Text(
                    'Action: ${log.action}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    ),
                  ),
                  Text(
                    'Made By: ${log.account}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
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
        title: Text('Security Logs', style: TextStyle(color: Colors.white),),
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
          FutureBuilder<List<Log>>(
            future: fetch(),
            builder: (context, snapshot) {
              //Needed checker to avoid redscreen while loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              // Create a list of Animal cards
              List<Widget> logCards = snapshot.data!.map((animal) {
                return logCard(animal);
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  children: logCards,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
