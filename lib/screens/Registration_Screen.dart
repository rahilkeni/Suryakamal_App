import 'package:flutter/material.dart';
import 'package:suryakamal/screens/MainScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const String id = 'registration_screen';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue),
      title: "Register",
      home: Register(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 100),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Your Password",
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
                SizedBox(height: 24),
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
                SizedBox(height: 30),
                ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Register".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                  ),
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.lightBlueAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.red),
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
                      print("Email: $email");
                      print("Password: $password");
                      Future.delayed(Duration(seconds: 3), () {
                        setState(() {
                          showSpinner = false;
                        });
                      });
                    } catch (e) {
                      print(e);
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
