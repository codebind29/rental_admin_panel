import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/booking/booking_cubit.dart';
import '../../bloc/booking/booking_state.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Booking Management"),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ **Header**
            const Text(
              "Active Bookings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),

            /// ✅ **Real-time Booking List**
            Expanded(
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  if (state is BookingInitial) {
                    return Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                  } else if (state is BookingError) {
                    return Center(child: Text(state.message, style: TextStyle(color: Colors.redAccent)));
                  } else if (state is BookingLoaded) {
                    final bookings = state.bookings;

                    if (bookings.isEmpty) {
                      return Center(child: Text("No active bookings", style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];

                        return Card(
                          color: Colors.grey[900],
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.tealAccent.withOpacity(0.3)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// ✅ **Car Name & User**
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      booking.carModel,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Chip(
                                      label: Text(
                                        booking.status.toUpperCase(),
                                        style: TextStyle(
                                          color: booking.status == "pending"
                                              ? Colors.orangeAccent
                                              : Colors.greenAccent,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey[850],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),

                                Text("User: ${booking.userName}",
                                    style: TextStyle(color: Colors.white70, fontSize: 14)),

                                const SizedBox(height: 10),

                                /// ✅ **Approve & Reject Buttons**
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.greenAccent,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      ),
                                      icon: Icon(Icons.check, color: Colors.black),
                                      label: Text("Approve", style: TextStyle(color: Colors.black)),
                                      onPressed: () {
                                        context.read<BookingCubit>().updateBookingStatus(booking.id, "confirmed");
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      ),
                                      icon: Icon(Icons.cancel, color: Colors.black),
                                      label: Text("Reject", style: TextStyle(color: Colors.black)),
                                      onPressed: () {
                                        context.read<BookingCubit>().updateBookingStatus(booking.id, "cancelled");
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: Text("Unexpected Error", style: TextStyle(color: Colors.redAccent)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


