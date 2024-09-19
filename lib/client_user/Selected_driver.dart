import 'dart:io';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/client_user/Map-for-Driver.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage import
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class WhichLocation extends StatefulWidget {
  const WhichLocation({super.key});

  @override
  State<WhichLocation> createState() => _WhichLocationState();
}

class _WhichLocationState extends State<WhichLocation> {
  final TextEditingController _startPlaceController = TextEditingController();
  final TextEditingController _endPlaceController = TextEditingController();
  final TextEditingController ContactNo = TextEditingController();
  final TextEditingController Des = TextEditingController();
  final List<String> _cities = [
    // Your cities list goes here...
  ];

  DateTime? _selectedDate;

  // Function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to display selected date
  String _getFormattedDate() {
    if (_selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
    return 'Select Date';
  }

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

  var Upload_Image_Link;
  Future<void> _uploadToFirebaseStorage(File imageFile) async {
    setState(() {
      isLoading = true; // Start loading when upload begins
    });

    try {
      // Get the file name
      String fileName = path.basename(imageFile.path);

      // Create a reference to Firebase Storage
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('Driver/$fileName');

      // Upload the file
      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

      // Get the download URL after the upload is complete
      TaskSnapshot taskSnapshot = await uploadTask;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      User_Profile_Picture = downloadUrl;
      prefs.setString("Profile_Picture", downloadUrl);
      setState(() {
        Upload_Image_Link = downloadUrl;
      });

      // Print the download URL (you can use this URL to display the image later)
      print("Image uploaded! Download URL: $downloadUrl");

      // CollectionReference chatCollection =
      //     FirebaseFirestore.instance.collection('User_Data');
      // String MakeId = '$User_Name $User_Id';

      // await chatCollection
      //     .doc(MakeId)
      //     .update({
      //       'Profile_Pic': downloadUrl,
      //     })
      //     .then((value) => () {
      //           print("Username Added");
      //         })
      //     .catchError(
      //         (error) => print("Failed to add user message count: $error"));

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

  void CreateDocumentFirebase(String to, String from, String name, String Pic,
      String ContactNo, String Description, String time) async {
    print("User name of 0 count:");
    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('Vicahle');
    // String MakeId = '$User_name $User_id';

    await chatCollection
        .doc("$from $to")
        .collection('usersForRide')
        .doc(User_Id)
        .set({
          'Name': name,
          'to': to,
          'from': from,
          'contactNo': ContactNo,
          'image': Pic,
          'description': Description,
          'Time': time
        })
        .then((value) => () {
              print("Username Added");
            })
        .catchError(
            (error) => print("Failed to add user message count: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Travel"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: isLoading
                  ? CircularProgressIndicator() // Show loading indicator when uploading
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _image != null
                            ? Container(
                                height: 200,
                                width: 200,
                                child: Image.file(
                                  _image!, // The file image
                                ),
                              )
                            : InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  child: Image.asset(
                                    "Assets/Images/add_img.png", // Ensure this image exists in your assets folder
                                    // fit: BoxFit
                                    //     .cover, // Optional: fit the image properly within the container
                                  ),
                                ),
                              ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Start Place TextField without suggestions
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: TextFormField(
                      controller: _startPlaceController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'From',
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
                  SizedBox(height: 16.0),

                  // End Place TextField without suggestions
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: TextFormField(
                      controller: _endPlaceController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'To',
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
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: TextFormField(
                      controller: ContactNo,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Contuct No',
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
                  SizedBox(height: 16.0),

                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: TextFormField(
                      controller: Des,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Description',
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
                  SizedBox(height: 16.0),

                  // Date picker button
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _pickDate(context);
                          },
                          icon: Icon(Icons.calendar_today),
                          label: Text(_getFormattedDate()),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.0),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Perform actions when the button is pressed
                          String startPlace = _startPlaceController.text;
                          String endPlace = _endPlaceController.text;
                          DateTime? selectedDate = _selectedDate;

                          // Add logic for handling travel information
                          if (startPlace.isNotEmpty &&
                              endPlace.isNotEmpty &&
                              selectedDate != null) {
                            print("Start Place: $startPlace");
                            print("End Place: $endPlace");
                            print("Selected Date: ${selectedDate.toString()}");
                            CreateDocumentFirebase(
                                _startPlaceController.text,
                                _endPlaceController.text,
                                User_Name,
                                Upload_Image_Link,
                                ContactNo.text,
                                Des.text,
                                _selectedDate.toString());
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DriverRides()),
                            );
                          } else {
                            // Show an alert if any of the required fields are missing
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Please fill all fields and select a date"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text("Submit"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
