import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/Driver/Choice_Device.dart';
import 'package:flutter_application_1/Driver/profile_screen.dart';
import 'package:flutter_application_1/Ini_setup/Splash_Screen.dart';
import 'package:flutter_application_1/client_user/FromTo.dart';
import 'package:flutter_application_1/client_user/Map-for-Driver.dart';
import 'package:flutter_application_1/client_user/Selected_driver.dart';
import 'package:flutter_application_1/client_user/list_ride.dart';
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

class UberMap extends StatefulWidget {
  const UberMap({super.key});

  @override
  State<UberMap> createState() => _UberMapState();
}

class _UberMapState extends State<UberMap> {
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

  var BottomSheetData;
  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _requestLocationPermission();
    _radarTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _getCurrentLocation(); // Get user's location
    });

    _startRadarAnimation(); // Start radar animation
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

  void GoOffline() async {
    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('User_Data');
    String MakeId = '$User_Name $User_Id';

    await chatCollection
        .doc(MakeId)
        .set({
          'Offline': true,
        })
        .then((value) => () {
              print("Username Added");
            })
        .catchError(
            (error) => print("Failed to add user message count: $error"));
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

  // Method to start the radar animation
  void _startRadarAnimation() {
    _radarTimer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
      setState(() {
        _currentRadius += 100; // Increase the radius by 100 meters per frame

        // Reset the radius once it exceeds the maximum (3 km)
        if (_currentRadius > _maxRadius) {
          _currentRadius = 0;
        }

        if (_currentPosition != null) {
          _radarCircle = Circle(
            circleId: CircleId("radar_circle"),
            center:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            radius: _currentRadius,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeWidth: 0,
          );
        }
      });
    });
  }

  // Method to get grid cell ID based on latitude and longitude
  String getGridCell(double latitude, double longitude) {
    // 8 km in degrees for latitude
    double latCellSize = 8.0 / 111.32; // ~ 0.072 degrees

    // 8 km in degrees for longitude, adjusted by latitude
    double lngCellSize = 8.0 / (111.32 * cos(latitude * pi / 180));

    // Calculate the indices for latitude and longitude grid
    int latIndex = (latitude / latCellSize).floor();
    int lngIndex = (longitude / lngCellSize).floor();

    // Return the grid cell identifier
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
        .collection('grid_cells')
        .doc(gridCell)
        .collection('users')
        .doc(userId);

    // Data to be saved
    Map<String, dynamic> userData = {
      'username': username,
      'Profile_Pic': Has_Driver_Acount ? Vicale_Type : User_Profile_Picture,
      "time": DateTime.now().toString(),
      'latitude': latitude,
      'longitude': longitude,
      'Description': Descraption.text
    };

    // Save or update the user's location in Firestore
    userDocRef.set(userData).then((_) {
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
    double lat1 = latitude - 0.072;
    double lng1 = longitude - 0.072;
    double lat2 = latitude + 0.072;
    double lng2 = longitude + 0.072;

    await getUsersInArea(lat1, lng1, lat2, lng2);
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
  Future<void> getUsersInArea(
      double lat1, double lng1, double lat2, double lng2) async {
    String startGridCell = getGridCell(lat1, lng1);
    String endGridCell = getGridCell(lat2, lng2);
    print("start :$startGridCell   end:$endGridCell");

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('grid_cells')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startGridCell)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endGridCell)
        .get();

    print('Grid id :${snapshot.docs}');

    for (var doc in snapshot.docs) {
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('grid_cells')
          .doc(doc.id)
          .collection('users');

      QuerySnapshot usersSnapshot = await usersCollection.get();
      BottomSheetData = usersSnapshot;
      setState(() {});

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
                userDoc['Description'] ?? "No has Location",
                userDoc['latitude'],
                userDoc['longitude']);
          });
        }
      }
    }
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
                    child: Image.asset("Assets/Images/send.png"))),
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
      90, // image size
    );

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('$Name $liti $longi'),
          position: LatLng(liti, longi), // Your desired position
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(
              onTap: () {
                // Show the alert dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.zero, // Remove default padding
                      content: SingleChildScrollView(
                        child: RideWidget(
                          fromPlace: "mianwali",
                          toPlace: "islamabad",
                          rideStatus: "good",
                          dateTime: DateTime.now(),
                          fare: "1500", // Example fare
                        ),
                      ),
                    );
                  },
                );
              },
              snippet: Des,
              title: Name),
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          loadMap
              ? Center(
                  child:
                      CircularProgressIndicator()) // Show loading indicator while fetching location
              : GoogleMap(
                  // mapType: MapType.hybrid,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition?.latitude ?? _initialPosition.latitude,
                      _currentPosition?.longitude ?? _initialPosition.longitude,
                    ),
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true, // Enable to show the user's location
                  myLocationButtonEnabled: true,
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
                  circles: _radarCircle != null
                      ? {_radarCircle!}
                      : {}, // Display the radar circle
                  markers: _markers, // Add markers to the map
                ),
          Positioned(
            top: 20,
            left: 20,
            child: InkWell(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer(); // Open the drawer
              },
              child: Icon(
                Icons.menu,
                size: 40,
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 60,
            child: InkWell(
              onTap: () {
                if (Has_Driver_Acount) {
                  if (Has_From_To) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverRides(),
                        ));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhichLocation(),
                        ));
                  }
                } else {
                  if (Has_From_To) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverRides(),
                        ));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FromtoPage(),
                        ));
                  }
                }
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
                child: Image.asset("Assets/Images/maplocation.png"),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 110,
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
                child: Image.asset("Assets/Images/userLocation.png"),
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
                                            GestureDetector(
                                              onTap: () {
                                                Movecamra(
                                                  userDoc['latitude'],
                                                  userDoc['longitude'],
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .location_history_outlined,
                                                    color: Colors.grey[400],
                                                    size: 18,
                                                  ),
                                                  Text(
                                                    "${calculateDistance(userDoc['latitude'], userDoc['longitude'], _currentPosition!.latitude, _currentPosition!.longitude)} KM",
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                ],
                                              ),
                                            ),
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
        ],
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Has_Driver_Acount
              ? Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Column(
                    children: [
                      // Profile Picture
                      User_Profile_Picture != null
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Vichale_cHOSE(),
                                    ));
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(Vicale_Type),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .blue, // You can change the color to fit your design
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Vichale_cHOSE(),
                                    ));
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        AssetImage('Assets/Images/No_Dp.jpeg'),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .blue, // You can change the color to fit your design
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(height: 15),
                      // Username
                      Text(
                        User_Name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Column(
                    children: [
                      // Profile Picture
                      User_Profile_Picture != null
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePictureScreen(),
                                    ));
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        NetworkImage(User_Profile_Picture),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .blue, // You can change the color to fit your design
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePictureScreen(),
                                    ));
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        AssetImage('Assets/Images/No_Dp.jpeg'),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .blue, // You can change the color to fit your design
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(height: 15),
                      // Username
                      Text(
                        User_Name,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
          _buildListTile(
            context,
            isSelected: false,
            icon: CupertinoIcons.home,
            title: 'Home',
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.abc,
            title: 'Orders',
            isSelected: false,
            onTap: () {},
          ),
          Visibility(
            visible: false,
            child: _buildListTile(
              context,
              icon: Icons.account_balance_wallet_sharp,
              title: 'Wallet',
              isSelected: false,
              onTap: () {},
            ),
          ),
          _buildListTile(
            context,
            icon: Icons.account_balance,
            title: 'Bank Details',
            isSelected: false,
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: CupertinoIcons.person,
            title: 'Profile',
            isSelected: false,
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'Language',
            isSelected: false,
            onTap: () {},
          ),
          _buildListTile(
            context,
            icon: CupertinoIcons.chat_bubble_2_fill,
            title: 'Inbox',
            isSelected: false,
            onTap: () {},
          ),
          _buildListTile(
            isSelected: false,
            context,
            icon: Icons.policy,
            title: 'Terms and Condition',
            onTap: () {},
          ),
          _buildListTile(
            isSelected: false,
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy policy',
            onTap: () {},
          ),
          _buildListTile(
            isSelected: false,
            context,
            icon: Icons.logout,
            title: 'Log out',
            onTap: () async {
              AuthService authService = AuthService();

              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData? icon,
      required String title,
      required bool isSelected,
      required VoidCallback onTap,
      Widget? leading}) {
    return ListTileTheme(
      style: ListTileStyle.drawer,
      selectedColor: Colors.white,
      child: ListTile(
        selected: isSelected,
        leading: leading ?? Icon(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}

class ModernTikTokDrawer extends StatelessWidget {
  final String userName;
  final String userProfileUrl;

  ModernTikTokDrawer({required this.userName, required this.userProfileUrl});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 230,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white60,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header section with user info
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  // Profile Picture
                  User_Profile_Picture != null
                      ? InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePictureScreen(),
                                ));
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    NetworkImage(User_Profile_Picture),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blue, // You can change the color to fit your design
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePictureScreen(),
                                ));
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    AssetImage('Assets/Images/No_Dp.jpeg'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .blue, // You can change the color to fit your design
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(height: 15),
                  // Username
                  Text(
                    User_Name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.black45, thickness: 0.5),

            // Options list
            Expanded(
              child: ListView(
                children: [
                  // Terms and Conditions
                  _buildDrawerOption(
                    iconColor: Colors.black,
                    icon: Icons.security_rounded,
                    title: 'Terms and Conditions',
                    onTap: () {
                      // Handle Terms and Conditions navigation
                    },
                  ),
                  Icon(
                    CupertinoIcons.photo_fill_on_rectangle_fill,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  // Privacy Policy
                  _buildDrawerOption(
                    icon: Icons.privacy_tip_rounded,
                    title: 'Privacy Policy',
                    onTap: () {
                      // Handle Privacy Policy navigation
                    },
                  ),
                  // Delete Account
                  _buildDrawerOption(
                    icon: Icons.delete_forever_rounded,
                    title: 'Delete Account',
                    iconColor: Colors.blue,
                    onTap: () {
                      // Handle account deletion
                    },
                  ),
                  // Logout
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 35,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Log Out",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: "Poppinsm",
                            fontWeight: FontWeight.w700,
                            fontSize: 19),
                      )
                    ],
                  )
                ],
              ),
            ),
            // Footer with a small logo or additional text
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                'App version 1.0.0',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create modern drawer options
  Widget _buildDrawerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}





