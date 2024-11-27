import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adminlogin.dart';

int a = 0;
int c = 0;
int d = 0;

class Credits extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  const Credits({Key? key, required this.wallpaper}) : super(key: key);

  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  // Resets the counters
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
    // Redirect once the secret combination is entered
    // Change to AdminLogin later
    if (a == 5 && c == 3 && d == 5) {
      Future.delayed(Duration.zero, () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminLogin(wallpaper: widget.wallpaper)));
      });
    }

    // Can be firebased so it is editable
    String aboutus =
      "The Manila Zoological and Botanical Garden is the only public zoo in the City of Manila it first opened on July 25, 1959 during the tenure of Manila Mayor Arsenio H. Lacson.\n\n"
        "The Zoo's main attraction is Ma'ali (Vishwama'ali) a female Asian Elephant gifted by the government of Sri Lanka in 1977 and Kois the White Tiger, a male white Siberian Tiger donated by Zoocobia in 2021.\n\n"
        "Manila Zoo also provide forever home to more than 550 specimens of exotic wildlife representing 13 species of mammals, 38 species of avian, and 21 species of reptiles.\n\n"
        "All animals are securely monitored to their lovely habitats while being maintained by group of Professional Veterinarians.\n\n"
        "Manila Zoo also nurtures a botanical garden where more than 10.000 plants are being grown and propagated.";
    String contact =
      "For inquiries, you may reach us through:\n\n"
        "Email: manilazoo@manila.gov.ph\n"
        "Social Media: https://www.facebook.com/ManilaZooPH.OfficialPage\n"
        "Address: M. Adriatico St, Malate, Manila, 1004 Metro Manila";
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
                            child: Text(
                              'ABOUT US',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 30,
                                fontFamily: 'RobotoCondensed',
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text(
                              aboutus,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'RobotoCondensed',
                              ),
                              textAlign: TextAlign.justify,
                            ),
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
                            child: Text(
                              'CONTACT US',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 30,
                                fontFamily: 'RobotoCondensed',
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text(
                              contact,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'RobotoCondensed',
                              ),
                              textAlign: TextAlign.justify,
                            ),
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
                            child: Text(
                              'DEVELOPERS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 30,
                                fontFamily: 'RobotoCondensed',
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(defpad),
                            child: Text(
                              develop,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'RobotoCondensed',
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}