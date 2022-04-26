import 'package:flutter/material.dart';
//Importing Screens
import 'package:suryakamal/screens/LoadingScreen.dart';
import 'package:suryakamal/screens/Registration_Screen.dart';
import 'package:suryakamal/screens/MainScreen.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MainScreen(),
      routes: {
        MainScreen.id: (context) => MainScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
      },
    );
  }
}
