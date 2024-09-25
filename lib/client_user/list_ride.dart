import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListRide extends StatefulWidget {
  const ListRide({super.key});

  @override
  State<ListRide> createState() => _ListRideState();
}

class _ListRideState extends State<ListRide> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsersInArea("islamabad", "mianwali");
  }

  var BottomSheetData;
  Future<void> getUsersInArea(String latitude, String lngtude) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Vicahle')
        .where(FieldPath.documentId, isEqualTo: "$latitude $lngtude")
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo: "$latitude $lngtude")
        .get();

    print('Grid id :${snapshot.docs}');
    if (snapshot.docs.isEmpty) {
      print("HAS NOT USER ON THIS ROUTER........");

      for (var doc in snapshot.docs) {
        CollectionReference usersCollection = FirebaseFirestore.instance
            .collection('Vicahle')
            .doc(doc.id)
            .collection('usersForRide');

        QuerySnapshot usersSnapshot = await usersCollection.get();
        if (snapshot.docs.isNotEmpty) {
          BottomSheetData = usersSnapshot;
          setState(() {});
        } else {
          BottomSheetData = null;
          setState(() {});
        }

        for (var userDoc in usersSnapshot.docs) {
          print('users data:${userDoc.data()}');

          var nowtime = DateTime.now();
          DateTime parsedTime = DateTime.parse(userDoc['time']);
          Duration difference = nowtime.difference(parsedTime);

          print(
              "Second deferance is ${difference} for  ${userDoc['username']}");

          if (difference.inSeconds < 20) {}
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(),
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
    this.fare = '', // Making fare optional
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // height: 160,
        // width: MediaQuery.of(context).size.width / 1.05,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/images%2FNo_Dp.jpeg?alt=media&token=5d47c083-d458-493e-9556-f71f516de648"),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Image.asset(
            //     "Assets/Vicale_images/hatchback.png",
            //     height: 60,
            //     width: 60,
            //   ),
            // ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        fromPlace,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Image.asset(
                        "Assets/Images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      Spacer(),
                      Text(
                        toPlace,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        "Assets/Images/schedulw.png",
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "${dateTime.hour}:${dateTime.minute} ${dateTime.hour >= 12 ? 'PM' : 'AM'}",
                        style: TextStyle(fontSize: 14),
                      ),
                      Spacer(),
                      Text(
                        "${dateTime.day}/${dateTime.month}/${dateTime.year}",
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Status: $rideStatus",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Spacer(),
                      if (fare.isNotEmpty)
                        Text(
                          "Fare: $fare Rupies",
                          style: TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        height: 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .deepOrangeAccent, // Primary color for the button
                            padding: EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color white
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
