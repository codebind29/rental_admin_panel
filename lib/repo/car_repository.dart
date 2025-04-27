import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class CarRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Car>> fetchCars() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('cars').get();
      return snapshot.docs.map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Error fetching cars: $e");
      return [];
    }
  }
}
