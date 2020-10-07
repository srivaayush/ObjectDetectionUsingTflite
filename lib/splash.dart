import 'dart:async';

import 'package:flutter/material.dart';
import 'package:object_detector/home.dart';

// ignore: camel_case_types
class splashscreen extends StatefulWidget {
  @override
  _splashscreenState createState() => _splashscreenState();
}

// ignore: camel_case_types
class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => TfLiteHome(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Text(
          "Object \n   Detector",
          style: TextStyle(fontSize: 60.0),
        ),
      ),
    );
  }
}
