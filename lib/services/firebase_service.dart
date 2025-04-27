import 'package:cloud_firestore/cloud_firestore.dart';

/*class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all cars from Firestore
  Stream<QuerySnapshot> getCars() {
    return _firestore.collection('car').snapshots();
  }

  // Fetch all bookings from Firestore
  Stream<QuerySnapshot> getBookings() {
    return _firestore.collection('booking').snapshots();
  }
}
*/
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getBookings() {
    return _firestore.collection('bookings').snapshots();
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({'status': newStatus});
    } catch (e) {
      print("Error updating booking status: $e");
    }
  }
}
