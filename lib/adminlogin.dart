import 'package:flutter/material.dart';
import 'accessories.dart';
import 'adminhome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: usernameCont,
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                TextField(
                  controller: passwordCont,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      showOKDialog(context, 'Please fill in both fields', () {});
      return;
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHome(wallpaper: wallpaper, logged: logged),
          ),
        );
      } else {
        showOKDialog(context, 'Incorrect Password!', () {});
        passwordCont.clear();
      }
    } catch (e) {
      showOKDialog(context, 'An error occurred: $e', () {});
    }
  }
}
