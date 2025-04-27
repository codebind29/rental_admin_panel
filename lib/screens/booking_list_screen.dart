import 'package:admin/models/payment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/firebase_service.dart';

class BookingListScreen extends StatefulWidget {
  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      case 'pending': default: return Colors.orange;
    }
  }


  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<Payment?> _fetchPaymentData(String paymentId) async {
    if (paymentId.isEmpty) {
      debugPrint('Payment ID is empty');
      return null;
    }

    try {
      debugPrint('Fetching payment data for ID: $paymentId');
      final doc = await _firestore.collection('payments').doc(paymentId).get(); // Using _firestore

      if (!doc.exists) {
        debugPrint('Payment document does not exist');
        return null;
      }

      final payment = Payment.fromDocument(doc); // Changed to fromDocument
      debugPrint('Successfully fetched payment: ${payment.transactionId}');
      return payment;
    } catch (e) {
      debugPrint('Error fetching payment: $e');
      return null;
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await firebaseService.updateBookingStatus(bookingId, newStatus);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Booking Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 10,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text("No bookings found", style: TextStyle(color: Colors.grey[400], fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final bookingData = doc.data() as Map<String, dynamic>;
              final bookingId = doc.id;
              final paymentId = bookingData['paymentId']?.toString() ?? '';

              final currentStatus = bookingData['status']?.toString() ?? 'pending';
              final userName = bookingData['userName']?.toString() ?? 'No name';
              final carModel = bookingData['carModel']?.toString() ?? 'Unknown Car';
              final amount = bookingData['amount']?.toString() ?? '400';
              final paymentMethod = bookingData['paymentMethod']?.toString() ?? 'UPI';
              final transactionId = bookingData['transactionId']?.toString() ?? 'PAY-1743987973843';
              final licenseNumber = bookingData['licenseNumber']?.toString() ?? 'Not provided';
              final location = bookingData['location']?.toString() ?? 'No location';
              final carId = bookingData['carId']?.toString() ?? 'Not available';
              final userId = bookingData['userId']?.toString() ?? 'Not available';

              final createdAt = bookingData['createdAt'] as Timestamp?;
              final updatedAt = bookingData['updatedAt'] as Timestamp?;
              final startDate = bookingData['startDate'] as Timestamp?;
              final endDate = bookingData['endDate'] as Timestamp?;

              final formattedCreatedAt = createdAt != null ? _formatDateTime(createdAt.toDate()) : 'Not available';
              final formattedUpdatedAt = updatedAt != null ? _formatDateTime(updatedAt.toDate()) : 'Not available';
              final formattedStartDate = startDate != null ? _formatDate(startDate.toDate()) : 'Not set';
              final formattedEndDate = endDate != null ? _formatDate(endDate.toDate()) : 'Not set';


              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.grey[850],
                child: InkWell(
                  onTap: () => _showBookingDetails(
                    context: context,
                    bookingData: bookingData,
                    bookingId: bookingId,
                    formattedCreatedAt: formattedCreatedAt,
                    formattedUpdatedAt: formattedUpdatedAt,
                    formattedStartDate: formattedStartDate,
                    formattedEndDate: formattedEndDate,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status and dropdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(currentStatus).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentStatus.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(currentStatus),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                              itemBuilder: (context) => ['pending', 'confirmed', 'completed', 'cancelled'].map((status) {
                                return PopupMenuItem<String>(
                                  value: status,
                                  child: Text(status[0].toUpperCase() + status.substring(1)),
                                );
                              }).toList(),
                              onSelected: (newStatus) => _updateBookingStatus(bookingId, newStatus),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // User and car info
                        Text(userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(carModel, style: TextStyle(color: Colors.grey[400])),
                        const SizedBox(height: 16),

                        // Rental period
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Date', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                Text(formattedStartDate, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End Date', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                Text(formattedEndDate, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Payment info
                        _buildPaymentRow('Amount', '₹$amount'),
                        _buildPaymentRow('Method', paymentMethod),
                        _buildPaymentRow('Transaction ID', transactionId),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500])),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showBookingDetails({
    required BuildContext context,
    required Map<String, dynamic> bookingData,
    required String bookingId,
    required String formattedCreatedAt,
    required String formattedUpdatedAt,
    required String formattedStartDate,
    required String formattedEndDate,
  }) {
    final statusColor = _getStatusColor(bookingData['status']?.toString() ?? 'pending');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
            constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
       // padding: const EdgeInsets.all(20),
        ),
          child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Center(
        child: Container(
        width: 60,
        height: 5,
        decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(10),
        ),
        ),
        ),
        const SizedBox(height: 20),

        // Booking ID
        _buildDetailRow('Booking ID', bookingId),
        const SizedBox(height: 16),

        // Status
        Center(
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
        bookingData['status']?.toString().toUpperCase() ?? 'PENDING',
        style: TextStyle(
        color: statusColor,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        ),
        ),
        ),
        ),
        const SizedBox(height: 20),

        // User Information
        const Text('USER INFORMATION', style: TextStyle(color: Colors.grey, fontSize: 12)),
        _buildDetailRow('Name', bookingData['userName']?.toString() ?? 'No name'),
        _buildDetailRow('User ID', bookingData['userId']?.toString() ?? 'Not available'),
        const SizedBox(height: 16),

        // Vehicle Information
        const Text('VEHICLE INFORMATION', style: TextStyle(color: Colors.grey, fontSize: 12)),
        _buildDetailRow('Car Model', bookingData['carModel']?.toString() ?? 'Unknown'),
        _buildDetailRow('Car ID', bookingData['carId']?.toString() ?? 'Not available'),
        _buildDetailRow('License Plate', bookingData['licenseNumber']?.toString() ?? 'Not provided'),
        const SizedBox(height: 16),

        // Rental Period
        const Text('RENTAL PERIOD', style: TextStyle(color: Colors.grey, fontSize: 12)),
        _buildDetailRow('Start Date', formattedStartDate),
        _buildDetailRow('End Date', formattedEndDate),
        _buildDetailRow('Location', bookingData['location']?.toString() ?? 'No location'),
        const SizedBox(height: 16),

        // Payment Information
        const Text('PAYMENT INFORMATION', style: TextStyle(color: Colors.grey, fontSize: 12)),
        _buildDetailRow('Amount', '₹${bookingData['amount']?.toString() ?? '400'}'),
        _buildDetailRow('Payment Method', bookingData['paymentMethod']?.toString() ?? 'UPI'),
        _buildDetailRow('Transaction ID', bookingData['transactionId']?.toString() ?? 'PAY-1743987973843'),
        const SizedBox(height: 16),

        // Timestamps
        const Text('TIMESTAMPS', style: TextStyle(color: Colors.grey, fontSize: 12)),
        _buildDetailRow('Created At', formattedCreatedAt),
        _buildDetailRow('Updated At', formattedUpdatedAt),
        const SizedBox(height: 24),

        // Close button
        SizedBox(
        width: double.infinity,
        child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('CLOSE'),
        ),
        ),
        const SizedBox(height: 10),
        ],
        ),
        ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

