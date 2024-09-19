import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:flutter_application_1/Ini_setup/Login_Screen.dart';
import 'package:flutter_application_1/Ini_setup/Onbording.dart';
import 'package:flutter_application_1/client_user/Map-for-Driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void Refresh_Data() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    User_Id = prefs.getString("UserId");
    User_Name = prefs.getString("User_Name");
    User_Profile_Picture = prefs.getString("Profile_Picture");
    Has_Driver_Acount = prefs.getBool("Has_Driver_Acount") ?? false;

    print("Username :$User_Name, user id :$User_Id");
  }

  bool user = false;

  Future<void> CheckUserLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    user = prefs.getBool("userLogIn") ?? false;
  }

  @override
  void initState() {
    super.initState();
    CheckUserLogin();
    Refresh_Data();

    // Simulate a delay before navigating to the next screen
    Timer(Duration(seconds: 3), () {
      if (user) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UberMap()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnBoardingScreen()),
        );
      }
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
            // Image.network(
            //   'https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png',
            //   width: 120.0, // Set the logo size
            //   height: 120.0,
            // ),
            SizedBox(height: 20.0),
            // Text like Instagram or your app's name
            Text(
              'Live TTrans pot',
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
