import 'package:cloud_firestore/cloud_firestore.dart';


class Booking {
  final String id;
  final String carId;
  final String carImage;
  final String carModel;
  final String licenseNumber;
  final String location;
  final String userId;
  final String userName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime timestamp;
  final double totalPrice;
  final bool? depositReturned;

  Booking({
    required this.id,
    required this.carId,
    required this.carImage,
    required this.carModel,
    required this.licenseNumber,
    required this.location,
    required this.userId,
    required this.userName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.timestamp,
    required this.totalPrice,
    this.depositReturned,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      carId: map['carId'] ?? '',
      carImage: map['carImage'] ?? '',
      carModel: map['carModel'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      location: map['location'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      status: map['status'] ?? 'pending',
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : map['startDate'] as DateTime,
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : map['endDate'] as DateTime,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : map['timestamp'] as DateTime,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      depositReturned: map['depositReturned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carImage': carImage,
      'carModel': carModel,
      'licenseNumber': licenseNumber,
      'location': location,
      'userId': userId,
      'userName': userName,
      'status': status,
      'startDate': startDate is DateTime
          ? Timestamp.fromDate(startDate)
          : startDate,
      'endDate': endDate is DateTime
          ? Timestamp.fromDate(endDate)
          : endDate,
      'timestamp': timestamp is DateTime
          ? Timestamp.fromDate(timestamp)
          : timestamp,
      'totalPrice': totalPrice,
      'depositReturned': depositReturned,
    };
  }
}