// for 3km code 
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/AuthService/Email_Auth.dart';
// import 'package:flutter_application_1/Driver/profile_screen.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:http/http.dart' as http;
// import 'dart:typed_data';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:intl/intl.dart';

// class UberMap extends StatefulWidget {
//   const UberMap({super.key});

//   @override
//   State<UberMap> createState() => _UberMapState();
// }

// class _UberMapState extends State<UberMap> {
//   LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default position
//   late GoogleMapController _mapController;
//   Position? _currentPosition;
//   bool loadMap = true;

//   // Circle for radar animation
//   Circle? _radarCircle;
//   double _currentRadius = 0; // Starting radius of the radar

//   double _maxRadius = 8000; // Maximum radius (100 km)
//   Timer? _radarTimer; // Timer for radar animation

//   // Set of markers to be displayed on the map
//   Set<Marker> _markers = {};

//   Future<void> _requestLocationPermission() async {
//     final status = await Permission.location.request();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _getPermissionStatusMessage(status),
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: _getSnackbarColor(status),
//       ),
//     );
//   }

//   String _getPermissionStatusMessage(PermissionStatus status) {
//     switch (status) {
//       case PermissionStatus.denied:
//         return 'Location permission denied. Please enable it in settings.';
//       case PermissionStatus.permanentlyDenied:
//         return 'Location permission permanently denied. Please enable it in settings.';
//       case PermissionStatus.restricted:
//         return 'Location permission restricted.';
//       case PermissionStatus.limited:
//         return 'Location permission limited.';
//       default:
//         return'';
//     }
//   }

