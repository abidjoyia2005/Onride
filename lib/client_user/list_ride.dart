import 'package:flutter/material.dart';

class ListRide extends StatefulWidget {
  const ListRide({super.key});

  @override
  State<ListRide> createState() => _ListRideState();
}

class _ListRideState extends State<ListRide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RideWidget(
          fromPlace: "mianwali",
          toPlace: "islambad",
          rideStatus: "good",
          dateTime: DateTime.now(),
          fare: "ka"),
    );
  }
}

class RideWidget extends StatelessWidget {
  final String fromPlace;
  final String toPlace;
  final String rideStatus;
  final DateTime dateTime;
  final String fare; // Optional for showing fare

  RideWidget({
    required this.fromPlace,
    required this.toPlace,
    required this.rideStatus,
    required this.dateTime,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text("1:20 Pm"),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text("11:20 Pm"),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
