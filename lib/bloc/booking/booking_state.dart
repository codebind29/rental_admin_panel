import 'package:equatable/equatable.dart';
import '../../models/booking_model.dart';

/// 🔹 **Define States for Bookings**
abstract class BookingState extends Equatable {
  @override
  List<Object> get props => [];
}

/// 🔹 **Initial State**
class BookingInitial extends BookingState {}

/// 🔹 **Loading State** ✅ ADD THIS
class BookingLoading extends BookingState {}

/// 🔹 **Booking Data Loaded Successfully**
class BookingLoaded extends BookingState {
  final List<Booking> bookings;
  BookingLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

/// 🔹 **Error Occurred While Fetching Data**
class BookingError extends BookingState {
  final String message;
  BookingError(this.message);

  @override
  List<Object> get props => [message];
}
