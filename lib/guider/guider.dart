import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class MyApp extends StatelessWidget {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Showcase(
            key: _one,
            title: 'App Bar',
            description: 'This is the app bar',
            child: Text('Showcase Example'),
          ),
        ),
        body: Center(
          child: Showcase(
            key: _two,
            title: 'Floating Action Button',
            description: 'This button allows you to add items',
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
