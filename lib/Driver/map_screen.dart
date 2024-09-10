import 'package:flutter/material.dart';
import 'package:flutter_application_1/Driver/Direcation_Map.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;

class MaoScreen extends StatefulWidget {
  const MaoScreen({super.key});

  @override
  State<MaoScreen> createState() => _MaoScreenState();
}

class _MaoScreenState extends State<MaoScreen> {
  @override
  Widget build(BuildContext context) {
    return MapScreen();
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  final Location _location = Location();
  Set<Marker> _markers = {};
  LatLng? _origin;
  LatLng? _destination;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default location
  double _currentZoom = 14.0; // Initialize the zoom level

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _getUserLocation();
  }

  // Request Location Permission
  void _requestPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  // Get user's current location and move the camera to it
  void _getUserLocation() async {
    _currentLocation = await _location.getLocation();
    setState(() {
      _initialPosition = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _initialPosition,
        infoWindow: InfoWindow(title: 'You are here'),
      ));
    });
  }

  // Move camera to the current location
  void _goToCurrentLocation() async {
    _currentLocation = await _location.getLocation();
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          zoom: _currentZoom,
        ),
      ),
    );
  }

  // Zoom in function
  void _zoomIn() {
    _currentZoom += 1;
    _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  // Zoom out function
  void _zoomOut() {
    if (_currentZoom > 1) {
      _currentZoom -= 1;
      _controller?.animateCamera(CameraUpdate.zoomOut());
    }
  }

  // Add a marker at the tapped location (destination)
  void _onMapTapped(LatLng position) {
    if (_origin == null) {
      setState(() {
        _origin = position;
        _markers.add(
          Marker(
            markerId: MarkerId('origin'),
            position: _origin!,
            infoWindow: InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );
      });
    } else if (_destination == null) {
      setState(() {
        _destination = position;
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: _destination!,
            infoWindow: InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
    }
  }

  // Calculate the midpoint between the origin and destination
  LatLng _calculateMidpoint(LatLng point1, LatLng point2) {
    return LatLng(
      (point1.latitude + point2.latitude) / 2,
      (point1.longitude + point2.longitude) / 2,
    );
  }

  // Place marker at the midpoint
  void _placeMidpointMarker() {
    if (_origin != null && _destination != null) {
      LatLng midpoint = _calculateMidpoint(_origin!, _destination!);
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('midpoint'),
            position: midpoint,
            infoWindow: InfoWindow(title: 'Midpoint'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Uber-style Google Map")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: _currentZoom,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap:
                _onMapTapped, // Add a destination marker when the map is tapped
          ),
          Positioned(
            right: 10,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UberMap(),
                        ));
                  },
                  tooltip: 'Zoom In',
                  mini: true,
                  child: Icon(Icons.zoom_in),
                ),
                FloatingActionButton(
                  onPressed: _zoomIn,
                  tooltip: 'Zoom In',
                  mini: true,
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  tooltip: 'Zoom Out',
                  mini: true,
                  child: Icon(Icons.zoom_out),
                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _goToCurrentLocation,
                  tooltip: 'Go to Current Location',
                  child: Icon(Icons.my_location),
                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: _placeMidpointMarker,
                  tooltip: 'Place Midpoint Marker',
                  child: Icon(Icons.place),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
