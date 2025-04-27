import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class CarListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Available Cars",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 10,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('cars').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                  strokeWidth: 3,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car_sharp,
                        size: 60, color: Colors.grey[600]),
                    const SizedBox(height: 20),
                    Text("No cars available",
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Check back later or try another location",
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              );
            }

            var cars = snapshot.data!.docs
                .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                .toList();

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                Car car = cars[index];
                return _buildCarCard(context, car);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, Car car) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.grey[850],
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Navigate to car details
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Car Image/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: car.isAvailable
                      ? Colors.teal.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: car.isAvailable ? Colors.tealAccent : Colors.redAccent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 40,
                  color: car.isAvailable ? Colors.tealAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(width: 16),

              // Car Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          car.model,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: car.isAvailable
                                ? Colors.teal.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            car.isAvailable ? "Available" : "Booked",
                            style: TextStyle(
                              color: car.isAvailable
                                  ? Colors.tealAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          car.city,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.speed, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          "${car.distance} km",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.attach_money,
                            size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          "₹${car.pricePerHour}/hr",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}