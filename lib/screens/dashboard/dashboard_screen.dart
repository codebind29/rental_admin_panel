import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.black87,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatistics(context),
            const SizedBox(height: 20),
            _buildCarList(context),
            const SizedBox(height: 20),
            _buildBookingList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[900]!, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Admin Dashboard",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text("Manage all bookings and cars",
                  style: TextStyle(color: Colors.grey[400])),
            ],
          ),
          Lottie.asset('assets/animations/car.json', width: 80, height: 80),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Row(
      children: [
        // Total Cars Card
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cars').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _DashboardCard(
                title: "Total Cars",
                amount: "Loading...",
                growth: "",
                icon: Icons.directions_car,
                color: Colors.blueAccent,
              );
            }

            final totalCars = snapshot.data!.docs.length;
            final availableCars = snapshot.data!.docs.where((doc) {
              final car = doc.data() as Map<String, dynamic>;
              return car['isAvailable'] as bool? ?? false;
            }).length;

            return _DashboardCard(
              title: "Total Cars",
              amount: "$totalCars",
              growth: "$availableCars Available",
              icon: Icons.directions_car,
              color: Colors.blueAccent,
            );
          },
        ),

        const SizedBox(width: 10),

        // Total Earnings Card - Combined from bookings and subscriptions
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('bookings')
              .where('status', isEqualTo: 'completed')
              .snapshots(),
          builder: (context, bookingsSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user_subscriptions')
                  .where('paymentStatus', isEqualTo: 'completed')
                  .snapshots(),
              builder: (context, subscriptionsSnapshot) {
                if (!bookingsSnapshot.hasData || !subscriptionsSnapshot.hasData) {
                  return _DashboardCard(
                    title: "Total Earnings",
                    amount: "Loading...",
                    growth: "",
                    icon: Icons.attach_money,
                    color: Colors.greenAccent,
                  );
                }

                double totalEarnings = 0;
                int completedTransactions = 0;

                // Calculate from bookings
                for (var doc in bookingsSnapshot.data!.docs) {
                  final booking = doc.data() as Map<String, dynamic>;
                  totalEarnings += (booking['totalPrice'] as num?)?.toDouble() ?? 0.0;
                  completedTransactions++;
                }

                // Calculate from subscriptions
                for (var doc in subscriptionsSnapshot.data!.docs) {
                  final subscription = doc.data() as Map<String, dynamic>;
                  totalEarnings += (subscription['price'] as num?)?.toDouble() ?? 0.0;
                  completedTransactions++;
                }

                final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

                return _DashboardCard(
                  title: "Total Earnings",
                  amount: formatter.format(totalEarnings),
                  growth: "$completedTransactions Transactions",
                  icon: Icons.attach_money,
                  color: Colors.greenAccent,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCarList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cars').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No cars available", style: TextStyle(color: Colors.white)));
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Car Inventory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              ...snapshot.data!.docs.map((doc) {
                final car = doc.data() as Map<String, dynamic>;
                final isAvailable = car['isAvailable'] as bool? ?? false;
                final carId = doc.id;

                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    leading: Icon(Icons.directions_car,
                        color: isAvailable ? Colors.green : Colors.red),
                    title: Text(car['model']?.toString() ?? 'Unknown model',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text("${car['city']?.toString() ?? ''} • ₹${car['pricePerHour']?.toString() ?? '0'}/hr",
                        style: TextStyle(color: Colors.grey[300])),
                    trailing: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('carId', isEqualTo: carId)
                          .where('status', whereIn: ['pending', 'confirmed'])
                          .snapshots(),
                      builder: (context, bookingSnapshot) {
                        if (bookingSnapshot.hasData && bookingSnapshot.data!.docs.isNotEmpty) {
                          final booking = bookingSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                          final status = booking['status'] as String? ?? 'pending';
                          return Chip(
                            label: Text(status.toUpperCase()),
                            backgroundColor: _getStatusColor(status).withOpacity(0.2),
                            labelStyle: TextStyle(color: _getStatusColor(status)),
                          );
                        }
                        return Chip(
                          label: Text(isAvailable ? "AVAILABLE" : "BOOKED"),
                          backgroundColor: isAvailable ? Colors.green[900] : Colors.red[900],
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Text("No bookings yet", style: TextStyle(color: Colors.white70)),
              ],
            ),
          );
        }

        // Calculate statistics for the status filter chips
        final allBookings = snapshot.data!.docs;
        final pendingCount = allBookings.where((doc) {
          final booking = doc.data() as Map<String, dynamic>;
          return booking['status'] == 'pending';
        }).length;

        final confirmedCount = allBookings.where((doc) {
          final booking = doc.data() as Map<String, dynamic>;
          return booking['status'] == 'confirmed';
        }).length;

        final completedCount = allBookings.where((doc) {
          final booking = doc.data() as Map<String, dynamic>;
          return booking['status'] == 'completed';
        }).length;

        final cancelledCount = allBookings.where((doc) {
          final booking = doc.data() as Map<String, dynamic>;
          return booking['status'] == 'cancelled';
        }).length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Recent Bookings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),

              // Status filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusChip(status: 'all', count: allBookings.length),
                    _StatusChip(status: 'pending', count: pendingCount),
                    _StatusChip(status: 'confirmed', count: confirmedCount),
                    _StatusChip(status: 'completed', count: completedCount),
                    _StatusChip(status: 'cancelled', count: cancelledCount),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              ...snapshot.data!.docs.take(5).map((doc) {
                final booking = doc.data() as Map<String, dynamic>;
                final status = booking['status']?.toString() ?? 'pending';
                //final timestamp = (booking['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                final startDate = (booking['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                final endDate = (booking['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                final userName = booking['userName']?.toString() ?? 'Unknown user';
                final carModel = booking['carModel']?.toString() ?? 'Unknown car';
                //final location = booking['location']?.toString() ?? 'Unknown location';
                final totalPrice = (booking['totalPrice'] as num?)?.toDouble() ?? 0.0;
                final carId = booking['carId']?.toString() ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text("$userName - $carModel",
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status: ${status.toUpperCase()}",
                            style: TextStyle(color: _getStatusColor(status))),
                        Text("${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd').format(endDate)}",
                            style: TextStyle(color: Colors.grey[300])),
                        Text("₹$totalPrice",
                            style: const TextStyle(color: Colors.greenAccent)),
                      ],
                    ),
                    leading: Icon(_getStatusIcon(status),
                        color: _getStatusColor(status)),
                    trailing: _buildStatusActions(context, status, doc.id, carId),
                    onTap: () {
                      _showBookingDetailsDialog(context, booking, doc.id, carId);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusActions(BuildContext context, String status, String bookingId, String carId) {
    switch (status) {
      case 'pending':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _confirmBooking(context, bookingId, carId),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectBooking(context, bookingId),
            ),
          ],
        );
      case 'confirmed':
        return IconButton(
          icon: const Icon(Icons.done_all, color: Colors.blue),
          onPressed: () => _completeBooking(context, bookingId, carId),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showBookingDetailsDialog(BuildContext context, Map<String, dynamic> booking, String bookingId, String carId) {
    final status = booking['status']?.toString() ?? 'pending';
    final timestamp = (booking['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final startDate = (booking['startDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endDate = (booking['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final userName = booking['userName']?.toString() ?? 'Unknown user';
    final carModel = booking['carModel']?.toString() ?? 'Unknown car';
    final location = booking['location']?.toString() ?? 'Unknown location';
    final totalPrice = (booking['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod = booking['paymentMethod']?.toString() ?? 'Unknown';
    final userId = booking['userId']?.toString() ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text("Booking Details", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow("User", userName, Icons.person),
              _buildDetailRow("User ID", userId, Icons.person_outline),
              _buildDetailRow("Car Model", carModel, Icons.directions_car),
              _buildDetailRow("Location", location, Icons.location_on),
              _buildDetailRow("Dates",
                  "${DateFormat('MMM dd, yyyy').format(startDate)} to ${DateFormat('MMM dd, yyyy').format(endDate)}",
                  Icons.calendar_today),
              _buildDetailRow("Total Price", "₹$totalPrice", Icons.attach_money),
              _buildDetailRow("Payment Method", paymentMethod, Icons.payment),
              _buildDetailRow("Booked On", DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp),
                  Icons.access_time),
              _buildDetailRow("Status", status.toUpperCase(), _getStatusIcon(status)),
            ],
          ),
        ),
        actions: [
          if (status == 'pending') ...[
            TextButton(
              child: const Text("Reject", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                _rejectBooking(context, bookingId);
              },
            ),
            TextButton(
              child: const Text("Confirm", style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.pop(context);
                _confirmBooking(context, bookingId, carId);
              },
            ),
          ],
          if (status == 'confirmed')
            TextButton(
              child: const Text("Complete", style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
                _completeBooking(context, bookingId, carId);
              },
            ),
          TextButton(
            child: const Text("Close", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context, String bookingId, String carId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
      });
      await FirebaseFirestore.instance.collection('cars').doc(carId).update({
        'isAvailable': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking confirmed"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectBooking(BuildContext context, String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking cancelled"), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _completeBooking(BuildContext context, String bookingId, String carId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status': 'completed',
      });
      await FirebaseFirestore.instance.collection('cars').doc(carId).update({
        'isAvailable': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking marked as completed"), backgroundColor: Colors.blue),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.greenAccent;
      case 'pending': return Colors.orangeAccent;
      case 'completed': return Colors.blueAccent;
      case 'cancelled':
      case 'rejected':
        return Colors.redAccent;
      default: return Colors.white70;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Icons.check_circle;
      case 'pending': return Icons.access_time;
      case 'completed': return Icons.done_all;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      default: return Icons.help_outline;
    }
  }
}

class _DashboardCard extends StatelessWidget {
  final String title, amount, growth;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.amount,
    required this.growth,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 10),
            Text(amount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Text(growth, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final int count;

  const _StatusChip({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text("${status.toUpperCase()} ($count)"),
        backgroundColor: color.withOpacity(0.2),
        labelStyle: TextStyle(color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.greenAccent;
      case 'pending': return Colors.orangeAccent;
      case 'completed': return Colors.blueAccent;
      case 'cancelled': return Colors.redAccent;
      case 'all': return Colors.white70;
      default: return Colors.white70;
    }
  }
}