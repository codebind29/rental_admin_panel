import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.createdAt,
  });

  factory Payment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'Unknown',
      transactionId: data['transactionId'] ?? 'Not available',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}