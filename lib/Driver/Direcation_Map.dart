import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _origin = LatLng(37.77483, -122.41942); // San Francisco
  static const LatLng _destination =
      LatLng(34.05223, -118.24368); // Los Angeles

  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
    _getPolyline();
  }

  Future<void> _getPolyline() async {
    String googleAPIKey = 'AIzaSyAqekFlNpFCYT5bl2o57iU0iFbJiGHqm4c';

    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(_origin.latitude, _origin.longitude),
      destination: PointLatLng(_destination.latitude, _destination.longitude),
      mode: TravelMode.driving,
    );

    // Fetch the route between the coordinates
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPIKey,
      request: request, // Pass the request object
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {}); // Update the map with the polyline
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Polyline Between Points')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _origin,
          zoom: 6.0,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
        markers: {
          Marker(
            markerId: MarkerId('origin'),
            position: _origin,
            infoWindow: InfoWindow(title: 'Origin'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: _destination,
            infoWindow: InfoWindow(title: 'Destination'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
