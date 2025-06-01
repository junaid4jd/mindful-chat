import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String counselorId;
  final String counselorName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final bool isActive;
  final int unreadCountUser;
  final int unreadCountCounselor;

  ChatRoom({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.counselorId,
    required this.counselorName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.isActive,
    this.unreadCountUser = 0,
    this.unreadCountCounselor = 0,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      counselorId: data['counselorId'] ?? '',
      counselorName: data['counselorName'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      unreadCountUser: data['unreadCountUser'] ?? 0,
      unreadCountCounselor: data['unreadCountCounselor'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'counselorId': counselorId,
      'counselorName': counselorName,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'unreadCountUser': unreadCountUser,
      'unreadCountCounselor': unreadCountCounselor,
    };
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'user' or 'counselor'
  final String message;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      chatRoomId: data['chatRoomId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}