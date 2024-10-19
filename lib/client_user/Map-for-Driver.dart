import 'package:flutter/material.dart';
import 'package:flutter_application_1/chatsystem/GroupChat.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:flutter_application_1/loading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/Driver/profile_screen.dart';
import 'package:flutter_application_1/Ini_setup/Splash_Screen.dart';
import 'package:flutter_application_1/client_user/Selected_driver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class DriverRides extends StatefulWidget {
  var descrip;
  DriverRides({this.descrip});
  @override
  State<DriverRides> createState() => _DriverRidesState();
}

class _DriverRidesState extends State<DriverRides> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default position
  late GoogleMapController _mapController;
  Position? _currentPosition;
  bool loadMap = true;

  // Circle for radar animation
  Circle? _radarCircle;
  double _currentRadius = 0; // Starting radius of the radar

  double _maxRadius = 8000; // Maximum radius (100 km)
  Timer? _radarTimer; // Timer for radar animation

  // Set of markers to be displayed on the map
  Set<Marker> _markers = {};

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getPermissionStatusMessage(status),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _getSnackbarColor(status),
        ),
      );
    }
  }

  String _getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.denied:
        return 'Location permission denied. Please enable it in settings.';
      case PermissionStatus.permanentlyDenied:
        return 'Location permission permanently denied. Please enable it in settings.';
      case PermissionStatus.restricted:
        return 'Location permission restricted.';
      case PermissionStatus.limited:
        return 'Location permission limited.';
      default:
        return "";
    }
  }

  var BottomSheetData;

  Color _getSnackbarColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        return Colors.red;
      case PermissionStatus.permanentlyDenied:
        return Colors.orange;
      default:
        return Colors.white10;
    }
  }

  void saveDescriptin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.descrip != null) {
      Descraption.text = widget.descrip;
      prefs.setString("DescriptionForDriver", widget.descrip);
    } else {
      Descraption.text = prefs.getString("DescriptionForDriver") ?? " ";
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMapStyle();
    saveDescriptin();

    _requestLocationPermission();
    _radarTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _getCurrentLocation(); // Get user's location
    });
  }

  String? _jsonData = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
