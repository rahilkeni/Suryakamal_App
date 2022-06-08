import 'package:flutter/material.dart';
//import 'package:suryakamal/screens/MainScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';

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
//        print(mail);
//        print(pass);
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
