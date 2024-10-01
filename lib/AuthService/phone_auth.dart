import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? verificationId;

  // Send OTP
  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text, // e.g. '+92XXXXXXXXXX'
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically handles verification when OTP is detected
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle failure
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID to use in OTP verification
        print("otp send otp is :$verificationId ");
        setState(() {
          this.verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
        setState(() {
          this.verificationId = verificationId;
        });
      },
    );
  }

  // Verify OTP
  Future<void> _signInWithOTP() async {
    final smsCode = _otpController.text;
    if (verificationId != null) {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      try {
        await _auth.signInWithCredential(credential);
        // Successful login
        print("Successfully signed in!");
      } on FirebaseAuthException catch (e) {
        // Handle error
        print("Error: ${e.message}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phone Number Input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+92XXXXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text('Send OTP'),
            ),
            SizedBox(height: 16.0),
            // OTP Input
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signInWithOTP,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
