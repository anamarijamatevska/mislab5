// ignore_for_file: prefer_const_constructors, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:lab_mis/screens/login.dart';
import 'package:lab_mis/screens/register.dart';
import 'screens/landing.dart';

import 'package:firebase_core/firebase_core.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: SignInScreen.idScreen,
      routes: {
        HomeScreen.idScreen:(context) => HomeScreen(),
        SignInScreen.idScreen:(context) => SignInScreen(),
        RegisterScreen.idScreen:(context) => RegisterScreen(),
      }
    );
  }

 
}

