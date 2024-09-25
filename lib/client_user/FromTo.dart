import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/client_user/Map-for-Driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FromtoPage extends StatefulWidget {
  const FromtoPage({super.key});

  @override
  State<FromtoPage> createState() => _FromtoPageState();
}

class _FromtoPageState extends State<FromtoPage> {
  final TextEditingController _startPlace = TextEditingController();
  final TextEditingController _endPlace = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          //height: 220,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("Assets/Images/From_To.png"),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  "Please type the exact names of the both place, otherwise, you may not be able to find a ride.",
                  style: TextStyle(
                      fontFamily: "Sofia",
                      fontWeight: FontWeight.w200,
                      fontSize: 16.0,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                child: TextFormField(
                  controller: _startPlace,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'From',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // End Place TextField
              Padding(
                padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                child: TextFormField(
                  controller: _endPlace,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'To',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Primary color for the button
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () async {
                    if (_startPlace.text.isNotEmpty &&
                        _endPlace.text.isNotEmpty) {
                      // Handle successful input
                      print("From: ${_startPlace.text}, To: ${_endPlace.text}");
                      From = _startPlace.text.trim().toLowerCase();
                      To = _endPlace.text.trim().toLowerCase();
                      setState(() {});
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("From", _startPlace.text);
                      prefs.setString("To", _endPlace.text);
                      prefs.setBool("Has_From_To", true);
                      Has_From_To = true;

                      setState(() {});
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DriverRides()),
                      );
                    } else {
                      // Show an error message if either field is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill both From and To fields.'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Find Vehicle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
