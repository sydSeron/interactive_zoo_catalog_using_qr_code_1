import 'package:flutter/material.dart';
import 'addanimal.dart';

class AdminHome extends StatelessWidget {
  //Wallpaper
  final String wallpaper;
  final String logged;
  const AdminHome({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

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
                image: AssetImage(wallpaper),
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
                        'Hello, ' + logged,
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
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddAnimal(wallpaper: wallpaper)));
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
                            onPressed: () {},
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings),
                            SizedBox(height: 10,),
                            Text('Account Settings')
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
