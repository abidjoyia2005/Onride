import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Uber_map extends StatefulWidget {
  const Uber_map({super.key});

  @override
  State<Uber_map> createState() => _Uber_mapState();
}

class _Uber_mapState extends State<Uber_map> {
  LatLng _initialPosition = LatLng(37.7749, -122.4194);
  LatLng _sPosition = LatLng(37.7749, -121.9993);

  late GoogleMapController _mapController;

  // Markers and polylines
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  // API key for Directions API (replace with your actual API key)
  String googleAPIKey = 'AIzaSyDWmd2HZJaJ8E_s33QFOMKdUkPjzOAejQg';

  Future<Map<String, dynamic>?> getDataFromDocument(
      String collectionName, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>?;
      } else {
        print('No such document!');
        return null;
      }
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  void fetchDocumentData() async {
    String collection = 'DefaultData'; // Example Firestore collection
    String documentId = 'Setings'; // Example document ID

    Map<String, dynamic>? documentData =
        await getDataFromDocument(collection, documentId);
    if (documentData != null) {
      print('Document data: $documentData');
    } else {
      print('Document not found or an error occurred.');
    }
  }

  //for redar system

  String getGridCell(double latitude, double longitude) {
    // Define the size of each grid cell
    double cellSize = 3.0; // 3 km

    // Calculate grid cell based on latitude and longitude
    int latIndex = (latitude / cellSize).floor();
    int lngIndex = (longitude / cellSize).floor();

    return 'grid_${latIndex}_${lngIndex}';
  }

  void saveUserLocation(
      String userId, String username, double latitude, double longitude) {
    // Determine the grid cell
    String gridCell = getGridCell(latitude, longitude);

    // Save user data in the appropriate grid cell
    FirebaseFirestore.instance
        .collection('grid_cells')
        .doc(gridCell)
        .collection('users')
        .doc('user_$userId')
        .set({
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<void> getUsersInArea(
      double lat1, double lng1, double lat2, double lng2) async {
    // Define the grid cells to query based on area
    String startGridCell = getGridCell(lat1, lng1);
    String endGridCell = getGridCell(lat2, lng2);

    // Fetch users from the relevant grid cells
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('grid_cells')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startGridCell)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endGridCell)
        .get();

    for (var doc in snapshot.docs) {
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('grid_cells')
          .doc(doc.id)
          .collection('users');

      QuerySnapshot usersSnapshot = await usersCollection.get();
      for (var userDoc in usersSnapshot.docs) {
        print(
            'User: ${userDoc['username']} - ${userDoc['latitude']}, ${userDoc['longitude']}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Add initial marker
    fetchDocumentData();
    _markers.add(Marker(
      markerId: MarkerId('initialMarker'),
      position: _initialPosition,
      infoWindow: InfoWindow(title: "San Francisco"),
    ));

    _markers.add(Marker(
      markerId: MarkerId('secondMarker'),
      position: _sPosition,
      infoWindow: InfoWindow(title: "Destination"),
    ));

    // Fetch the polyline between the two points
    getPolyline();
  }

  // Function to get polyline between two points
  // Function to get polyline between two points
  void getPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();

    // Requesting the route between two points using Directions API
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleAPIKey,
        request: PolylineRequest(
            origin: PointLatLng(
                _initialPosition.latitude, _initialPosition.longitude),
            destination: PointLatLng(_sPosition.latitude, _sPosition.longitude),
            mode: TravelMode.driving));

    // If the result is successful, add points to the polyline
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        // Add polyline to the map
        _polylines.add(Polyline(
          polylineId: PolylineId('routePolyline'),
          width: 5,
          color: Colors.blue,
          points: polylineCoordinates,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("uber"),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 12.0, // Set zoom level
          ),
          myLocationEnabled: true, // Enable to show the user's location
          myLocationButtonEnabled: true,

          markers: {
            Marker(
              markerId: MarkerId("Source"),
              position: _initialPosition,
            ),
            Marker(
              markerId: MarkerId("Destination"),
              position: _sPosition,
            )
          },
        ));
  }
}
