import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:flutter_application_1/Ini_setup/Choose_Screen.dart';
import 'package:flutter_application_1/Ini_setup/Forgot_screen.dart';
import 'package:flutter_application_1/Ini_setup/Signuo.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  GlobalKey<FormState> _key = GlobalKey();

  Future<void> saveTokenToDatabase() async {
    // Save token along with userId in Firestore or any backend service
    await FirebaseFirestore.instance
        .collection('User_Data')
        .doc(User_Id)
        .set({'FCMToken': FCMToken}, SetOptions(merge: true));
  }

  void GetDataForLogin(String User_id) async {
    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('User_Data');

    try {
      // Retrieve the document for the given User_id
      DocumentSnapshot documentSnapshot =
          await chatCollection.doc(User_id).get();

      if (documentSnapshot.exists) {
        saveTokenToDatabase();
        // Extract the 'name' field from the document
        var data = documentSnapshot.data() as Map<String, dynamic>;
        print("login user data :$data");
        String userName = data['User_Name'] ?? 'No Name';
        User_Name = userName;
        Has_Driver_Acount = data['Driver_Acount'] ?? false;

        Vicale_Type = data['Vicale_Type'] ?? "null";
        Has_From_To = data['Has_From_To'] ?? false;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("User_Name", userName);
        prefs.setBool("Has_Driver_Acount", Has_Driver_Acount);
        prefs.setBool("Has_From_To", Has_From_To);
        prefs.setString("Vicale_Type", Vicale_Type);
        User_Profile_Picture = data['Profile_Pic'] ?? "null";
        setState(() {});
        if (Has_Driver_Acount) {
          User_Profile_Picture = Vicale_Type;
          prefs.setString("Profile_Picture", Vicale_Type);
        } else {
          User_Profile_Picture = data['Profile_Pic'];
          prefs.setString("Profile_Picture", User_Profile_Picture);
        }
        setState(() {
          isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UberMap(), maintainState: false),
        );

        print("Data Download for login: User Name is $userName");
      } else {
        print("No such document found for User ID: $User_id");
      }
    } catch (error) {
      print("Failed to retrieve user data: $error");
    }
  }

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  void CreateDocumentFirebaseForGoogle(
      context, String userId, String userName, String profpic) async {
    print("Checking if document exists for user: $userName");

    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('User_Data');

    DocumentSnapshot docSnapshot = await chatCollection.doc(userId).get();

    if (!docSnapshot.exists) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      User_Profile_Picture = profpic;
      prefs.setString("Profile_Picture", User_Profile_Picture);
      setState(() {});

      // If document does not exist, create it
      await chatCollection.doc(userId).set({
        'User_Name': userName,
        'CompleteProfile': false,
        'Driver_Acount': false,
        'Profile_Pic': profpic,
        'FCMToken': FCMToken
      }).then((value) {
        print("User document created successfully.");
      }).catchError((error) {
        print("Failed to create user document: $error");
      });
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GifWithBlur()),
      );
    } else {
      saveTokenToDatabase();
      // If the document exists, retrieve the data
      print("Document for user already exists.");
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      print("login user data :$data");
      String userName = data['User_Name'] ?? 'No Name';
      User_Name = userName;
      Has_Driver_Acount = data['Driver_Acount'] ?? false;

      Vicale_Type = data['Vicale_Type'] ?? "null";
      Has_From_To = data['Has_From_To'] ?? false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("User_Name", userName);
      prefs.setBool("Has_Driver_Acount", Has_Driver_Acount);
      prefs.setBool("Has_From_To", Has_From_To);
      prefs.setString("Vicale_Type", Vicale_Type);
      User_Profile_Picture = data['Profile_Pic'] ?? "null";

      if (Has_Driver_Acount) {
        User_Profile_Picture = Vicale_Type;
        prefs.setString("Profile_Picture", Vicale_Type);
      } else {
        User_Profile_Picture = data['Profile_Pic'] ?? "null";
        prefs.setString("Profile_Picture", User_Profile_Picture);
      }
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UberMap(), maintainState: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background color by default
      body: isLoading
          ? LoadingGif()
          : Form(
              key: _key,
              autovalidateMode: _validate,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32.0, right: 16.0, left: 16.0),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 32),

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
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
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
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),

                  /// Forgot password link
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 24),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen(),
                              ));
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  /// Login button
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Primary color for the button
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        AuthService authService = AuthService();

                        var res = await authService.signInWithEmail(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            context);
                        print("login Response :$res");

                        if (res != null) {
                          User_Id = res;
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("userLogIn", true);
                          prefs.setString("UserId", User_Id);
                          GetDataForLogin(User_Id);

                          setState(() {});
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Text(
                        'Log In',
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
                              builder: (context) => SignupScreen(),
                            ));
                      },
                      child: Text(
                        "I don't have Acount? Sign Up ",
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  /// OR divider
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  /// Facebook login button
                  Container(
                    height: 50,
                    width: 200,
                    child: SignInButton(
                      Buttons.Google, // Use the pre-built Google button
                      text: "Continue with Google",
                      onPressed: () async {
                        AuthService _authService = AuthService();
                        User? user = await _authService.signInWithGoogle();
                        if (user != null) {
                          setState(() {
                            isLoading = true;
                          });
                          print(
                              "Google Sign-In Successful. User ID: ${user.uid}");
                          User_Id = user.uid;
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("userLogIn", true);
                          prefs.setString("UserId", User_Id);
                          prefs.setString(
                              "User_Name", user.displayName ?? "UnKnown");
                          CreateDocumentFirebaseForGoogle(
                              context,
                              User_Id,
                              user.displayName ?? "UnKnown",
                              user.photoURL ?? "null");
                          User_Name = user.displayName ?? "UnKnown";
                        } else {
                          setState(() {
                            isLoading = false;
                          });
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

                  InkWell(
                    onTap: () {},
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue, width: 0.3),
                        color: Colors.white, // Background color (optional)
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(
                                0.5), // Shadow color with transparency
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  _login() {
    if (_key.currentState?.validate() ?? false) {
      // Perform login logic
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
