import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Driver/map_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class Lecense_Scan_Page extends StatefulWidget {
  const Lecense_Scan_Page({super.key});

  @override
  State<Lecense_Scan_Page> createState() => _Lecense_Scan_PageState();
}

class _Lecense_Scan_PageState extends State<Lecense_Scan_Page> {
  @override
  Widget build(BuildContext context) {
    return CNICUploadScreen();
  }
}

class CNICUploadScreen extends StatefulWidget {
  @override
  _CNICUploadScreenState createState() => _CNICUploadScreenState();
}

class _CNICUploadScreenState extends State<CNICUploadScreen> {
  File? frontImage;
  File? backImage;

  final ImagePicker _picker = ImagePicker();

  // Requesting permission for gallery and camera
  Future<bool> _requestGalleryPermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.camera.request();
    }
    return status.isGranted;
  }

  // Show bottom sheet to choose between camera and gallery
  void _showImageSourceBottomSheet(
      Function(ImageSource) onImageSourceSelected) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Handle image picking for front side
  Future<void> _pickImageFront() async {
    if (await _requestGalleryPermission() || await _requestCameraPermission()) {
      _showImageSourceBottomSheet((source) async {
        final pickedFile = await _picker.pickImage(source: source);
        setState(() {
          if (pickedFile != null) {
            frontImage = File(pickedFile.path);
          }
        });
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  // Handle image picking for back side
  Future<void> _pickImageBack() async {
    if (await _requestGalleryPermission() || await _requestCameraPermission()) {
      _showImageSourceBottomSheet((source) async {
        final pickedFile = await _picker.pickImage(source: source);
        setState(() {
          if (pickedFile != null) {
            backImage = File(pickedFile.path);
          }
        });
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  // Handle permission denied cases
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
            'This app needs gallery and camera permissions to upload your CNIC.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload CNIC'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImageFront,
              child: Card(
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      frontImage == null
                          ? Image.asset(
                              'Assets/Vicale_images/driving-license.png',
                              height: 150,
                              width: 350,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              frontImage!,
                              height: 150,
                              width: 350,
                              fit: BoxFit.cover,
                            ),
                      SizedBox(height: 10),
                      frontImage == null
                          ? Text('Upload CNIC Front',
                              style: TextStyle(fontSize: 16))
                          : Text('CNIC Front', style: TextStyle(fontSize: 16))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImageBack,
              child: Card(
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      backImage == null
                          ? Image.asset(
                              'Assets/Vicale_images/driving-license.png',
                              height: 150,
                              width: 350,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              backImage!,
                              height: 150,
                              width: 350,
                              fit: BoxFit.cover,
                            ),
                      SizedBox(height: 10),
                      backImage == null
                          ? Text('Upload CNIC Back',
                              style: TextStyle(fontSize: 16))
                          : Text('CNIC Back', style: TextStyle(fontSize: 16))
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaoScreen(),
                    ));
                if (frontImage != null && backImage != null) {
                  // Handle form submission here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CNIC Uploaded Successfully!')),
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaoScreen(),
                      ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please upload both front and back images')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
