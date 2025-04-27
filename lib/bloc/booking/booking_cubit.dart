import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_state.dart';
import '../../models/booking_model.dart';

/// 🔹 **Cubit for Managing Bookings**
class BookingCubit extends Cubit<BookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingCubit() : super(BookingInitial());

  /// ✅ **Fetch Real-time Bookings**
  void fetchBookings() async {
    try {
      print("Fetching bookings from Firestore...");
      _firestore.collection('bookings').snapshots().listen((snapshot) {
        print("Bookings snapshot received. Docs count: ${snapshot.docs.length}");

        List<Booking> bookings = snapshot.docs.map((doc) {
          print("Booking found: ${doc.id} => ${doc.data()}");
          return Booking.fromMap(doc.id as Map<String, dynamic>, doc.data() as String);
        }).toList();

        emit(BookingLoaded(bookings));
        print("Emitting BookingLoaded state with ${bookings.length} bookings.");
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      emit(BookingError("Failed to fetch bookings: $e"));
    }
  }


  /// ✅ **Update Booking Status in Firestore**
  void updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({'status': newStatus});
      fetchBookings(); // Refresh the state after updating
    } catch (e) {
      emit(BookingError("Failed to update booking: $e"));
    }
  }
}







