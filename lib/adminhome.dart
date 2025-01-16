import 'package:flutter/material.dart';
import 'accessories.dart';
import 'addanimal.dart';
import 'animallist.dart';
import 'adminsettings.dart';
import 'adminstats.dart';

class AdminHome extends StatefulWidget {
  // Wallpaper
  final String wallpaper;
  final String logged;
  const AdminHome({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Home', style: TextStyle(color: Colors.white),),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Hello, ' + widget.logged,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoCondensed',
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Check connection before proceeding
                              bool isConnected = await connectivityService.checkConnection();
                              if (!isConnected) {
                                // Show SnackBar if no connection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No internet connection')),
                                );
                                return;
                              }

                              // Proceed if connected
                              showLoadingDialog(context, 'Rechecking credentials...');
                              isLoggedCorrectly(widget.logged).then((isCorrect) {
                                if (!isCorrect) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Navigator.pop(context);
                                    showOKDialog(context, 'Please login again.', () {
                                      Navigator.pop(context);
                                    });
                                  });
                                } else {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddAnimal(wallpaper: widget.wallpaper, logged: widget.logged,)));
                                }
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add),
                                SizedBox(height: 10,),
                                Text('Add Animal')
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                            onPressed: () async {
                              // Check connection before proceeding
                              bool isConnected = await connectivityService.checkConnection();
                              if (!isConnected) {
                                // Show SnackBar if no connection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No internet connection')),
                                );
                                return;
                              }

                              // Proceed if connected
                              showLoadingDialog(context, 'Rechecking credentials...');
                              isLoggedCorrectly(widget.logged).then((isCorrect) {
                                if (!isCorrect) {
                                  Navigator.pop(context);
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    showOKDialog(context, 'Please login again.', () {
                                      Navigator.pop(context);
                                    });
                                  });
                                } else {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Animallist(wallpaper: widget.wallpaper, logged: widget.logged,)));
                                }
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit),
                                SizedBox(height: 10,),
                                Text('Edit Animal')
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Check connection before proceeding
                              bool isConnected = await connectivityService.checkConnection();
                              if (!isConnected) {
                                // Show SnackBar if no connection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No internet connection')),
                                );
                                return;
                              }

                              // Proceed if connected
                              showLoadingDialog(context, 'Rechecking credentials...');
                              isLoggedCorrectly(widget.logged).then((isCorrect) {
                                if (!isCorrect) {
                                  Navigator.pop(context);
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    showOKDialog(context, 'Please login again.', () {
                                      Navigator.pop(context);
                                    });
                                  });
                                } else {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Adminsettings(wallpaper: widget.wallpaper, logged: widget.logged,)));
                                }
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.settings),
                                SizedBox(height: 10,),
                                Text('Settings')
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                            onPressed: () async {
                              // Check connection before proceeding
                              bool isConnected = await connectivityService.checkConnection();
                              if (!isConnected) {
                                // Show SnackBar if no connection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No internet connection')),
                                );
                                return;
                              }

                              // Proceed if connected
                              showLoadingDialog(context, 'Rechecking credentials...');
                              isLoggedCorrectly(widget.logged).then((isCorrect) {
                                if (!isCorrect) {
                                  Navigator.pop(context);
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    showOKDialog(context, 'Please login again.', () {
                                      Navigator.pop(context);
                                    });
                                  });
                                } else {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminStats(wallpaper: widget.wallpaper, logged: widget.logged,)));
                                }
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.graphic_eq),
                                SizedBox(height: 10,),
                                Text('Statistics')
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
