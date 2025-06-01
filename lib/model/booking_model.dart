import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String counselorId;
  final String counselorName;
  final String sessionType;
  final String appointmentDate;
  final String appointmentTime;
  final String message;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? chatRoomId;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.counselorId,
    required this.counselorName,
    required this.sessionType,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.message,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.chatRoomId,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      counselorId: data['counselorId'] ?? '',
      counselorName: data['counselorName'] ?? '',
      sessionType: data['sessionType'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      message: data['message'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      chatRoomId: data['chatRoomId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'counselorId': counselorId,
      'counselorName': counselorName,
      'sessionType': sessionType,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'message': message,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'chatRoomId': chatRoomId,
    };
  }
}
