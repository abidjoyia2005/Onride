import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

    // Check if location service is enabled
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check for location permission
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
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: position,
          infoWindow: InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
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
              _location.onLocationChanged.listen((LocationData location) {
                _controller?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(location.latitude!, location.longitude!),
                      zoom: _currentZoom,
                    ),
                  ),
                );
                setState(() {
                  _markers.add(
                    Marker(
                      markerId: MarkerId('currentLocation'),
                      position: LatLng(location.latitude!, location.longitude!),
                      infoWindow: InfoWindow(title: 'You are here'),
                    ),
                  );
                });
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Disable default location button
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
