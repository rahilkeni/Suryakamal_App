//import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyCustomSplashScreen(),
      routes: {
        RegistrationScreen.id: (context) => const RegistrationScreen(),
      },
    );
  }
}

class MyCustomSplashScreen extends StatefulWidget {
  @override
  _MyCustomSplashScreenState createState() => _MyCustomSplashScreenState();
}

class _MyCustomSplashScreenState extends State<MyCustomSplashScreen>
    with TickerProviderStateMixin {
  double _fontSize = 2;
  double _containerSize = 1.5;
  double _textOpacity = 0.0;
  double _containerOpacity = 0.0;
  late AnimationController _controller;
  late Animation<double> animation1;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    animation1 = Tween<double>(begin: 40, end: 20).animate(CurvedAnimation(
        parent: _controller, curve: Curves.fastLinearToSlowEaseIn))
      ..addListener(() {
        setState(() {
          _textOpacity = 1.0;
        });
      });
    _controller.forward();

    Timer(Duration(seconds: 2), () {
      setState(() {
        _fontSize = 1.06;
      });
    });

    Timer(Duration(seconds: 2), () {
      setState(() {
        _containerSize = 2;
        _containerOpacity = 1;
      });
    });

    Timer(Duration(seconds: 4), () {
      setState(() {
        Navigator.pushReplacement(context, PageTransition(LoadingScreen()));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/logo.jpg"),
            opacity: 0.5,
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                AnimatedContainer(
                    duration: Duration(milliseconds: 2000),
                    curve: Curves.fastLinearToSlowEaseIn,
                    height: _height / _fontSize),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 1000),
                  opacity: _textOpacity,
                  child: Text(
                    'Suryakamal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: animation1.value,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 2000),
                curve: Curves.fastLinearToSlowEaseIn,
                opacity: _containerOpacity,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 2000),
                  curve: Curves.fastLinearToSlowEaseIn,
                  height: _width / _containerSize,
                  width: _width / _containerSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Image.asset('images/logo-3.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageTransition extends PageRouteBuilder {
  final Widget page;

  PageTransition(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: Duration(milliseconds: 2000),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn,
              parent: animation,
            );
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizeTransition(
                sizeFactor: animation,
                child: page,
                axisAlignment: 0,
              ),
            );
          },
        );
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
//    print(email);
//    print(password);

    if ((email != null) && (password != null)) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          PageTransition(const MainScreen()),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          PageTransition(const RegistrationScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/logo.jpg"),
            opacity: 0.2,
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: SpinKitRotatingCircle(
            color: Colors.white,
            size: 50.0,
          ),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const String id = 'registration_screen';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue),
      title: "Register",
      home: const Register(),
    );
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final messageTextController1 = TextEditingController();
  final messageTextController2 = TextEditingController();
  bool showSpinner = false;
  String? email;
  String? password;

  Future<int> getAuth(email, password) async {
    await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();
    try {
      var collection = FirebaseFirestore.instance.collection('User');
      var docSnapshot = await collection.doc('auth').get();
      var mail = "";
      var pass = "";
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        mail = data?['email']; // <-- The value you want to retrieve.
        pass = data?['password'];
      }
      if (mail == email && pass == password) {
        prefs.setString('email', email);
        prefs.setString('password', password);
        return 1;
      }
      return 0;
    } catch (e) {
      //print(e);
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 70),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Your Email",
                    fillColor: Colors.white60,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  controller: messageTextController1,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Your Password",
                    fillColor: Colors.white60,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  controller: messageTextController2,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Register".toUpperCase(),
                        style: const TextStyle(fontSize: 14)),
                  ),
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.lightBlueAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    messageTextController1.clear();
                    messageTextController2.clear();
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      //print("Email: $email");
                      //print("Password: $password");
                      var ret = await getAuth(email, password);
                      if (ret == 1) {
                        Future.delayed(const Duration(seconds: 3), () {
                          Navigator.push(
                            context,
                            PageTransition(const MainScreen()),
                          );
                        });
                      } else {
                        //print("Unverified");
                      }
                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          showSpinner = false;
                        });
                      });
                    } catch (e) {
                      //print(e);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const String id = 'main_screen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTabIndex = 1;
  List<_EnergyData> data1 = [];
  List<_EnergyData> data2 = [];
  List<_EnergyData> data3 = [];
  final fontColor = Color(0xFF2937B9);
  var system_status = Colors.grey;
  var system_temp = "50° C";

  void getChartData(docSnapshot) {
    var day1 = [];
    var day2 = [];
    var day3 = [];
    Map<String, dynamic>? data = docSnapshot.data();
    var d = [];
    var val = [];
    data?.forEach((key, value) {
      d.add(key);
      val.add(value);
    });
    day1 = val[0]['pwr'];
    day2 = val[1]['pwr']; // <-- The value you want to retrieve.
    day3 = val[2]['pwr']; // <-- The value you want to retrieve.
    system_temp = val[0]['rpi_status']['temp'];
    print(system_temp);

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
      data3.add(_EnergyData(c, day3[i]));
    }
  }

  void getSystemData(docSnapshot) {
    Map<String, dynamic>? data = docSnapshot.data();
    var d = [];
    var val = [];
//    data?.forEach((key, value) {
//      d.add(key);
//      print(key);
//      val.add(value);
//    });
    print("length ");
    print(docSnapshot.size);
  }

  Future<int> getAuth() async {
    await Firebase.initializeApp();
    final prefs = await SharedPreferences.getInstance();
    try {
      var collection = FirebaseFirestore.instance.collection('User');
      var docSnapshot = await collection.doc('data').get();
      if (docSnapshot.exists) {
        getChartData(docSnapshot);
        getSystemData(docSnapshot);
      }
      return 0;
    } catch (e) {
      return 1;
    }
  }

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: true);
    super.initState();
    getAuth();
  }

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/logo.jpg"), fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                  height: 300,
                  width: 350,
                  child: SfCartesianChart(
//                    plotAreaBackgroundColor: Color.fromRGBO(0, 0, 0, 0.4),
                    backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
                    zoomPanBehavior: _zoomPanBehavior,
                    title: ChartTitle(text: 'Energy Generated'),
                    plotAreaBorderWidth: 1,
                    primaryXAxis: CategoryAxis(
                        interval: 0.5,
                        majorGridLines: const MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift),
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
//                      opacity: 0.7,
//                      width: '10%',
//                      padding: 1.0,
                    ),
                    primaryYAxis: NumericAxis(
                        labelFormat: '{value}V',
                        axisLine: const AxisLine(width: 0),
                        majorGridLines: const MajorGridLines(width: 0),
                        majorTickLines: const MajorTickLines(size: 0)),
                    series: <ChartSeries<_EnergyData, String>>[
                      SplineAreaSeries<_EnergyData, String>(
                        name: "Day 1",
                        dataSource: data1,
                        color: const Color.fromRGBO(0, 135, 0, 0.43),
                        borderColor: const Color.fromRGBO(75, 135, 185, 1),
                        borderWidth: 2,
                        xValueMapper: (_EnergyData reading, _) => reading.time,
                        yValueMapper: (_EnergyData reading, _) =>
                            reading.rating,
                      ),
                      SplineAreaSeries<_EnergyData, String>(
                        name: "Day 2",
                        dataSource: data2,
                        color: const Color.fromRGBO(75, 135, 185, 0.6),
                        borderColor: const Color.fromRGBO(75, 135, 185, 1),
                        borderWidth: 2,
                        xValueMapper: (_EnergyData reading, _) => reading.time,
                        yValueMapper: (_EnergyData reading, _) =>
                            reading.rating,
                      ),
                      SplineAreaSeries<_EnergyData, String>(
                        name: "Day 3",
                        dataSource: data3,
                        color: const Color.fromRGBO(75, 135, 185, 0.4),
                        borderColor: const Color.fromRGBO(75, 110, 185, 1),
                        borderWidth: 2,
                        xValueMapper: (_EnergyData reading, _) => reading.time,
                        yValueMapper: (_EnergyData reading, _) =>
                            reading.rating,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ), //Chart
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
//                          width: 0.38 * MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                width: 100,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Energy Generated',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: fontColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "100 W",
                                style: TextStyle(
                                  color: fontColor,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ), //Energy Generated
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
//                          width: 0.38 * MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 100,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'System Status',
                                  style: TextStyle(
                                    color: fontColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: system_status,
                                    shape: BoxShape.circle),
                              )
                            ],
                          ),
                        ),
                        Container(
//                          width: 0.38 * MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                width: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'System Temperature',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: fontColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                system_temp,
                                style: TextStyle(
                                  color: fontColor,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ), //System Status & Temp
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 20.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 20.0, right: 20.0, left: 20.0, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Camera',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.deepPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: system_status,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Motor Driver',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.deepPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: system_status,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Motor 1',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.deepPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: system_status,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 15.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Motor 2',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.deepPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50.0),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    color: system_status,
                                    shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ), // Status
              ],
            ),
          )
        ],
      ),
      //Logs Tab
      Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/logo.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: (MediaQuery.of(context).size.height * 0.025),
              horizontal: (MediaQuery.of(context).size.width * 0.05),
            ),
            child: Container(
              padding: EdgeInsets.only(
                top: (MediaQuery.of(context).size.height * 0.025),
                right: (MediaQuery.of(context).size.width * 0.05),
                left: (MediaQuery.of(context).size.width * 0.05),
                bottom: (MediaQuery.of(context).size.width * 0.05),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(255, 255, 255, 0.2),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: (MediaQuery.of(context).size.height * 0.01)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Level',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
//                              horizontal:
//                              (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Message',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: (MediaQuery.of(context).size.height * 0.002),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical:
                              (MediaQuery.of(context).size.height * 0.01)),
//                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '12:25:17',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
//                              horizontal:
//                              (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'System Failure',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: (MediaQuery.of(context).size.height * 0.002),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical:
                              (MediaQuery.of(context).size.height * 0.01)),