//   Color _getSnackbarColor(PermissionStatus status) {
//     switch (status) {
//       case PermissionStatus.granted:
//         return Colors.green;
//       case PermissionStatus.denied:
//       case PermissionStatus.restricted:
//       case PermissionStatus.limited:
//         return Colors.red;
//       case PermissionStatus.permanentlyDenied:
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   var BottomSheetData;
//   @override
//   void initState() {
//     super.initState();
//     _requestLocationPermission();
//     _radarTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
//       _getCurrentLocation(); // Get user's location
//     });

//     _startRadarAnimation(); // Start radar animation
//   }

//   @override
//   void dispose() {
//     print("map dispose called...........");
//     _radarTimer
//         ?.cancel(); // Cancel the radar animation when the widget is disposed
//     super.dispose();
//   }

//   void GoOffline() async {
//     CollectionReference chatCollection =
//         FirebaseFirestore.instance.collection('User_Data');
//     String MakeId = '$User_Name $User_Id';

//     await chatCollection
//         .doc(MakeId)
//         .set({
//           'Offline': true,
//         })
//         .then((value) => () {
//               print("Username Added");
//             })
//         .catchError(
//             (error) => print("Failed to add user message count: $error"));
//   }

//   // Method to fetch user location
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         print("Postion is $position");
//         _currentPosition = position;
//         loadMap = false;
//         _radarCircle = Circle(
//           circleId: CircleId("radar_circle"),
//           center: LatLng(position.latitude, position.longitude),
//           radius: _currentRadius,
//           fillColor: Colors.blue.withOpacity(0.2),
//           strokeWidth: 0,
//         );
//       });
//       // Move the camera to the user's current location
//       saveUserLocation(
//         User_Id, // Replace with actual user ID
//         User_Name, // Replace with actual username
//         _currentPosition!.latitude,
//         _currentPosition!.longitude,
//       );

