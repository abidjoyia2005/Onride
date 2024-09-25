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
          .set({'Driver_Acount': true}, SetOptions(merge: true))
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
            top: 1,
            left: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 80.0,
                    // bottom: 170.0,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "Drivers & \npassengers \ncan find each\nother over \nlong \ndistances",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 37.0,
                        fontWeight: FontWeight.w800,
                        fontFamily: "lemon",
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      top: 60.0,
                      // right: 20.0,
                    ),
                    child: Text(
                      "Radar scans your surroundings \n within an 8 km radius.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w200,
                        fontFamily: "Sofia",
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 200.0)),
              ],
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Vichale_cHOSE()),
                  );
                },
                child: Text(
                  'Driver',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
