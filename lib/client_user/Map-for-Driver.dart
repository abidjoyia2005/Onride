import 'package:flutter/material.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
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
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class DriverRides extends StatefulWidget {
  const DriverRides({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
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
    print("map dispose called...........");
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

      print('map is refersh................');
      updateMapWithNearbyUsers(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 12.0,
          ),
        ),
      );
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
    String gridCell = getGridCell(latitude, longitude);
    print("Curent location Gridcell: $gridCell");

    // Reference to the Firestore collection and document path
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('Vicahle')
        .doc("lahore mianwali")
        .collection('usersForRide')
        .doc(userId);

    // Data to be saved
    Map<String, dynamic> userData = {
      'username': username,
      'Profile_Pic': User_Profile_Picture,
      "time": DateTime.now().toString(),
      'latitude': latitude,
      'longitude': longitude,
    };

    // Save or update the user's location in Firestore
    userDocRef.update(userData).then((_) {
      print('User location saved successfully');
    }).catchError((error) {
      print('Failed to save user location: $error');
    });

    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('grid_cells');

    chatCollection.doc(gridCell).set({
      'User_Name': User_Name,
    });
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
        .where(FieldPath.documentId, isEqualTo: "$fromLocation $toLocation")
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo: "$fromLocation $toLocation")
        .get();

    print('Grid id :${snapshot.docs}');
    if (snapshot.docs.isEmpty) {
      print("HAS NOT USER ON THIS ROUTER........");
      setState(() {
        _markers.clear();
      });
    }

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

        var nowtime = DateTime.now();
        DateTime parsedTime = DateTime.parse(userDoc['time']);
        Duration difference = nowtime.difference(parsedTime);

        setState(() {
          _markers.clear();
        });
        print("Second deferance is ${difference} for  ${userDoc['username']}");

        if (difference.inSeconds < 20) {
          print("User name is ${userDoc['username']}");
          setState(() {
            _loadCustomMarker(
                userDoc['Profile_Pic'] != null
                    ? userDoc['Profile_Pic']
                    : "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/images%2FNo_Dp.jpeg?alt=media&token=5d47c083-d458-493e-9556-f71f516de648",
                userDoc['username'],
                "hello",
                userDoc['latitude'],
                userDoc['longitude']);
          });
        }
      }
    }
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

  Future<void> _loadCustomMarker(
      String image, String Name, String Des, double liti, double longi) async {
    print("maker mak for $Name ");

    final Uint8List markerIcon = await _createCustomMarkerWithTail(
      image,
      70, // image size
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('$Name $liti $longi'),
          position: LatLng(liti, longi), // Your desired position
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(onTap: () {}, snippet: Des, title: Name),
        ),
      );
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
    if (difference.inSeconds < 15) {
      return true;
    } else {
      return false;
    }
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
                      CircularProgressIndicator()) // Show loading indicator while fetching location
              : GoogleMap(
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition?.latitude ?? _initialPosition.latitude,
                      _currentPosition?.longitude ?? _initialPosition.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true, // Enable to show the user's location
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
          Positioned(
            bottom: 80.0, // Adjust position as needed
            left: 15.0, // Adjust position as needed
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              height: 50,
              width: 50,
              child: InkWell(
                onTap: () {
                  // Move the camera to the current location
                },
                child: Container(
                  child: Icon(Icons.chat),
                ),
              ),
            ),
          ),
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
                                    for (var userDoc in BottomSheetData.docs)
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 10, 0),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 15),
                                            userDoc['Profile_Pic'] != null
                                                ? CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(userDoc[
                                                            'Profile_Pic']),
                                                  )
                                                : CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: AssetImage(
                                                        'Assets/Images/No_Dp.jpeg'),
                                                  ),
                                            SizedBox(width: 5),
                                            Text(userDoc['username']),
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
          Fromto ? FromTo() : SelectedFromTo()
        ],
      ),
    );
  }
}

final TextEditingController _startPlace = TextEditingController();
final TextEditingController _endPlace = TextEditingController();
var Fromto = true;
var fromLocation;
var toLocation;

class FromTo extends StatefulWidget {
  const FromTo({super.key});

  @override
  State<FromTo> createState() => _FromToState();
}

class _FromToState extends State<FromTo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24.0, left: 24.0),
            child: TextFormField(
              controller: _startPlace,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'From',
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
          SizedBox(height: 16.0),

          // End Place TextField without suggestions
          Padding(
            padding: const EdgeInsets.only(right: 24.0, left: 24.0),
            child: TextFormField(
              controller: _endPlace,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'To',
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
          SizedBox(
            height: 20,
          ),
          Container(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Primary color for the button
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onPressed: () async {
                setState(() {
                  fromLocation = _startPlace.text;
                  toLocation = _endPlace.text;
                  Fromto = false;
                });
              },
              child: Text(
                'Find Vicale',
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
    );
  }
}

class SelectedFromTo extends StatefulWidget {
  const SelectedFromTo({super.key});

  @override
  State<SelectedFromTo> createState() => _SelectedFromToState();
}

class _SelectedFromToState extends State<SelectedFromTo> {
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
            InkWell(
                onTap: () {
                  setState(() {
                    Fromto = true;
                  });
                },
                child: Icon(Icons.edit)),
            Text(
              fromLocation,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppinssb"),
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
            Text(
              toLocation,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppinssb"),
            )
          ],
        ),
      ),
    );
  }
}
