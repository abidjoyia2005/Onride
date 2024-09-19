import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/Driver/Choice_Device.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GifWithBlur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void CreateDocumentFirebase() async {
      print("User name of 0 count:");
      CollectionReference chatCollection =
          FirebaseFirestore.instance.collection('User_Data');

      await chatCollection
          .doc(User_Id)
          .set({'Driver_Acount': true})
          .then((value) => () {
                print("Username Added");
              })
          .catchError(
              (error) => print("Failed to add user message count: $error"));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'Assets/gifs/map.gif',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Blur(
              blur: 6.0, // Adjust the blur intensity
              blurColor: Colors.black.withOpacity(0.3), // Optional blur color
              child: Container(),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            child: Container(
              width: 130,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepOrangeAccent, // Primary color for the button
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  CreateDocumentFirebase();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool("Has_Driver_Acount", true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UberMap()),
                  );
                },
                child: Text(
                  'Driver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color white
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 20,
            child: Container(
              width: 130,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.lightBlue, // Primary color for the button
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool("Has_Driver_Acount", false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UberMap()),
                  );
                },
                child: Text(
                  'Client',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color white
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
