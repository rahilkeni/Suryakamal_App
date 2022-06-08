import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
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
  Future<int> getAuth() async {
    await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();

    try {
      var collection = FirebaseFirestore.instance.collection('User');
      var docSnapshot = await collection.doc('Chart_Data').get();
      var dayData = {};
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        dayData = data?['day1']; // <-- The value you want to retrieve.
        for (var v in dayData.keys) {
          var time = v <= 4 ? v + 9 : v - 4;
          print("time: $time");
          var rating = dayData[v];
          print("rating: $rating");
          if (v <= 4) {
            time = v + 9;
          } else {
            time = v - 4;
          }
          print("time: $time\trating: $rating");
          dataE.add(_EnergyData(time, rating));
        }
      }
      print(dataE);
      return 0;
    } catch (e) {
      //print(e);
      return 0;
    }
  }

  List<_EnergyData> dataE = [];

  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40)
  ];

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
          appBar: AppBar(
            centerTitle: true,
            title: Text("Suryakamal"),
          ),
          body: Container(
            color: Colors.lightBlueAccent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20.0),
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  //chart title
                  title: ChartTitle(text: 'Energy Generation For the Day'),
                  //enable legend
                  legend: Legend(isVisible: false),
                  //enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_SalesData, String>>[
                    SplineSeries(
                      dataSource: data,
                      xValueMapper: (_SalesData sales, _) => sales.year,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                    ),
                  ],
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

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

class _EnergyData {
  _EnergyData(this.time, this.rating);

  final double rating;
  final num time;
}
