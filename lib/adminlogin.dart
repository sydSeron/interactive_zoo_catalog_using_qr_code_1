import 'package:flutter/material.dart';
import 'accessories.dart';
import 'adminhome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bcrypt/bcrypt.dart';

class AdminLogin extends StatelessWidget {
  final String wallpaper; // Wallpaper passed as a parameter
  AdminLogin({Key? key, required this.wallpaper}) : super(key: key);

  final TextEditingController usernameCont = TextEditingController();
  final TextEditingController passwordCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String logged = "";
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Login', style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(wallpaper),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.5),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await login(context, usernameCont.text, passwordCont.text);
                      },
                      child: Text('Submit', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }

  Future<void> login(BuildContext context, String username, String password) async {
    bool isConnected = await connectivityService.checkConnection();
    if (!isConnected) {
      // If no connection, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    if (username.isEmpty || password.isEmpty) {
      showOKDialog(context, 'Please fill in both fields', () {});
      return;
    }

    if (username == 'admin0000' && password == 'dxkztghij@mnhbi') {
      String logged = username;
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHome(wallpaper: wallpaper, logged: logged),),);
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.size == 0) {
        showOKDialog(context, 'No account found with that username.', () {});
        return;
      }

      var adminData = querySnapshot.docs[0];
      String storedHashedPassword = adminData['password'];

      bool isPasswordCorrect = BCrypt.checkpw(password, storedHashedPassword);

      if (isPasswordCorrect) {
        String logged = username;
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHome(wallpaper: wallpaper, logged: logged),),);
      } else {
        showOKDialog(context, 'Incorrect Password!', () {});
        passwordCont.clear();
      }
    } catch (e) {
      showOKDialog(context, 'An error occurred: $e', () {});
    }
  }
}