//       // Update the map with nearby users

//       print('map is refersh................');
//       updateMapWithNearbyUsers(
//         _currentPosition!.latitude,
//         _currentPosition!.longitude,
//       );

//       _mapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target:
//                 LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//             zoom: 12.0,
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error fetching location: $e');
//     }
//   }

//   // Method to start the radar animation
//   void _startRadarAnimation() {
//     _radarTimer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
//       setState(() {
//         _currentRadius += 100; // Increase the radius by 100 meters per frame

//         // Reset the radius once it exceeds the maximum (3 km)
//         if (_currentRadius > _maxRadius) {
//           _currentRadius = 0;
//         }

//         if (_currentPosition != null) {
//           _radarCircle = Circle(
//             circleId: CircleId("radar_circle"),
//             center:
//                 LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//             radius: _currentRadius,
//             fillColor: Colors.blue.withOpacity(0.2),
//             strokeWidth: 0,
//           );
//         }
//       });
//     });
//   }

//   // Method to get grid cell ID based on latitude and longitude
//   String getGridCell(double latitude, double longitude) {
//     double cellSize = 3.0; // 3 km
//     int latIndex = (latitude / cellSize).floor();
//     int lngIndex = (longitude / cellSize).floor();
//     return 'grid_${latIndex}_${lngIndex}';
//   }

//   // Save user location to Firestore
//   void saveUserLocation(
//       String userId, String username, double latitude, double longitude) {
//     // Determine the grid cell based on the user's location
//     String gridCell = getGridCell(latitude, longitude);
//     print("Curent location Gridcell: $gridCell");

//     // Reference to the Firestore collection and document path
//     DocumentReference userDocRef = FirebaseFirestore.instance
//         .collection('grid_cells')
//         .doc(gridCell)
//         .collection('users')
//         .doc(userId);

