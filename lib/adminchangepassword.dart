import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'classes.dart';
import 'package:bcrypt/bcrypt.dart';
import 'accessories.dart';

class Adminchangepassword extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  final String logged;
  const Adminchangepassword({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<Adminchangepassword> createState() => _AdminchangepasswordState();
}

class _AdminchangepasswordState extends State<Adminchangepassword> {
  @override
  final TextEditingController oldpCont = TextEditingController();
  final TextEditingController newpCont = TextEditingController();
  final TextEditingController newp2Cont = TextEditingController();

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

  void submit() async {
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
        //Checks for empty strings
        if (oldpCont.text == null || newpCont.text == null || newp2Cont.text == null) {
          showOKDialog(context, 'Some fields are empty.', () {});
          return;
        }
        if (oldpCont.text.isEmpty || newpCont.text.isEmpty || newp2Cont.text.isEmpty) {
          showOKDialog(context, 'Some fields are empty.', () {});
          return;
        }
        //Check for password mismatch
        if (newpCont.text != newp2Cont.text) {
          showOKDialog(context, 'The passwords do not match.', () {});
          return;
        }

        //Check for old password and for same password
        showLoadingDialog(context, 'Checking...');
        QuerySnapshot querySnapshot = (await firestore?.collection('users')
            .where('username', isEqualTo: widget.logged)
            .get()) as QuerySnapshot<Object?>;
        var fetched = querySnapshot.docs.first;
        if (!BCrypt.checkpw(oldpCont.text, fetched['password'])) {
          Navigator.pop(context);
          showOKDialog(context, 'Wrong password.', () {});
          return;
        }
        if (BCrypt.checkpw(newpCont.text, fetched['password'])) {
          Navigator.pop(context);
          showOKDialog(context, 'New password cannot be the old password.', () {});
          return;
        }

        //Saves
        Navigator.pop(context);
        showLoadingDialog(context, 'Changing...');
        User user = User(username: widget.logged, hashedPassword: BCrypt.hashpw(newpCont.text, BCrypt.gensalt()));
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.update({
            'username': user.username,
            'password': user.hashedPassword
          });
        }
        Log log = Log(type: 'User', account: widget.logged, action: 'Edit', name: user.username, dateandtime: DateTime.now().toString());
        firestore?.collection('logs').add({
          'type': log.type,
          'account': log.account,
          'action': log.action,
          'name': log.name,
          'dateandtime': log.dateandtime
        });

        Navigator.pop(context);
        showOKDialog(context, 'Successfully changed password!', (){
          Navigator.pop(context);
        });
          }
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Change Password', style: TextStyle(color: Colors.white),),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: oldpCont,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Old Password',
                        labelStyle: TextStyle(color: Colors.white)
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: newpCont,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(color: Colors.white)
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: newp2Cont,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Colors.white)
                    ),
                    obscureText: true,
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
          )
        ]
      )
    );
  }
}
