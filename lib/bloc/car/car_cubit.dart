import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/car_model.dart';

class CarCubit extends Cubit<List<Car>> {
  CarCubit() : super([]);

  void fetchCars() async {
    try {
      print("Fetching cars from Firestore...");
      final snapshot = await FirebaseFirestore.instance.collection('cars').get();

      if (snapshot.docs.isEmpty) {
        print("No cars found in Firestore");
      }

      final cars = snapshot.docs.map((doc) => Car.fromMap(doc.data(), doc.id)).toList();
      emit(cars);
    } catch (e) {
      print("Error fetching cars: $e");
      emit([]);
    }
  }
}