//     // Data to be saved
//     Map<String, dynamic> userData = {
//       'username': username,
//       'Profile_Pic': User_Profile_Picture,
//       "time": DateTime.now().toString(),
//       'latitude': latitude,
//       'longitude': longitude,
//     };

//     // Save or update the user's location in Firestore
//     userDocRef.set(userData).then((_) {
//       print('User location saved successfully');
//     }).catchError((error) {
//       print('Failed to save user location: $error');
//     });

//     CollectionReference chatCollection =
//         FirebaseFirestore.instance.collection('grid_cells');

//     chatCollection.doc(gridCell).set({
//       'User_Name': User_Name,
//     });
//   }

//   // Fetch users within a 3x3 km area and update the map
//   Future<void> updateMapWithNearbyUsers(
//       double latitude, double longitude) async {
//     double lat1 = latitude - 0.027; // Roughly 3 km in degrees
//     double lng1 = longitude - 0.027;
//     double lat2 = latitude + 0.027;
//     double lng2 = longitude + 0.027;

//     await getUsersInArea(lat1, lng1, lat2, lng2);
//     setState(() {
//       // _markers.add(Marker(
//       //   markerId: MarkerId('currentLocation'),
//       //   position: LatLng(latitude, longitude),
//       //   infoWindow: InfoWindow(title: "You"),
//       // ));
//     });
//   }

//   // Retrieve users from Firestore and add markers to the map
//   var defTime;
//   Future<void> getUsersInArea(
//       double lat1, double lng1, double lat2, double lng2) async {
//     String startGridCell = getGridCell(lat1, lng1);
//     String endGridCell = getGridCell(lat2, lng2);
//     print("start :$startGridCell   end:$endGridCell");

//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('grid_cells')
//         .where(FieldPath.documentId, isGreaterThanOrEqualTo: startGridCell)
//         .where(FieldPath.documentId, isLessThanOrEqualTo: endGridCell)
//         .get();

//     print('Grid id :${snapshot.docs}');

//     for (var doc in snapshot.docs) {
//       CollectionReference usersCollection = FirebaseFirestore.instance
//           .collection('grid_cells')
//           .doc(doc.id)
//           .collection('users');

//       QuerySnapshot usersSnapshot = await usersCollection.get();
//       BottomSheetData = usersSnapshot;
//       setState(() {});

//       for (var userDoc in usersSnapshot.docs) {
//         print('users data:${userDoc.data()}');

//         var nowtime = DateTime.now();
//         DateTime parsedTime = DateTime.parse(userDoc['time']);
//         Duration difference = nowtime.difference(parsedTime);

//         setState(() {
//           _markers.clear();
//         });
//         print("Second deferance is ${defTime} ");

//         if (difference.inSeconds < 20) {
//           print("User name is ${userDoc['username']}");
//           setState(() {
//             _loadCustomMarker(
//                 userDoc['Profile_Pic'] != null
//                     ? userDoc['Profile_Pic']
//                     : "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/images%2FNo_Dp.jpeg?alt=media&token=5d47c083-d458-493e-9556-f71f516de648",
//                 userDoc['username'],
//                 "hello",
//                 userDoc['latitude'],
//                 userDoc['longitude']);
//           });
//         }
//       }
//     }
//   }

//   DateTime parseTimestamp(String timestamp) {
//     // Extract seconds and nanoseconds
//     RegExp regExp = RegExp(r'Timestamp\(seconds=(\d+), nanoseconds=(\d+)\)');
//     Match match = regExp.firstMatch(timestamp)!;

//     int seconds = int.parse(match.group(1)!);
//     int nanoseconds = int.parse(match.group(2)!);

//     // Convert to milliseconds
//     int milliseconds = seconds * 1000 + nanoseconds ~/ 1000000;

//     // Create DateTime object
//     return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
//   }

//   Future<void> _loadCustomMarker(
//       String image, String Name, String Des, double liti, double longi) async {
//     print("maker mak for $Name ");

