import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  double _maxRadius = 3000; // Maximum radius (3 km)
  Timer? _radarTimer; // Timer for radar animation

  // Set of markers to be displayed on the map
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get user's location
    _startRadarAnimation(); // Start radar animation
  }

  @override
  void dispose() {
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
          radius: _currentRadius, // This will be animated
          fillColor: Colors.blue.withOpacity(0.2),
          strokeWidth: 0,
        );
      });

      // Move the camera to the user's current location

      // Save the user's location to Firestore
      saveUserLocation(
        'user_123', // Replace with actual user ID
        'Username', // Replace with actual username
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Update the map with nearby users

      updateMapWithNearbyUsers(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.0,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching location: $e');
    }
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
    double cellSize = 3.0; // 3 km
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
        .collection('grid_cells')
        .doc(gridCell)
        .collection('users')
        .doc(userId);

    // Data to be saved
    Map<String, dynamic> userData = {
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
    };

    // Save or update the user's location in Firestore
    userDocRef.set(userData).then((_) {
      print('User location saved successfully');
    }).catchError((error) {
      print('Failed to save user location: $error');
    });
  }

  // Fetch users within a 3x3 km area and update the map
  Future<void> updateMapWithNearbyUsers(
      double latitude, double longitude) async {
    double lat1 = latitude - 0.027; // Roughly 3 km in degrees
    double lng1 = longitude - 0.027;
    double lat2 = latitude + 0.027;
    double lng2 = longitude + 0.027;

    await getUsersInArea(lat1, lng1, lat2, lng2);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: "You"),
      ));
    });
  }

  // Retrieve users from Firestore and add markers to the map
  Future<void> getUsersInArea(
      double lat1, double lng1, double lat2, double lng2) async {
    String startGridCell = getGridCell(lat1, lng1);
    String endGridCell = getGridCell(lat2, lng2);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('grid_cells')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startGridCell)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endGridCell)
        .get();

    setState(() {
      _markers.clear(); // Clear existing markers before adding new ones
    });

    for (var doc in snapshot.docs) {
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('grid_cells')
          .doc(doc.id)
          .collection('users');

      QuerySnapshot usersSnapshot = await usersCollection.get();
      for (var userDoc in usersSnapshot.docs) {
        LatLng userLocation = LatLng(userDoc['latitude'], userDoc['longitude']);
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId('user_${userDoc.id}'),
            position: userLocation,
            infoWindow: InfoWindow(title: userDoc['username']),
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Uber Map with Radar"),
      ),
      body: loadMap
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching location
          : GoogleMap(
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
                _mapController = controller;
                if (_currentPosition != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        zoom: 13.2,
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
    );
  }
}
