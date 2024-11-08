import 'package:flutter/material.dart';
import 'accessories.dart';
import 'adminhome.dart';

class AdminLogin extends StatelessWidget {
  //Wallpaper
  final String wallpaper;
  AdminLogin({Key? key, required this.wallpaper}) : super(key: key);

  @override

  //Consider having encryption with password in the future
  //Consider firebasing to allow dynamic admin account settings
  final TextEditingController usernameCont = TextEditingController();
  final TextEditingController passwordCont = TextEditingController();

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
                  onPressed: () {
                    if (usernameCont.text == 'admin' && passwordCont.text == '1234') {
                      logged = usernameCont.text;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHome(wallpaper: wallpaper, logged: logged,)));
                    }
                    else {
                      showOKDialog(context, 'Wrong username or password', () {});
                      usernameCont.clear();
                      passwordCont.clear();
                    }
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
}
