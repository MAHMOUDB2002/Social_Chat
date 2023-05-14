import 'package:f_finalproject/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Social Network",
      theme: ThemeData(
        primaryColor: Colors.blue[400],
        accentColor: Colors.greenAccent[400],
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
