import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<_EnergyData> data1 = [];
  List<_EnergyData> data2 = [];
  List<_EnergyData> data3 = [];

  Future<int> getAuth() async {
    await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();
    try {
      var collection = FirebaseFirestore.instance.collection('User');
      var docSnapshot = await collection.doc('Chart_Data').get();
      var day1 = [];
      var day2 = [];
      var day3 = [];
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        day1 = data?['day1']; // <-- The value you want to retrieve.
        day2 = data?['day2']; // <-- The value you want to retrieve.
//        day3 = data?['day3']; // <-- The value you want to retrieve.

        for (var i = 0; i < 9; i++) {
          String c = "";
          if (i < 3) {
            c = "${(i + 9).toString()} am";
          } else {
            if (i == 3) {
              c = "${(i + 9).toString()} pm";
            } else {
              c = "${(i - 3).toString()} pm";
            }
          }
          data1.add(_EnergyData(c, day1[i]));
          data2.add(_EnergyData(c, day2[i]));
//          data3.add(_EnergyData(c, day3[i]));
        }
      }
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    getAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Colors.deepPurple,
            centerTitle: true,
            title: const Text(
              "Suryakamal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/logo.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SfCartesianChart(
                  legend: Legend(
                      isVisible: true,
                      opacity: 0.7,
                      width: '10%',
                      padding: 1.0),
                  title: ChartTitle(text: 'Energy Generated'),
                  plotAreaBorderWidth: 1,
                  primaryXAxis: CategoryAxis(
                      interval: 0.5,
                      majorGridLines: const MajorGridLines(width: 0),
                      edgeLabelPlacement: EdgeLabelPlacement.shift),
                  primaryYAxis: NumericAxis(
                      labelFormat: '{value}V',
                      axisLine: const AxisLine(width: 0),
                      majorGridLines: const MajorGridLines(width: 0),
                      majorTickLines: const MajorTickLines(size: 0)),
                  series: <ChartSeries<_EnergyData, String>>[
                    SplineAreaSeries<_EnergyData, String>(
                      name: 'Day 1',
                      dataSource: data1,
                      color: const Color.fromRGBO(75, 135, 185, 0.6),
                      borderColor: const Color.fromRGBO(75, 135, 185, 1),
                      borderWidth: 2,
                      xValueMapper: (_EnergyData reading, _) => reading.time,
                      yValueMapper: (_EnergyData reading, _) => reading.rating,
                    ),
                    SplineAreaSeries<_EnergyData, String>(
                      name: 'Day 2',
                      dataSource: data2,
                      color: const Color.fromRGBO(75, 135, 185, 0.6),
                      borderColor: const Color.fromRGBO(75, 135, 185, 1),
                      borderWidth: 2,
                      xValueMapper: (_EnergyData reading, _) => reading.time,
                      yValueMapper: (_EnergyData reading, _) => reading.rating,
                    ),
//                    SplineAreaSeries<_EnergyData, String>(
//                      name: 'Day 3',
//                      dataSource: data3,
//                      color: const Color.fromRGBO(75, 135, 185, 0.6),
//                      borderColor: const Color.fromRGBO(75, 135, 185, 1),
//                      borderWidth: 2,
//                      xValueMapper: (_EnergyData reading, _) => reading.time,
//                      yValueMapper: (_EnergyData reading, _) => reading.rating,
//                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: "Logs",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyData {
  _EnergyData(this.time, this.rating);
  final String time;
  final double rating;
}