//                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.warning,
                              color: Colors.yellow,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '11:55:33',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
//                              horizontal:
//                              (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Temperature Rising, May cause System Shutdown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: (MediaQuery.of(context).size.height * 0.002),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical:
                              (MediaQuery.of(context).size.height * 0.01)),
//                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.info,
                              color: Colors.blue,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              right: (MediaQuery.of(context).size.width * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
                              horizontal:
                                  (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '11:08:18',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  (MediaQuery.of(context).size.width * 0.01),
//                              horizontal:
//                              (MediaQuery.of(context).size.width * 0.02),
                            ),
                            width: (MediaQuery.of(context).size.width * 0.40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'System Functioning Optimally',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.clip,
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: (MediaQuery.of(context).size.height * 0.002),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ), // Status
      SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: kToolbarHeight),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                maxRadius: 48,
                backgroundImage: AssetImage('images/profile_pic.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Optimus Prime',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text('Settings'),
                subtitle: Text('Privacy and logout'),
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 30,
                    minHeight: 30,
                    minWidth: 30,
                  ),
                  child: Image.asset(
                    'images/settings_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.yellow),
              ),
              Divider(),
              ListTile(
                title: Text('Help & Support'),
                subtitle: Text('Help center and legal support'),
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 30,
                    minHeight: 30,
                    minWidth: 30,
                  ),
                  child: Image.asset(
                    'images/support.png',
                    fit: BoxFit.cover,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.yellow,
                ),
              ),
              Divider(),
              ListTile(
                title: Text('FAQ'),
                subtitle: Text('Questions and Answer'),
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 30,
                    maxWidth: 30,
                    minHeight: 30,
                    minWidth: 30,
                  ),
                  child: Image.asset(
                    'images/faq.png',
                    fit: BoxFit.cover,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.yellow),
              ),
              Divider(),
            ],
          ),
        ),
      ), //Profile Tab
    ];

    final _kBottomNavBarItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.view_list),
        label: "Logs",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle),
        label: "Account",
      ),
    ];

    assert(_kTabPages.length == _kBottomNavBarItems.length);

    final bottomNavBar = BottomNavigationBar(
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.lightGreen,
      items: _kBottomNavBarItems,
      currentIndex: _currentTabIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
    );

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
          body: _kTabPages[_currentTabIndex],
          bottomNavigationBar: bottomNavBar,
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
