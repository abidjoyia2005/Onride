import 'dart:async';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingGif extends StatefulWidget {
  const LoadingGif({super.key});

  @override
  State<LoadingGif> createState() => _LoadingGifState();
}

class _LoadingGifState extends State<LoadingGif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Center(
          child: Container(
            width: 200,
            height: 200,
            child: LoadinDep(),
          ),
        ),
        // Positioned.fill(
        //   child: Blur(
        //     blur: 2.0, // Set the blur intensity
        //     child: Container(
        //         // color: Colors.white.withOpacity(0.01), // Optional overlay color
        //         ),
        //   ),
        // ),
      ],
    ));
  }
}

class RadarLoadingIndicator extends StatefulWidget {
  @override
  _RadarLoadingIndicatorState createState() => _RadarLoadingIndicatorState();
}

class _RadarLoadingIndicatorState extends State<RadarLoadingIndicator>
    with SingleTickerProviderStateMixin {
  final double _maxRadius = 300.0; // Visual radius for the animation
  AnimationController? _animationController;
  int _currentColorIndex = 0;

  List<Color> _circleColors = [
    Colors.blue[100]!,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.yellow,
    Colors.cyan,
    Colors.indigo,
    Colors.teal,
    Colors.lime,
    Colors.pink,
    Colors.amber,
    Colors.brown,
    Colors.grey,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.blueAccent,
    Colors.greenAccent,
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Reset the animation and update color index
          _animationController!.reset();
          _animationController!.forward();

          setState(() {
            _currentColorIndex =
                (_currentColorIndex + 1) % _circleColors.length;
          });
        }
      });

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: _maxRadius * 2,
        width: _maxRadius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(10, (index) {
            double scale = 1 - (index * 0.1); // Adjust size for each circle
            return Container(
              height: _maxRadius * 2 * scale * _animationController!.value,
              width: _maxRadius * 2 * scale * _animationController!.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent, // Set to transparent
                border: Border.all(
                  color: _circleColors[(_currentColorIndex + index) %
                      _circleColors.length], // Change border color
                  width: 5.0, // Adjust border width as needed
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class LoadinDep extends StatefulWidget {
  const LoadinDep({super.key});

  @override
  State<LoadinDep> createState() => _LoadinDepState();
}

class _LoadinDepState extends State<LoadinDep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // Starts the animation
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center the spinner
      child: SpinKitPulse(
        color: Colors.blue,
        size: 500.0,
        controller: _controller, // Use the controller here
      ),
    );
  }
}
