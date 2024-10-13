import 'package:flutter/material.dart';

class No_Data extends StatelessWidget {
  String Title;
  No_Data({super.key, required this.Title});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Center(
          child: Column(children: [
            Image.asset("Assets/Images/EmptyBox.png"),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Text(
                Title,
                style: TextStyle(
                    fontFamily: "Sofia",
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                    color: Color(0xFF319AFF)),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
