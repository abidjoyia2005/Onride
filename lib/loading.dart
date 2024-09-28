import 'package:flutter/material.dart';

class LoadingGif extends StatefulWidget {
  const LoadingGif({super.key});

  @override
  State<LoadingGif> createState() => _LoadingGifState();
}

class _LoadingGifState extends State<LoadingGif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            height: 150,
            width: 150,
            child: Image.asset("Assets/gifs/loading1.gif")),
      ),
    );
  }
}
