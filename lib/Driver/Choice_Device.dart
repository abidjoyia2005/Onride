import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';
import 'package:flutter_application_1/Driver/Leciense_Scan.dart';
import 'package:flutter_application_1/Driver/Uber_map.dart';
import 'package:flutter_application_1/client_user/Selected_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/AuthService/Email_Auth.dart';

class Vichale_cHOSE extends StatefulWidget {
  var route;
  Vichale_cHOSE({super.key, this.route});

  @override
  State<Vichale_cHOSE> createState() => _Vichale_cHOSEState();
}

class _Vichale_cHOSEState extends State<Vichale_cHOSE> {
  @override
  Widget build(BuildContext context) {
    return VehicleSelectionScreen(route: widget.route);
  }
}

class VehicleSelectionScreen extends StatefulWidget {
  var route;
  VehicleSelectionScreen({this.route});
  @override
  _VehicleSelectionScreenState createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  String selectedVehicle = '';
  void CreateDocumentFirebase(String VIC) async {
    print("User name of 0 count:");
    CollectionReference chatCollection =
        FirebaseFirestore.instance.collection('User_Data');

    await chatCollection
        .doc(User_Id)
        .set({'Driver_Acount': true, 'Vicale_Type': VIC},
            SetOptions(merge: true))
        .then((value) => () {
              print("Username Added");
            })
        .catchError(
            (error) => print("Failed to add user message count: $error"));
  }

  final List<Map<String, dynamic>> vehicles = [
    {
      'image': 'Assets/Vicale_images/Bus.png',
      'name': 'Bus',
      'count': 1,
      'capacity': 40,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2Fbus.png?alt=media&token=894e74ab-e6f2-44ad-ab04-31abf1a4b6cf"
    },
    {
      'image': 'Assets/Vicale_images/Van.png',
      'name': 'Van',
      'count': 2,
      'capacity': 12,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2Fvan.png?alt=media&token=3ae8f7cc-fdba-441a-b640-ff8b1b5f2a27"
    },
    {
      'image': 'Assets/Vicale_images/Car.png',
      'name': 'Car',
      'count': 3,
      'capacity': 5,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2Fcar.png?alt=media&token=44ecb4f3-8266-4e25-9777-efc64ffe015b"
    },
    {
      'image': 'Assets/Vicale_images/Bike.png',
      'name': 'Bike',
      'count': 4,
      'capacity': 2,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2Fmotorcycle1.png?alt=media&token=f2069408-2a8e-43ab-8982-673ad708dc28"
    },
    {
      'image': 'Assets/Vicale_images/Ambulance.png',
      'name': 'Ambulance',
      'count': 4,
      'capacity': 3,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2Fambulance.png?alt=media&token=249e2f4c-0454-4737-9c66-b5900a2a5f70"
    },
    {
      'image': 'Assets/Vicale_images/Truck.png',
      'name': 'Truck',
      'count': 5,
      'capacity': 3,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2Ftruck.png?alt=media&token=52cd43e3-997c-4da9-9d64-61209a72f923"
    },
    {
      'image': 'Assets/Vicale_images/MiniTruck.png',
      'name': 'MiniTruck',
      'count': 6,
      'capacity': 5,
      'ProfileLink':
          "https://firebasestorage.googleapis.com/v0/b/liveticketbyjoyia-244a9.appspot.com/o/vehicle%2FPick%20up%20truck-amico.png?alt=media&token=a0741bd8-ee6c-471d-8178-4a4e8ed48060"
    },
  ];
  var _textH1 = TextStyle(
      fontFamily: "Poppinssb",
      fontWeight: FontWeight.w600,
      fontSize: 23.0,
      color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Select Your Vehicle',
          style: _textH1,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("Has_Driver_Acount", true);
                    Has_Driver_Acount = true;

                    setState(() {
                      selectedVehicle = vehicles[index]['ProfileLink'];
                      Vicale_Type = selectedVehicle;
                    });
                    prefs.setString("Vicale_Type", Vicale_Type);
                    setState(() {});

                    CreateDocumentFirebase(selectedVehicle);
                    if (widget.route == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => UberMap()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WhichLocation()),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Card(
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            vehicles[index]['image'],
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 5),
                          Text(
                            vehicles[index]['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_seat, // Using seat icon
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 5),
                              Container(
                                width: 10,
                                height: 10,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .deepOrangeAccent, // Primary color for the button
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Driver',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Text color white
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${vehicles[index]['capacity']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     selectedVehicle.isEmpty
          //         ? 'Please select a vehicle'
          //         : 'Selected Vehicle: $selectedVehicle',
          //     style: TextStyle(fontSize: 20),
          //   ),
          // ),
        ],
      ),
    );
  }
}
