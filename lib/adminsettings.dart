import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'adminadd.dart';
import 'accessories.dart';
import 'classes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Adminsettings extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  final String logged;
  const Adminsettings({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<Adminsettings> createState() => _AdminsettingsState();
}

class _AdminsettingsState extends State<Adminsettings> {
  FirebaseFirestore? firestore;

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

  void delete(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Are you sure you want to delete this? This is irreversible.'),
            actions: [
              TextButton(
                child: Text('YES'),
                onPressed: () async {
                    //Delete
                    showLoadingDialog(context, 'Deleting...');
                    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('username', isEqualTo: widget.logged)
                        .get();
                    if (querySnapshot.docs.isNotEmpty) {
                      for (var doc in querySnapshot.docs) {
                        await doc.reference.delete();
                      }

                      //Record in logs
                      Log log = Log(type: 'Account', account: widget.logged, action: 'Delete', name: widget.logged, dateandtime: DateTime.now().toString());
                      firestore?.collection('logs').add({
                        'type': log.type,
                        'account': log.account,
                        'action': log.action,
                        'name': log.name,
                        'dataandtime': log.dateandtime
                      });

                      Navigator.pop(context); // Close the loading dialog
                      showOKDialog(context, 'Successfully deleted account.', () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Account Settings', style: TextStyle(color: Colors.white),),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 10,),
                            Text('Change Password')
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Adminadd(wallpaper: widget.wallpaper, logged: widget.logged,)));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 10,),
                            Text('Add Account')
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          delete(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 10,),
                            Text('Delete Account')
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history),
                            SizedBox(width: 10,),
                            Text('See Logs')
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ]
      )
    );
  }
}