''';
  Completer<GoogleMapController> _controller = Completer();
  Future<void> _loadMapStyle() async {
    final controller = await _controller.future;
    controller.setMapStyle(_jsonData);
  }

  @override
  void dispose() {
    print("map To From dispose called...........");
    _radarTimer
        ?.cancel(); // Cancel the radar animation when the widget is disposed
    super.dispose();
  }

  // Method to fetch user location
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        print("Postion is $position");
        _currentPosition = position;
        loadMap = false;
        _radarCircle = Circle(
          circleId: CircleId("radar_circle"),
          center: LatLng(position.latitude, position.longitude),
          radius: _currentRadius,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeWidth: 0,
        );
      });
      // Move the camera to the user's current location
      saveUserLocation(
        User_Id, // Replace with actual user ID
        User_Name, // Replace with actual username
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Update the map with nearby users

      print('map to from is refersh................');
      updateMapWithNearbyUsers(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // _mapController.animateCamera(
      //   CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //       target:
      //           LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      //       zoom: 12.0,
      //     ),
      //   ),
      // );
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Method to start the radar animation

  // Method to get grid cell ID based on latitude and longitude
  String getGridCell(double latitude, double longitude) {
    double cellSize = 8.0; // 3 km
    int latIndex = (latitude / cellSize).floor();
    int lngIndex = (longitude / cellSize).floor();
    return 'grid_${latIndex}_${lngIndex}';
  }

  // Save user location to Firestore
  void saveUserLocation(
      String userId, String username, double latitude, double longitude) {
    // Determine the grid cell based on the user's location

    print("Curent location from to: $From $To ");

    // Reference to the Firestore collection and document path
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Vicahle')
        .doc("$From $To")
        .collection('usersForRide')
        .doc(userId);

    // Data to be saved
    Map<String, dynamic> userData = {
      'username': username,
      'image': Has_Driver_Acount ? Vicale_Type : User_Profile_Picture,
      "time": DateTime.now().toString(),
      'latitude': latitude,
      'longitude': longitude,
      'Description': Descraption.text
    };

    // Save or update the user's location in Firestore
    userDocRef.set(userData, SetOptions(merge: true)).then((_) {
      print('User location saved successfully');
    }).catchError((error) {
      print('Failed to save user location: $error');
    });

    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('Vicahle');

    chatCollection.doc("$From $To").set({
      'User_Name': User_Name,
    }, SetOptions(merge: true));
  }

  // Fetch users within a 3x3 km area and update the map
  Future<void> updateMapWithNearbyUsers(
      double latitude, double longitude) async {
    await getUsersInArea(latitude, longitude);
    setState(() {
      // _markers.add(Marker(
      //   markerId: MarkerId('currentLocation'),
      //   position: LatLng(latitude, longitude),
      //   infoWindow: InfoWindow(title: "You"),
      // ));
    });
  }

  // Retrieve users from Firestore and add markers to the map
  var defTime;
  Future<void> getUsersInArea(double latitude, double lngtude) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Vicahle')
        .where(FieldPath.documentId, isEqualTo: "$From $To")
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: "$From $To")
        .get();

    print('Grid id :${snapshot.docs}');
    if (snapshot.docs.isEmpty) {
      print("HAS NOT USER ON THIS ROUTER........");
      // setState(() {
      //   _markers.clear();
      // });
    }
    List<Map<String, dynamic>> allUsersData =
        []; // Create a list to store all users

    for (var doc in snapshot.docs) {
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('Vicahle')
          .doc(doc.id)
          .collection('usersForRide');

      QuerySnapshot usersSnapshot = await usersCollection.get();
      if (snapshot.docs.isNotEmpty) {
        BottomSheetData = usersSnapshot;
        setState(() {});
      } else {
        BottomSheetData = null;
        setState(() {});
      }

      for (var userDoc in usersSnapshot.docs) {
        print('users data:${userDoc.data()}');
        // Add user data to the list
        allUsersData.add(userDoc.data() as Map<String, dynamic>);

        var nowtime = DateTime.now();
        DateTime parsedTime = DateTime.parse(userDoc['time']);
        Duration difference = nowtime.difference(parsedTime);

        // setState(() {
        //   _markers.clear();
        // });
        print("Second deferance is ${difference} for  ${userDoc['username']}");

        if (difference.inSeconds < 25) {
          print("User name is ${userDoc['username']}");

          setState(() {
            _loadCustomMarker(
                userDoc['image'] != null
                    ? userDoc['image']
                    : "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/images%2FNo_Dp.jpeg?alt=media&token=5d47c083-d458-493e-9556-f71f516de648",
                userDoc['username'],
                userDoc['Description'],
                userDoc['latitude'],
                userDoc['longitude']);
          });
        }
      }
    }
    // Now BottomSheetData contains all users
    setState(() {
      BottomSheetData =
          sortUsersByTime(allUsersData); // Store accumulated users data
    });
  }

  List<Map<String, dynamic>> sortUsersByTime(
      List<Map<String, dynamic>> usersData) {
    // Sort the list based on 'parsedTime', with most recent at the top
    usersData.sort((a, b) => b['time'].compareTo(a['time']));
    return usersData; // Return the sorted list
  }

  DateTime parseTimestamp(String timestamp) {
    // Extract seconds and nanoseconds
    RegExp regExp = RegExp(r'Timestamp\(seconds=(\d+), nanoseconds=(\d+)\)');
    Match match = regExp.firstMatch(timestamp)!;

    int seconds = int.parse(match.group(1)!);
    int nanoseconds = int.parse(match.group(2)!);

    // Convert to milliseconds
    int milliseconds = seconds * 1000 + nanoseconds ~/ 1000000;

    // Create DateTime object
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }

  var preliti;
  var prelongi;

  Future<void> _loadCustomMarker(
      String image, String Name, String Des, double liti, double longi) async {
    print("maker mak for $Name ");

    final Uint8List markerIcon = await _createCustomMarkerWithTail(
      image,
      70, // image size
    );

    setState(() {
      // Remove the existing marker with the same MarkerId
      for (int i = 0; i < 5; i++) {
        _markers
            .removeWhere((marker) => marker.markerId.value == '$Name $image');
      }

      _markers.add(
        Marker(
          markerId: MarkerId('$Name $image'),
          position: LatLng(liti, longi), // Your desired position
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(onTap: () {}, snippet: "📍 $Des", title: Name),
        ),
      );
      preliti = liti;
      prelongi = longi;
    });
  }

  Future<Uint8List> _createCustomMarkerWithTail(
      String imageUrl, int size) async {
    // Use CachedNetworkImageProvider to handle caching
    final CachedNetworkImageProvider imageProvider =
        CachedNetworkImageProvider(imageUrl);

    final Completer<ui.Image> completer = Completer();
    final ImageStream stream = imageProvider.resolve(
        ImageConfiguration(size: Size(size.toDouble(), size.toDouble())));
    final ImageStreamListener listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info.image);
    });

    stream.addListener(listener);
    final ui.Image image = await completer.future;
    stream.removeListener(listener);

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = Colors.blue;

    final double circleRadius = size / 2.0;
    final double tailHeight = size / 3.0;

    // Draw the circle (profile picture background)
    final Rect circleRect = Rect.fromCircle(
        center: Offset(circleRadius, circleRadius), radius: circleRadius);
    canvas.drawCircle(Offset(circleRadius, circleRadius), circleRadius, paint);

    // Clip the canvas to circular shape and draw the image inside the circle
    canvas.clipPath(Path()..addOval(circleRect));
    paintImage(
      canvas: canvas,
      rect: circleRect,
      image: image,
      fit: BoxFit.cover,
    );

    // Draw the triangle tail at the bottom
    final Path tailPath = Path();
    tailPath.moveTo(circleRadius - circleRadius / 3, size.toDouble());
    tailPath.lineTo(circleRadius + circleRadius / 3, size.toDouble());
    tailPath.lineTo(circleRadius, size.toDouble() + tailHeight);
    tailPath.close();

    canvas.drawPath(tailPath, paint);

    // Finalize the drawing
    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage =
        await picture.toImage(size, (size + tailHeight).toInt());
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  var drawer = false;
  var live = true;

  bool Timedef(String Time) {
    var nowtime = DateTime.now();
    DateTime parsedTime = DateTime.parse(Time);
    Duration difference = nowtime.difference(parsedTime);
    if (difference.inSeconds < 25) {
      return true;
    } else {
      return false;
    }
  }

  void Movecamra(var Lat, var log) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(Lat, log),
          zoom: 18.0,
        ),
      ),
    );
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    // Calculate the distance in meters
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);

    // Convert the distance to kilometers
    double distanceInKilometers = distanceInMeters / 1000;

    double roundedDistance =
        double.parse(distanceInKilometers.toStringAsFixed(1));

    return roundedDistance;
  }

  TextEditingController Descraption = TextEditingController();
  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            icon: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                    width: 150,
                    height: 150,
                    child: Image.asset("Assets/Images/consulting.gif"))),
            title: Text(
              "Describe where you're going or the destination.",
              style: TextStyle(
                  fontFamily: "Sofia",
                  fontWeight: FontWeight.w200,
                  fontSize: 16.0,
                  color: Colors.black),
            ),
            content: Padding(
              padding: const EdgeInsets.only(right: 24.0, left: 24.0),
              child: TextFormField(
                controller: Descraption,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Destination Location Name',
                  labelStyle: TextStyle(fontSize: 11),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                height: 35,
                width: 90,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.amber, // Primary color for the button
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () async {
                    print("User input: ${Descraption.text}");
                    Navigator.of(context).pop(); // Close the alert dialog
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color white
                    ),
                  ),
                ),
              ),
              Spacer(),

              /// Signup button
              Container(
                height: 35,
                width: 90,
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
                    setState(() {});
                    // Handle the button press
                    print("User input: ${Descraption.text}");
                    Navigator.of(context).pop(); // Close the alert dialog
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color white
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: CustomDrawer(),
      body: Stack(
        children: [
          loadMap
              ? Center(
                  child:
                      LoadingGif()) // Show loading indicator while fetching location
              : GoogleMap(
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition?.latitude ?? _initialPosition.latitude,
                      _currentPosition?.longitude ?? _initialPosition.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  myLocationEnabled:
                      false, // Enable to show the user's location
                  myLocationButtonEnabled: false, // Disable default button
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _mapController = controller;
                    if (_currentPosition != null) {
                      _mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            zoom: 8.2,
                          ),
                        ),
                      );
                    }
                  },
                  circles: _radarCircle != null ? {_radarCircle!} : {},
                  markers: _markers, // Add markers to the map
                ),
          if (!Has_Driver_Acount)
            Positioned(
              right: 12,
              top: 90,
              child: InkWell(
                onTap: () {
                  showAlertDialog(context);
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 1, // How wide the shadow spreads
                        blurRadius: 3, // Softness of the shadow
                        offset: Offset(0, 2), // Positioning of the shadow
                      ),
                    ],
                  ),
                  child: Image.asset("Assets/Images/consulting.gif"),
                ),
              ),
            ),
          Positioned(
            right: 12,
            top: 138,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupFromTo(
                              hasFromTo: "$From $To",
                            )));
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 1, // How wide the shadow spreads
                      blurRadius: 3, // Softness of the shadow
                      offset: Offset(0, 2), // Positioning of the shadow
                    ),
                  ],
                ),
                child: Image.asset("Assets/gifs/group.gif"),
              ),
            ),
          ),
          Positioned(
            bottom: 80.0, // Adjust position as needed
            right: 15.0, // Adjust position as needed
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              height: 50,
              width: 50,
              child: InkWell(
                onTap: () {
                  // Move the camera to the current location
                  if (_currentPosition != null) {
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 14.0,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  child: Icon(Icons.my_location),
                ),
              ),
            ),
          ),
          // Positioned(
          //   bottom: 80.0, // Adjust position as needed
          //   left: 15.0, // Adjust position as needed
          //   child: Container(
          //     decoration: BoxDecoration(
          //         color: Colors.white60,
          //         borderRadius: BorderRadius.all(Radius.circular(16))),
          //     height: 50,
          //     width: 50,
          //     child: InkWell(
          //       onTap: () {

          //       },
          //       child: Container(
          //         child: Icon(Icons.chat),
          //       ),
          //     ),
          //   ),
          // ),
          DraggableScrollableSheet(
            initialChildSize:
                0.1, // Show only 1 row initially (10% of the screen)
            minChildSize: 0.1, // Minimum size when dragged down
            maxChildSize: 0.5, // Maximum size when fully expanded
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15.0,
                      spreadRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: BottomSheetData != null
                              ? Column(
                                  children: [
                                    for (var userDoc in BottomSheetData)
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 10, 0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 15),
                                            userDoc['image'] != null
                                                ? CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            userDoc['image']),
                                                  )
                                                : CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: AssetImage(
                                                        'Assets/Images/No_Dp.jpeg'),
                                                  ),
                                            SizedBox(width: 5),
                                            Text(
                                              userDoc['username'].length > 15
                                                  ? '${userDoc['username'].substring(0, 13)}...'
                                                  : userDoc['username'],
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Spacer(),
                                            Timedef(userDoc['time'])
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Movecamra(
                                                        userDoc['latitude'],
                                                        userDoc['longitude'],
                                                      );
                                                    },
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            25)),
                                                            border: Border.all(
                                                                width: 3,
                                                                color: Color(
                                                                    0xFF319AFF))),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      5),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .location_history_outlined,
                                                                color: Color(
                                                                    0xFF319AFF),
                                                                size: 18,
                                                              ),
                                                              Text(
                                                                "${calculateDistance(userDoc['latitude'], userDoc['longitude'], _currentPosition!.latitude, _currentPosition!.longitude)} KM",
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF319AFF),
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800),
                                                              ),
                                                            ],
                                                          ),
                                                        )))
                                                : GestureDetector(
                                                    onTap: () {
                                                      Movecamra(
                                                        userDoc['latitude'],
                                                        userDoc['longitude'],
                                                      );
                                                    },
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.all(
                                                                        Radius.circular(
                                                                            25)),
                                                                border:
                                                                    Border.all(
                                                                  width: 1.5,
                                                                  color: Colors
                                                                          .grey[
                                                                      400]!,
                                                                )),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      5),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .location_history_outlined,
                                                                color: Colors
                                                                    .grey[400],
                                                                size: 18,
                                                              ),
                                                              Text(
                                                                "${calculateDistance(userDoc['latitude'], userDoc['longitude'], _currentPosition!.latitude, _currentPosition!.longitude)} KM",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        400],
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800),
                                                              ),
                                                            ],
                                                          ),
                                                        ))),
                                            Spacer(),
                                            if (Timedef(userDoc['time']))
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    radius: 5,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "Live",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              )
                                            else
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.black54,
                                                    radius: 5,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "Offline",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              )
                                          ],
                                        ),
                                      ),
                                  ],
                                )
                              : Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Shimmer for CircleAvatar (Profile Image)
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey[
                                                  300], // Placeholder for avatar
                                            ),
                                            SizedBox(width: 5),
                                            // Shimmer for Name Text
                                            Container(
                                              width:
                                                  100, // Adjust width according to your text length
                                              height:
                                                  15, // Adjust height for the text
                                              color: Colors.grey[
                                                  300], // Placeholder for name
                                            ),
                                            Spacer(),
                                            // Shimmer for live indicator
                                            CircleAvatar(
                                              backgroundColor: Colors.grey[
                                                  300], // Placeholder for live dot
                                              radius: 5,
                                            ),
                                            SizedBox(width: 5),
                                            Container(
                                              width:
                                                  40, // Adjust width for the "Live" text
                                              height:
                                                  15, // Adjust height for the text
                                              color: Colors.grey[
                                                  300], // Placeholder for live text
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                    ),
                  ],
                ),
              );
            },
          ),
          SelectedFromTo(
            from: From,
            to: To,
          )
        ],
      ),
    );
  }
}

class SelectedFromTo extends StatefulWidget {
  var from;
  var to;
  SelectedFromTo({required this.from, required this.to});

  @override
  State<SelectedFromTo> createState() => _SelectedFromToState();
}

class _SelectedFromToState extends State<SelectedFromTo> {
// Function to remove a token from the array
  void removeTokenFromFirebase(String tokenToRemove) async {
    // Create a Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the collection and document
    DocumentReference harnoliDocument =
        firestore.collection('Vicahle').doc('$From $To');

    try {
      // Check if the document exists
      DocumentSnapshot docSnapshot = await harnoliDocument.get();

      if (docSnapshot.exists) {
        // If the document exists, remove the token from the 'tokens' array
        await harnoliDocument.update({
          'tokens': FieldValue.arrayRemove([tokenToRemove]),
        });
        print('Token removed successfully.');
      } else {
        print('Document does not exist. No token to remove.');
      }
    } catch (e) {
      print('Error removing token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)), // Border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
            spreadRadius: 2, // How much the shadow should spread
            blurRadius: 5, // Softness of the shadow
            offset:
                Offset(0, 3), // Horizontal and Vertical position of the shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 15,
            ),
            InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UberMap()),
                  );
                },
                child: Icon(
                  Icons.arrow_back_rounded,
                )),
            Spacer(),
            InkWell(
              onTap: () async {
                // Show the confirmation dialog
                bool? isConfirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      // title: Text('Confirm Change'),
                      content: Text(
                          'Are you sure you want to change From & To Place?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Dismiss dialog and return false
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Dismiss dialog and return true
                          },
                        ),
                      ],
                    );
                  },
                );

                // If the user confirmed, execute the existing code
                if (isConfirmed == true) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    prefs.remove("Has_From_To");
                    prefs.remove("DescriptionForDriver");
                    Has_From_To = false;
                  });
                  removeTokenFromFirebase(FCMToken);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UberMap()),
                  );
                }
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: Colors.black, // Set your desired border color
                    width: 2.0, // Set the border width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // Spread radius of the shadow
                      blurRadius: 5, // Blur radius of the shadow
                      offset: Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.from.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppinssb",
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "To",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () async {
                // Show the confirmation dialog
                bool? isConfirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      // title: Text('Confirm Change'),
                      content: Text(
                          'Are you sure you want to change From & To Place?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Dismiss dialog and return false
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Dismiss dialog and return true
                          },
                        ),
                      ],
                    );
                  },
                );

                // If the user confirmed, execute the existing code
                if (isConfirmed == true) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    prefs.remove("Has_From_To");
                    prefs.remove("DescriptionForDriver");
                    Has_From_To = false;
                  });
                  removeTokenFromFirebase(FCMToken);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UberMap()),
                  );
                }
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: Colors.black, // Set your desired border color
                    width: 2.0, // Set the border width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      spreadRadius: 2, // Spread radius of the shadow
                      blurRadius: 5, // Blur radius of the shadow
                      offset: Offset(0, 3), // Offset of the shadow (x, y)
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.to.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppinssb",
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            InkWell(
                onTap: () async {
                  // Show the confirmation dialog
                  bool? isConfirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        // title: Text('Confirm Change'),
                        content: Text(
                            'Are you sure you want to change From & To Place?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop(
                                  false); // Dismiss dialog and return false
                            },
                          ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(true); // Dismiss dialog and return true
                            },
                          ),
                        ],
                      );
                    },
                  );

                  // If the user confirmed, execute the existing code
                  if (isConfirmed == true) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    setState(() {
                      prefs.remove("Has_From_To");
                      prefs.remove("DescriptionForDriver");
                      Has_From_To = false;
                    });
                    removeTokenFromFirebase(FCMToken);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => UberMap()),
                    );
                  }
                },
                child: Image.asset("Assets/icons/change.png")),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
