import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'classes.dart';
import 'package:bcrypt/bcrypt.dart';
import 'accessories.dart';

class Adminadd extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  final String logged;
  const Adminadd({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<Adminadd> createState() => _AdminaddState();
}

class _AdminaddState extends State<Adminadd> {
  @override
  final TextEditingController usernameCont = TextEditingController();
  final TextEditingController passwordCont = TextEditingController();
  final TextEditingController password2Cont = TextEditingController();

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

  void submit(String username, String pass, String pass2) async {
    bool isConnected = await connectivityService.checkConnection();
    
    if (!isConnected) {
      showOKDialog(context, 'No internet connection. Please try again.', () {
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
            Navigator.pop(context);
          });
        });
      }
      else {
        Navigator.pop(context);
        //Checks for empty fields
        if (username.isEmpty || pass.isEmpty || pass2.isEmpty) {
          showOKDialog(context, 'Some fields are empty.', (){});
          return;
        }

        //Check if confirm password matches
        if (pass != pass2) {
          showOKDialog(context, 'Passwords do not match.', () {});
          return;
        }

        //Check if username already exists
        QuerySnapshot querySnapshot = (await firestore?.collection('users')
            .where('username', isEqualTo: username)
            .get()) as QuerySnapshot<Object?>;
        if (querySnapshot.size > 0) {
          showOKDialog(context, 'Username already exists.', () {});
          return;
        }

        //Save information
        showLoadingDialog(context, 'Adding...');
        User user = User(username: username, hashedPassword: BCrypt.hashpw(pass, BCrypt.gensalt()));
        firestore?.collection('users').add({
          'username': user.username,
          'password': user.hashedPassword
        });
        Log log = Log(type: 'User', account: widget.logged, action: 'Add', name: user.username, dateandtime: DateTime.now().toString());
        firestore?.collection('logs').add({
          'type': log.type,
          'account': log.account,
          'action': log.action,
          'name': log.name,
          'dateandtime': log.dateandtime
        });
        Navigator.pop(context);
        showOKDialog(context, 'Successfully added account!', (){
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
        title: Text('Add Account', style: TextStyle(color: Colors.white),),
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
                    controller: usernameCont,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.white)
                    ),
                  ),
                  TextField(
                    controller: passwordCont,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white)
                    ),
                    obscureText: true,
                  ),
                  TextField(
                    controller: password2Cont,
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
                      if (usernameCont.text == null || passwordCont.text == null || password2Cont.text == null) {
                        showOKDialog(context, 'Some fields are empty.', (){});
                      }
                      else {
                        submit(usernameCont.text, passwordCont.text, password2Cont.text);
                      }
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
        ],
      )
    );
  }
}