//     final Uint8List markerIcon = await _createCustomMarkerWithTail(
//       image,
//       70, // image size
//     );

//     setState(() {
//       _markers.add(
//         Marker(
//           markerId:
//               MarkerId(Name), // Use a unique marker ID, e.g., the user's name
//           position: LatLng(liti, longi), // Your desired position
//           icon: BitmapDescriptor.fromBytes(markerIcon),
//           infoWindow: InfoWindow(onTap: () {}, snippet: Des, title: Name),
//         ),
//       );
//     });
//   }

//   Future<Uint8List> _createCustomMarkerWithTail(
//       String imageUrl, int size) async {
//     // Use CachedNetworkImageProvider to handle caching
//     final CachedNetworkImageProvider imageProvider =
//         CachedNetworkImageProvider(imageUrl);

//     final Completer<ui.Image> completer = Completer();
//     final ImageStream stream = imageProvider.resolve(
//         ImageConfiguration(size: Size(size.toDouble(), size.toDouble())));
//     final ImageStreamListener listener =
//         ImageStreamListener((ImageInfo info, bool synchronousCall) {
//       completer.complete(info.image);
//     });

//     stream.addListener(listener);
//     final ui.Image image = await completer.future;
//     stream.removeListener(listener);

//     final ui.PictureRecorder recorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(recorder);
//     final Paint paint = Paint()..color = Colors.blue;

//     final double circleRadius = size / 2.0;
//     final double tailHeight = size / 3.0;

//     // Draw the circle (profile picture background)
//     final Rect circleRect = Rect.fromCircle(
//         center: Offset(circleRadius, circleRadius), radius: circleRadius);
//     canvas.drawCircle(Offset(circleRadius, circleRadius), circleRadius, paint);

//     // Clip the canvas to circular shape and draw the image inside the circle
//     canvas.clipPath(Path()..addOval(circleRect));
//     paintImage(
//       canvas: canvas,
//       rect: circleRect,
//       image: image,
//       fit: BoxFit.cover,
//     );

//     // Draw the triangle tail at the bottom
//     final Path tailPath = Path();
//     tailPath.moveTo(circleRadius - circleRadius / 3, size.toDouble());
//     tailPath.lineTo(circleRadius + circleRadius / 3, size.toDouble());
//     tailPath.lineTo(circleRadius, size.toDouble() + tailHeight);
//     tailPath.close();

//     canvas.drawPath(tailPath, paint);

//     // Finalize the drawing
//     final ui.Picture picture = recorder.endRecording();
//     final ui.Image finalImage =
//         await picture.toImage(size, (size + tailHeight).toInt());
//     final ByteData? byteData =
//         await finalImage.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   var drawer = false;
//   var live = true;

