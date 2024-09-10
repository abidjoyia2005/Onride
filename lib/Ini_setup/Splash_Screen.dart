import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:flutter_application_1/Ini_setup/Login_Screen.dart';
import 'package:flutter_application_1/Ini_setup/Onbording.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Simulate a delay before navigating to the next screen
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // White background like Instagram's splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instagram logo or any logo you want
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png',
              width: 120.0, // Set the logo size
              height: 120.0,
            ),
            SizedBox(height: 20.0),
            // Text like Instagram or your app's name
            Text(
              'Instagram',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
