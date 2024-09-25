import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage import
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePictureScreen extends StatefulWidget {
  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false; // Loading state

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Directly compress the image after picking it
      _cropImage();
    } else {
      // Show a snackbar if no image is selected
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No image selected.')));
    }
  }

  Future<void> _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: _image!.path,
      aspectRatio:
          const CropAspectRatio(ratioX: 1, ratioY: 1), // Set aspect ratio
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Profile Picture',
          lockAspectRatio: true, // Lock aspect ratio to square
        ),
        IOSUiSettings(
          title: 'Adjust Profile Picture',
          aspectRatioLockEnabled: true, // Lock aspect ratio for iOS
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _image =
            File(croppedFile.path); // Convert CroppedFile to File using .path
      });

      // Compress the image
      _compressImage();
    }
  }

  Future<void> _compressImage() async {
    // Read the image file as bytes
    Uint8List imageBytes = await _image!.readAsBytes();

    // Decode the image
    img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage != null) {
      // Resize the image (reduce size) and compress to JPEG format
      img.Image resizedImage =
          img.copyResize(decodedImage, width: 500); // Resize width to 500px

      // Convert to compressed JPEG format with lower quality
      List<int> compressedBytes =
          img.encodeJpg(resizedImage, quality: 70); // Adjust quality

      // Write the compressed image back to the file
      File compressedFile = await _image!.writeAsBytes(compressedBytes);

      // Update the state with the compressed image
      setState(() {
        _image = compressedFile;
      });

      // Upload the compressed image to Firebase Storage
      _uploadToFirebaseStorage(compressedFile);
    }
  }

  Future<void> _uploadToFirebaseStorage(File imageFile) async {
    setState(() {
      isLoading = true; // Start loading when upload begins
    });

    try {
      // Get the file name
      String fileName = path.basename(imageFile.path);

      // Create a reference to Firebase Storage
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('ProfilePic/$fileName');

      // Upload the file
      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

      // Get the download URL after the upload is complete
      TaskSnapshot taskSnapshot = await uploadTask;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      User_Profile_Picture = downloadUrl;
      prefs.setString("Profile_Picture", downloadUrl);
      setState(() {});

      // Print the download URL (you can use this URL to display the image later)
      print("Image uploaded! Download URL: $downloadUrl");

      CollectionReference chatCollection =
          FirebaseFirestore.instance.collection('User_Data');
      String MakeId = '$User_Name $User_Id';

      await chatCollection
          .doc(User_Id)
          .update({
            'Profile_Pic': downloadUrl,
          })
          .then((value) => () {
                print("Username Added");
              })
          .catchError(
              (error) => print("Failed to add user message count: $error"));

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully!')));
    } catch (e) {
      // Show a SnackBar with the error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    } finally {
      setState(() {
        isLoading = false; // Stop loading after upload completes
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Profile Picture"),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading indicator when uploading
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(_image!),
                        )
                      : Icon(Icons.account_circle, size: 160),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("Upload Profile Picture"),
                  ),
                ],
              ),
      ),
    );
  }
}