//   bool Timedef(String Time) {
//     var nowtime = DateTime.now();
//     DateTime parsedTime = DateTime.parse(Time);
//     Duration difference = nowtime.difference(parsedTime);
//     if (difference.inSeconds < 20) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         toolbarHeight: 0,
//       ),
//       drawer: ModernTikTokDrawer(
//         userName: "abid",
//         userProfileUrl: "",
//       ),
//       body: Stack(
//         children: [
//           loadMap
//               ? Center(
//                   child:
//                       CircularProgressIndicator()) // Show loading indicator while fetching location
//               : GoogleMap(
//                   zoomControlsEnabled: false,
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(
//                       _currentPosition?.latitude ?? _initialPosition.latitude,
//                       _currentPosition?.longitude ?? _initialPosition.longitude,
//                     ),
//                     zoom: 14.0,
//                   ),
//                   myLocationEnabled: true, // Enable to show the user's location
//                   myLocationButtonEnabled: true,
//                   onMapCreated: (GoogleMapController controller) {
//                     _mapController = controller;
//                     if (_currentPosition != null) {
//                       _mapController.animateCamera(
//                         CameraUpdate.newCameraPosition(
//                           CameraPosition(
//                             target: LatLng(
//                               _currentPosition!.latitude,
//                               _currentPosition!.longitude,
//                             ),
//                             zoom: 12.2,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   circles: _radarCircle != null
//                       ? {_radarCircle!}
//                       : {}, // Display the radar circle
//                   markers: _markers, // Add markers to the map
//                 ),
//           Positioned(
//             top: 20,
//             left: 20,
//             child: InkWell(
//               onTap: () {
//                 _scaffoldKey.currentState?.openDrawer(); // Open the drawer
//               },
//               child: Icon(
//                 Icons.menu,
//                 size: 40,
//               ),
//             ),
//           ),
//           DraggableScrollableSheet(
//             initialChildSize:
//                 0.1, // Show only 1 row initially (10% of the screen)
//             minChildSize: 0.1, // Minimum size when dragged down
//             maxChildSize: 0.5, // Maximum size when fully expanded
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 15.0,
//                       spreadRadius: 10.0,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: Container(
//                         width: 40,
//                         height: 5,
//                         decoration: BoxDecoration(
//                           color: Colors.black45,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                           controller: scrollController,
//                           child: BottomSheetData != null
//                               ? Column(
//                                   children: [
//                                     for (var userDoc in BottomSheetData.docs)
//                                       Padding(
//                                         padding:
//                                             EdgeInsets.fromLTRB(0, 10, 10, 0),
//                                         child: Row(
//                                           children: [
//                                             SizedBox(width: 15),
//                                             userDoc['Profile_Pic'] != null
//                                                 ? CircleAvatar(
//                                                     radius: 20,
//                                                     backgroundImage:
//                                                         NetworkImage(userDoc[
//                                                             'Profile_Pic']),
//                                                   )
//                                                 : CircleAvatar(
//                                                     radius: 20,
//                                                     backgroundImage: AssetImage(
//                                                         'Assets/Images/No_Dp.jpeg'),
//                                                   ),
//                                             SizedBox(width: 5),
//                                             Text(userDoc['username']),
//                                             Spacer(),
//                                             if (Timedef(userDoc['time']))
//                                               Row(
//                                                 children: [
//                                                   CircleAvatar(
//                                                     backgroundColor:
//                                                         Colors.green,
//                                                     radius: 5,
//                                                   ),
//                                                   SizedBox(width: 5),
//                                                   Text(
//                                                     "Live",
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                 ],
//                                               )
//                                             else
//                                               Row(
//                                                 children: [
//                                                   CircleAvatar(
//                                                     backgroundColor:
//                                                         Colors.black54,
//                                                     radius: 5,
//                                                   ),
//                                                   SizedBox(width: 5),
//                                                   Text(
//                                                     "Offline",
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.w600),
//                                                   ),
//                                                 ],
//                                               )
//                                           ],
//                                         ),
//                                       ),
//                                   ],
//                                 )
//                               : Padding(
//                                   padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
//                                   child: Shimmer.fromColors(
//                                     baseColor: Colors.grey[300]!,
//                                     highlightColor: Colors.grey[100]!,
//                                     child: Column(
//                                       children: [
//                                         Row(
//                                           children: [
//                                             // Shimmer for CircleAvatar (Profile Image)
//                                             CircleAvatar(
//                                               radius: 20,
//                                               backgroundColor: Colors.grey[
//                                                   300], // Placeholder for avatar
//                                             ),
//                                             SizedBox(width: 5),
//                                             // Shimmer for Name Text
//                                             Container(
//                                               width:
//                                                   100, // Adjust width according to your text length
//                                               height:
//                                                   15, // Adjust height for the text
//                                               color: Colors.grey[
//                                                   300], // Placeholder for name
//                                             ),
//                                             Spacer(),
//                                             // Shimmer for live indicator
//                                             CircleAvatar(
//                                               backgroundColor: Colors.grey[
//                                                   300], // Placeholder for live dot
//                                               radius: 5,
//                                             ),
//                                             SizedBox(width: 5),
//                                             Container(
//                                               width:
//                                                   40, // Adjust width for the "Live" text
//                                               height:
//                                                   15, // Adjust height for the text
//                                               color: Colors.grey[
//                                                   300], // Placeholder for live text
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ModernTikTokDrawer extends StatelessWidget {
//   final String userName;
//   final String userProfileUrl;

//   ModernTikTokDrawer({required this.userName, required this.userProfileUrl});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       width: 230,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.white,
//               Colors.white60,
//             ],
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header section with user info
//             Container(
//               padding: const EdgeInsets.only(top: 50, bottom: 20),
//               child: Column(
//                 children: [
//                   // Profile Picture
//                   User_Profile_Picture != null
//                       ? InkWell(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ProfilePictureScreen(),
//                                 ));
//                           },
//                           child: Stack(
//                             children: [
//                               CircleAvatar(
//                                 radius: 40,
//                                 backgroundImage:
//                                     NetworkImage(User_Profile_Picture),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: Container(
//                                   height: 30,
//                                   width: 30,
//                                   decoration: BoxDecoration(
//                                     color: Colors
//                                         .blue, // You can change the color to fit your design
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     Icons.edit,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : InkWell(
//                           onTap: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ProfilePictureScreen(),
//                                 ));
//                           },
//                           child: Stack(
//                             children: [
//                               CircleAvatar(
//                                 radius: 40,
//                                 backgroundImage:
//                                     AssetImage('Assets/Images/No_Dp.jpeg'),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: Container(
//                                   height: 30,
//                                   width: 30,
//                                   decoration: BoxDecoration(
//                                     color: Colors
//                                         .blue, // You can change the color to fit your design
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(
//                                     Icons.add,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                   SizedBox(height: 15),
//                   // Username
//                   Text(
//                     User_Name,
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(color: Colors.black45, thickness: 0.5),

//             // Options list
//             Expanded(
//               child: ListView(
//                 children: [
//                   // Terms and Conditions
//                   _buildDrawerOption(
//                     iconColor: Colors.black,
//                     icon: Icons.security_rounded,
//                     title: 'Terms and Conditions',
//                     onTap: () {
//                       // Handle Terms and Conditions navigation
//                     },
//                   ),
//                   Icon(
//                     CupertinoIcons.photo_fill_on_rectangle_fill,
//                     color: Colors.white,
//                     size: 24.0,
//                   ),
//                   // Privacy Policy
//                   _buildDrawerOption(
//                     icon: Icons.privacy_tip_rounded,
//                     title: 'Privacy Policy',
//                     onTap: () {
//                       // Handle Privacy Policy navigation
//                     },
//                   ),
//                   // Delete Account
//                   _buildDrawerOption(
//                     icon: Icons.delete_forever_rounded,
//                     title: 'Delete Account',
//                     iconColor: Colors.redAccent,
//                     onTap: () {
//                       // Handle account deletion
//                     },
//                   ),
//                   // Logout
//                   _buildDrawerOption(
//                     icon: Icons.logout_rounded,
//                     title: 'Logout',
//                     onTap: () {
//                       // Handle logout
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Footer with a small logo or additional text
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30),
//               child: Text(
//                 'App version 1.0.0',
//                 style: TextStyle(color: Colors.white54, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method to create modern drawer options
//   Widget _buildDrawerOption({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color iconColor = Colors.white,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: iconColor, size: 28),
//       title: Text(
//         title,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 18,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       onTap: onTap,
//     );
//   }
// }

// class BottomSheetContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(0.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             'Available Cars',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           ListTile(
//             leading: Icon(Icons.car_repair),
//             title: Text('Car Type 1'),
//             subtitle: Text('Available Now'),
//             trailing: Text('\$10.00'),
//             onTap: () {
//               // Handle tap
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.car_repair),
//             title: Text('Car Type 2'),
//             subtitle: Text('Available Now'),
//             trailing: Text('\$12.00'),
//             onTap: () {
//               // Handle tap
//             },
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }

