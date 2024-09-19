import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Ini_setup/Choose_Screen.dart';
import 'package:flutter_application_1/Ini_setup/Login_Screen.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  @override
  State createState() {
    return _SignupScreen();
  }
}

void CreateDocumentFirebase(
  String User_id,
  String User_name,
) async {
  print("User name of 0 count:");
  CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('User_Data');
  // String MakeId = '$User_name $User_id';

  await chatCollection
      .doc(User_id)
      .set({
        'User_Name': User_name,
        // 'FCMToken': Token,
        'CompleteProfile': false,
        'Driver_Acount': false
      })
      .then((value) => () {
            print("Username Added");
          })
      .catchError((error) => print("Failed to add user message count: $error"));
}

class _SignupScreen extends State<SignupScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  GlobalKey<FormState> _key = GlobalKey();
  final AuthService _authService = AuthService();
  var FirebaseToken;
  void _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission if needed
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken(); // Get the token
      setState(() {
        FirebaseToken = token;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background color by default

      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 25.0, right: 16.0, left: 16.0),
              child: Text(
                'Create Account',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 25),

            /// Name input field
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24.0),
              child: TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: validateName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            /// Email input field
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24.0),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            /// Password input field
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24.0),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: validatePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            /// Confirm password input field
            Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24.0),
              child: TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                validator: validateConfirmPassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),

            SizedBox(height: 25),

            /// Signup button
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Primary color for the button
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () async {
                  var Res = await _authService.signUpWithEmail(
                      _emailController.text, _passwordController.text, context);
                  print('Response is :$Res');

                  setState(() {});
                  if (Res != "null") {
                    User_Id = Res;
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("userLogIn", true);
                    prefs.setString("UserId", User_Id);
                    prefs.setString("User_Name", _nameController.text);
                    CreateDocumentFirebase(User_Id, _nameController.text);
                    User_Name = _nameController.text;

                    setState(() {});

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GifWithBlur()),
                    );
                  }
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color white
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ));
                },
                child: Text(
                  'I have a Acount?',
                  style: TextStyle(
                      color: Colors.lightBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            /// OR divider
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),

            Container(
              height: 50,
              width: 200,
              child: SignInButton(
                Buttons.Google, // Use the pre-built Google button
                text: "Continue with Google",
                onPressed: () async {
                  User? user = await _authService.signInWithGoogle();
                  if (user != null) {
                    print("Google Sign-In Successful. User ID: ${user.uid}");
                  } else {
                    print("Google Sign-In Cancelled or Failed");
                  }
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SignupScreen(),
                  //   ),
                  // );
                },
              ),
            ),
            SizedBox(
              height: 13,
            ),

            /// Phone number login option
            InkWell(
              onTap: () {
                // Navigate to phone number login screen
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue, width: 0.3),
                  color: Colors.white, // Background color (optional)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.5), // Shadow color with transparency
                      spreadRadius: 0.5, // How much the shadow spreads
                      blurRadius: 2, // Softness of the shadow
                      offset: Offset(
                          0, 3), // Shadow position (horizontal, vertical)
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Login with Phone Number',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  _signup() {
    if (_key.currentState?.validate() ?? false) {
      // Perform signup logic
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
