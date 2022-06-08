import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
//Importing Screens
import 'package:suryakamal/screens/Registration_Screen.dart';
import 'package:suryakamal/screens/MainScreen.dart';

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
    //print(email);
    //print(password);

    if ((email != null) && (password != null)) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(seconds: 3),
            //alignment: Alignment.center,
            child: const RegistrationScreen(),
          ),
          //MaterialPageRoute(builder: (context) {
          //  return ;
          //}),
        );
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            duration: const Duration(seconds: 3),
            //alignment: Alignment.center,
            child: const MainScreen(),
          ),
          //MaterialPageRoute(builder: (context) {
          //  return ;
          //}),
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
            image: AssetImage("images/logo.png"),
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
