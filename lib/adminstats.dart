import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'accessories.dart';

class AdminStats extends StatefulWidget {
  //Wallpaper
  final String wallpaper;
  final String logged;
  const AdminStats({Key? key, required this.wallpaper, required this.logged}) : super(key: key);

  @override
  State<AdminStats> createState() => _AdminStatsState();
}

class _AdminStatsState extends State<AdminStats> {
  final TextEditingController yearCont = TextEditingController();
  final TextEditingController monthCont = TextEditingController();

  int selectedYear = 0;
  int selectedMonth = 0;
  int firstHalf = 0;
  int secondHalf = 0;

  Color textColor = Colors.white;
  double opacity = 0.5;
  String? wallp;
  String? storedwallp;
  String button = "Print Format";

  int year = 0;
  int month = 0;
  Map<int, int> peopleInMonth = {
    for (int i = 1; i <= 12; i++) i: 0,
  };

  Map<int, int> peopleInDay = {
    for (int i = 1; i <= 31; i++) i: 0,
  };

  FirebaseFirestore? firestore;

  void initState() {
    super.initState();
    initializeFirebase();

    wallp = widget.wallpaper;
    storedwallp = wallp;
  }

  void initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    setState(() {
      firestore = FirebaseFirestore.instance;
    });
  }

  bool checkFields() {
    // Checks for empty fields
    if (yearCont.text.trim().isEmpty || monthCont.text.trim().isEmpty) {
      showOKDialog(context, 'Some fields are empty.', () {
        yearCont.clear();
        monthCont.clear();
      });
      return false;
    }
    // Checks for the numbers first if not number, then bounds
    int? m = int.tryParse(monthCont.text.trim());
    int? y = int.tryParse(yearCont.text.trim());
    final now = DateTime.now();
    if (m == null || y == null) {
      showOKDialog(context, 'Make sure the fields are all numbers.', () {
        yearCont.clear();
        monthCont.clear();
      });
      return false;
    }
    if (m < 1 || m > 12) {
      showOKDialog(context, 'Limit the month into 1 to 12.', () {
        yearCont.clear();
        monthCont.clear();
      });
      return false;
    }
    if (y > now.year || (y == now.year && m > now.month)) {
      showOKDialog(context, 'Cannot select a future date.', () {
        yearCont.clear();
        monthCont.clear();
      });
    }

    return true;
  }

  void submit() async {
    bool isConnected = await connectivityService.checkConnection();
    if (!isConnected) {
      showOKDialog(context, 'No internet connection. Please try again', () {
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
          });
        });
      }
      else {
        Navigator.pop(context);
        if (!checkFields()) {
          return;
        }

        showLoadingDialog(context, 'Fetching...');
        int? m = int.tryParse(monthCont.text.trim());
        int? y = int.tryParse(yearCont.text.trim());
        CollectionReference collection = FirebaseFirestore.instance.collection('visitors');
        //year
        QuerySnapshot qSyear = await collection.where('year', isEqualTo: y).get();
        int countyear = qSyear.docs.length;
        int countMonth = 0;
        //months
        Map<int, int> updatedPeopleInMonth = {
          for (int i = 1; i <= 12; i++) i: 0,
        };

        Map<int, int> updatedPeopleInDay = {
          for (int i = 1; i <= 31; i++) i: 0,
        };

        for (QueryDocumentSnapshot doc in qSyear.docs) {
          int month = doc['month'];
          if (month != null) {
            updatedPeopleInMonth[month] = (updatedPeopleInMonth[month] ?? 0) + 1;
            if (month == m!) {
              countMonth += 1;
              int day = doc['day'];
              updatedPeopleInDay[day] = (updatedPeopleInDay[day] ?? 0) + 1;
            }
          }
        }

        int fh = 0;
        int sh = 0;
        int daysinmonth = getDaysInMonth(m!, y!);
        if (daysinmonth % 2 == 0) {
          fh = (daysinmonth / 2).toInt();
          sh = (daysinmonth / 2).toInt();
        } else {
          sh = (daysinmonth ~/ 2).toInt();
          fh = sh + 1;
        }

        Navigator.pop(context);
        setState(() {
          selectedYear = y!;
          selectedMonth = m!;
          firstHalf = fh;
          secondHalf = sh;
          year = countyear;
          month = countMonth;
          peopleInMonth = updatedPeopleInMonth;
          peopleInDay = updatedPeopleInDay;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Statistics', style: TextStyle(color: textColor),),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(wallp!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(opacity),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      controller: yearCont,
                      maxLines: null,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: TextStyle(color: textColor),
                        hintText: 'Enter a number',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: monthCont,
                      maxLines: null,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Month',
                        labelStyle: TextStyle(color: textColor),
                        hintText: 'Enter a number',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10,),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          submit();
                        },
                        child: Text('Submit', style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Divider(height: 50,),
                    Text(
                      'YEARLY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 30,
                        fontFamily: 'RobotoCondensed',
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text('Total unique users in year ' + selectedYear.toString() + ': ' + year.toString(), style: TextStyle(color: textColor),),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 300,
                      width: 500,
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          child: BarChart(
                            BarChartData(
                              barGroups: List.generate(12, (index) {
                                int month = index + 1;  // For months 1 to 12
                                return BarChartGroupData(
                                  x: month,
                                  barRods: [
                                    BarChartRodData(toY: peopleInMonth[month]?.toDouble() ?? 0.0),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            for (int month = 1; month <= 6; month++)
                              Text(
                                '${getMonthName(month)}: ${peopleInMonth[month]?.toString() ?? "0"}',
                                style: TextStyle(color: textColor),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            for (int month = 7; month <= 12; month++)
                              Text(
                                '${getMonthName(month)}: ${peopleInMonth[month]?.toString() ?? "0"}',
                                style: TextStyle(color: textColor),
                              ),
                          ],
                        )
                      ],
                    ),
                    Divider(height: 50,),
                    Text(
                      'MONTHLY',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 30,
                        fontFamily: 'RobotoCondensed',
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text('Total unique users in ' + getMonthName(selectedMonth) + " / " + selectedYear.toString() + ': ' + month.toString(), style: TextStyle(color: textColor),),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 300,
                      width: 500,
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          child: BarChart(
                            BarChartData(
                              barGroups: List.generate(firstHalf, (index) {
                                int day = index + 1;
                                return BarChartGroupData(
                                  x: day,
                                  barRods: [
                                    BarChartRodData(toY: peopleInDay[day]?.toDouble() ?? 0.0),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 300,
                      width: 500,
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          child: BarChart(
                            BarChartData(
                              barGroups: List.generate(secondHalf, (index) {
                                int day = index + firstHalf + 1;
                                return BarChartGroupData(
                                  x: day,
                                  barRods: [
                                    BarChartRodData(toY: peopleInDay[day]?.toDouble() ?? 0.0),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            for (int day = 1; day <= firstHalf; day++)
                              Text(
                                '${day}: ${peopleInDay[day]?.toString() ?? "0"}',
                                style: TextStyle(color: textColor),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            for (int day = firstHalf + 1; day <= getDaysInMonth(selectedMonth, selectedYear); day++)
                              Text(
                                '${day}: ${peopleInDay[day]?.toString() ?? "0"}',
                                style: TextStyle(color: textColor),
                              ),
                          ],
                        )
                      ],
                    ),
                    Divider(height: 50,),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (button == "Print Format") {
                            setState(() {
                              wallp = 'images/whitescreen.jpg';
                              textColor = Colors.black;
                              button = "Viewing Format";
                              opacity = 0;
                            });
                          } else {
                            setState(() {
                              wallp = storedwallp;
                              textColor = Colors.white;
                              button = "Print Format";
                              opacity = 0.5;
                            });
                          }
                        },
                        child: Text(button, style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.1),
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
