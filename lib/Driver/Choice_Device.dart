import 'package:flutter/material.dart';
import 'package:flutter_application_1/Driver/Leciense_Scan.dart';

class Vichale_cHOSE extends StatefulWidget {
  const Vichale_cHOSE({super.key});

  @override
  State<Vichale_cHOSE> createState() => _Vichale_cHOSEState();
}

class _Vichale_cHOSEState extends State<Vichale_cHOSE> {
  @override
  Widget build(BuildContext context) {
    return VehicleSelectionScreen();
  }
}

class VehicleSelectionScreen extends StatefulWidget {
  @override
  _VehicleSelectionScreenState createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  String selectedVehicle = '';

  final List<Map<String, dynamic>> vehicles = [
    {
      'image': 'Assets/Vicale_images/hatchback.png',
      'name': 'Bus',
      'capacity': 40
    },
    {
      'image': 'Assets/Vicale_images/hatchback.png',
      'name': 'Car',
      'capacity': 5
    },
    {
      'image': 'Assets/Vicale_images/hatchback.png',
      'name': 'Van',
      'capacity': 12
    },
    {
      'image': 'Assets/Vicale_images/hatchback.png',
      'name': 'Bike',
      'capacity': 2
    },
    {
      'image': 'Assets/Vicale_images/hatchback.png',
      'name': 'Truck',
      'capacity': 3
    },
    {
      'image': 'Assets/Vicale_images/hatchback.png',
      'name': 'Electric Car',
      'capacity': 5
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Vehicle'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Reduced crossAxisCount to prevent overflow
                crossAxisSpacing: 10,

                mainAxisSpacing: 10,
              ),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicle = vehicles[index]['name'];
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Lecense_Scan_Page(),
                        ));
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              selectedVehicle.isEmpty
                  ? 'Please select a vehicle'
                  : 'Selected Vehicle: $selectedVehicle',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
