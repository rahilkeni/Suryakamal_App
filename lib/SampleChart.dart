import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

void main() {
  return runApp(_ChartApp());
}

class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  _MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  List<_EnergyData> dataE = [
    _EnergyData('9 am', 11.6),
    _EnergyData('10 am', 11.9),
    _EnergyData('11 am', 12.5),
    _EnergyData('12 pm', 12.6),
    _EnergyData('1 pm', 12.6),
    _EnergyData('2 pm', 12.6),
    _EnergyData('3 pm', 12.5),
    _EnergyData('4 pm', 12.5),
    _EnergyData('5 pm', 12.5),
  ];

//  List<_EnergyData> dataE2 = [
//    _EnergyData(9, 11.9),
//    _EnergyData(10, 11.9),
//    _EnergyData(11, 12.2),
//    _EnergyData(12, 12.5),
//    _EnergyData(13, 12.6),
//    _EnergyData(14, 12.6),
//    _EnergyData(15, 12.5),
//    _EnergyData(16, 12.5),
//    _EnergyData(17, 12.5),
//  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syncfusion Flutter chart'),
      ),
      body: Column(
        children: [
          //Initialize the chart widget
          SfCartesianChart(
            legend: Legend(
                isVisible: true, opacity: 0.7, width: '10%', padding: 1.0),
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
                dataSource: dataE,
                color: const Color.fromRGBO(75, 135, 185, 0.6),
                borderColor: const Color.fromRGBO(75, 135, 185, 1),
                borderWidth: 2,
                xValueMapper: (_EnergyData reading, _) => reading.time,
                yValueMapper: (_EnergyData reading, _) => reading.rating,
              ),
//              SplineAreaSeries<_EnergyData, int>(
//                name: 'Day 2',
//                dataSource: dataE2,
//                color: const Color.fromRGBO(75, 135, 185, 0.6),
//                borderColor: const Color.fromRGBO(75, 135, 185, 1),
//                borderWidth: 2,
//                xValueMapper: (_EnergyData reading, _) => reading.time,
//                yValueMapper: (_EnergyData reading, _) => reading.rating,
//              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ],
      ),
    );
  }
}

class _EnergyData {
  _EnergyData(this.time, this.rating);

  final String time;
  final double rating;
}
