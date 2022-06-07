import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id = 'main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<FlSpot> day1 = [];

  @override
  void initState() {
    super.initState();
    callGetData();
  }

  void callGetData() async {
    await getData();
  }

  Future<void> getData() async {
    await Firebase.initializeApp();
    try {
      var collection = FirebaseFirestore.instance.collection('User');
      var docSnapshot = await collection.doc('Chart_Data').get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var data2 = data?["day1"] ?? -1;
        //mail = data?['day1'][0]; // <-- The value you want to retrieve.
        data2.forEach((i, value) {
          //print("index: $i, value: $value");
          day1.add(FlSpot(double.parse(i), value));
        });
      }
    } catch (e) {
      //print("error");
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Suryakamal"),
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  height: 300,
                  child: LineChart(
                    LineChartData(
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          //the red line
                          LineChartBarData(
                            spots: [
                              const FlSpot(1, 11.6),
                              const FlSpot(2, 11.9),
                              const FlSpot(3, 12.5),
                              const FlSpot(4, 12.6),
                              const FlSpot(5, 12.6),
                              const FlSpot(6, 12.6),
                              const FlSpot(7, 12.5),
                              const FlSpot(8, 12.5),
                              const FlSpot(9, 12.5),
                            ],
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.lightGreen,
                          ),
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00CCFF),
                        const Color(0xFF3366FF),
                      ],
                      begin: FractionalOffset(0, 0),
                      end: FractionalOffset(0, 1),
                    ),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "System Status:",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const Text("Active"),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("Motor Driver "),
                            const Text("Active"),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Logs and Errors",
                          textAlign: TextAlign.center,
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
