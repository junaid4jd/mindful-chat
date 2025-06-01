import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_app/model/chat_model.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a chat room when booking is accepted
  static Future<String> createChatRoom({
    required String bookingId,
    required String userId,
    required String userName,
    required String counselorId,
    required String counselorName,
  }) async {
    try {
      final chatRoomData = {
        'bookingId': bookingId,
        'userId': userId,
        'userName': userName,
        'counselorId': counselorId,
        'counselorName': counselorName,
        'lastMessage': 'Chat room created',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'unreadCountUser': 0,
        'unreadCountCounselor': 0,
      };

      DocumentReference chatRoomRef = await _firestore
          .collection('chatRooms')
          .add(chatRoomData);

      // Update the booking with chat room ID
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({'chatRoomId': chatRoomRef.id});

      // Send initial message
      await sendMessage(
        chatRoomId: chatRoomRef.id,
        message: 'Hello! Your counseling session chat is now active. Feel free to start the conversation.',
        senderRole: 'system',
        senderName: 'System',
      );

      return chatRoomRef.id;
    } catch (e) {
      print('Error creating chat room: $e');
      throw e;
    }
  }

  // Send a message
  static Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    String? senderRole,
    String? senderName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null && senderRole != 'system') return;

      String actualSenderRole = senderRole ?? 'user';
      String actualSenderName = senderName ?? 'Unknown';

      if (senderRole == null) {
        // Get user info to determine role
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String,
              dynamic>;
          actualSenderRole = userData['role'] ?? 'user';
          actualSenderName = userData['fullName'] ?? 'Unknown';
        }
      }

      final messageData = {
        'chatRoomId': chatRoomId,
        'senderId': senderRole == 'system' ? 'system' : currentUser!.uid,
        'senderName': actualSenderName,
        'senderRole': actualSenderRole,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore.collection('messages').add(messageData);

      // Update chat room with last message
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        // Increment unread count for the other user
        actualSenderRole == 'user'
            ? 'unreadCountCounselor'
            : 'unreadCountUser': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  // Get messages for a chat room
  static Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('messages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .snapshots();
  }

  // Get chat rooms for current user - simplified query
  static Stream<QuerySnapshot> getChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.empty();
    }

    // We'll fetch all chat rooms and filter client-side to avoid complex queries
    return _firestore
        .collection('chatRooms')
        .snapshots();
  }

  // Get chat rooms for user - simplified query
  static Stream<QuerySnapshot> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Get chat rooms for counselor - simplified query
  static Stream<QuerySnapshot> getCounselorChatRooms(String counselorId) {
    return _firestore
        .collection('chatRooms')
        .where('counselorId', isEqualTo: counselorId)
        .snapshots();
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String chatRoomId,
      String userRole) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Update unread count in chat room
      String unreadField = userRole == 'user'
          ? 'unreadCountUser'
          : 'unreadCountCounselor';
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        unreadField: 0,
      });

      // Mark messages as read - simplified query
      QuerySnapshot unreadMessages = await _firestore
          .collection('messages')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in unreadMessages.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Only mark as read if it's not from current user
        if (data['senderId'] != currentUser.uid) {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();

    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Check if user has access to chat room
  static Future<bool> hasAccessToChatRoom(String chatRoomId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot chatRoom = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .get();

      if (!chatRoom.exists) return false;

      Map<String, dynamic> data = chatRoom.data() as Map<String, dynamic>;
      return data['userId'] == currentUser.uid ||
          data['counselorId'] == currentUser.uid;
    } catch (e) {
      print('Error checking chat room access: $e');
      return false;
    }
  }

  // Filter chat rooms for current user (client-side filtering)
  static List<QueryDocumentSnapshot> filterChatRoomsForCurrentUser(
      List<QueryDocumentSnapshot> allChatRooms,
      String currentUserId,) {
    return allChatRooms.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return (data['userId'] == currentUserId ||
          data['counselorId'] == currentUserId) &&
          (data['isActive'] == true);
    }).toList();
  }
}
