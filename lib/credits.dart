import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'adminhome.dart';

int a = 0;
int c = 0;
int d = 0;

class Credits extends StatefulWidget {
  const Credits({super.key});

  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {

  //Resets them counters
  Future<bool> _onPop() async {
    setState(() {
      a = 0;
      c = 0;
      d = 0;
    });
    return true;
  }
  
  @override
  Widget build(BuildContext context) {

    //Redirect once the secret combination is entered
    if (a == 1 && c == 2 && d == 0) {
      Future.delayed(Duration.zero, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHome()),);
      });
    }

    //Can be firebased so it is editable
    String aboutus = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    String contact = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    String develop = "This application is made as a final requirement for the subject Operating System by:\n Arañez, Charlie Magne \n Nacu, Adrian \n Rodeo, RJ \n Samonte, Rolan Jay \n Seron, Jan Emman \n\nSubmitted to: \n Dr. Arlene Evangelista \n College of Computing Sciences \n Eulogio \"Amang\" Rodriguez Institute of Science and Technology \n";

    const double defpad = 15.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await _onPop();
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(wallpaper),
                  fit: BoxFit.cover
              )
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          a += 1;
                        });
                      },
                      highlightColor: Colors.white.withOpacity(0.3),
                      splashColor: Colors.white.withOpacity(0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text('ABOUT US', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'RobotoCondensed',
                            ), textAlign: TextAlign.start,),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text(aboutus, style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'RobotoCondensed',
                            ), textAlign: TextAlign.justify,),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(defpad),
                    child: Divider(height: 0, color: Colors.white,),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          c += 1;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text('CONTACT US', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'RobotoCondensed',
                            ), textAlign: TextAlign.start,),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text(contact, style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'RobotoCondensed',
                            ), textAlign: TextAlign.justify,),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(defpad),
                    child: Divider(height: 0, color: Colors.white,),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          d += 1;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text('DEVELOPERS', style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'RobotoCondensed',
                            ), textAlign: TextAlign.start,),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text(develop, style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'RobotoCondensed',
                            ), textAlign: TextAlign.justify,),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
