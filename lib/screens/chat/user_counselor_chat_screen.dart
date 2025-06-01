import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/model/chat_model.dart';
import 'package:mental_health_app/services/chat_service.dart';

class UserCounselorChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String bookingId;

  const UserCounselorChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.otherUserName,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<UserCounselorChatScreen> createState() =>
      _UserCounselorChatScreenState();
}

class _UserCounselorChatScreenState extends State<UserCounselorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _currentUserRole = 'user';
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUserInfo();
    _markMessagesAsRead();
  }

  void _getCurrentUserInfo() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _currentUserRole = userData['role'] ?? 'user';
          _currentUserName = userData['fullName'] ?? 'Unknown';
        });
      }
    }
  }

  void _markMessagesAsRead() async {
    await ChatService.markMessagesAsRead(widget.chatRoomId, _currentUserRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.purpleColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: AppColors.purpleColor,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.otherUserName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    _currentUserRole == 'user' ? 'Counselor' : 'Client',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'booking_details':
                  _showBookingDetails();
                  break;
                case 'end_chat':
                  _showEndChatDialog();
                  break;
              }
            },
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                value: 'booking_details',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Booking Details'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'end_chat',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 8),
                    Text('End Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ChatService.getMessages(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading messages: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort messages client-side by creation time (newest first)
                List<QueryDocumentSnapshot> messages = snapshot.data!.docs
                    .toList();
                messages.sort((a, b) {
                  Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
                  Map<String, dynamic> bData = b.data() as Map<String, dynamic>;

                  Timestamp? aTime = aData['createdAt'] as Timestamp?;
                  Timestamp? bTime = bData['createdAt'] as Timestamp?;

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return bTime.compareTo(aTime);
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageDoc = messages[index];
                    var messageData = messageDoc.data() as Map<String, dynamic>;

                    return _buildMessageBubble(messageData);
                  },
                );
              },
            ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final currentUser = _auth.currentUser;
    final isMe = messageData['senderId'] == currentUser?.uid;
    final isSystem = messageData['senderRole'] == 'system';
    final timestamp = (messageData['createdAt'] as Timestamp?)?.toDate();

    if (isSystem) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              messageData['message'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment
            .start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.purpleColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.purpleColor,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.purpleColor : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: isMe ? Radius.circular(20) : Radius.circular(
                          4),
                      bottomRight: isMe ? Radius.circular(4) : Radius.circular(
                          20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Text(
                    messageData['message'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timestamp != null
                      ? DateFormat('MMM d, h:mm a').format(timestamp)
                      : 'Just now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.purpleColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.purpleColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.purpleColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    try {
      await ChatService.sendMessage(
        chatRoomId: widget.chatRoomId,
        message: message,
      );

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookingDetails() async {
    try {
      DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (bookingDoc.exists) {
        Map<String, dynamic> bookingData = bookingDoc.data() as Map<
            String,
            dynamic>;

        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Booking Details'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Session Type', bookingData['sessionType'] ?? 'N/A'),
                    _buildDetailRow(
                        'Date', bookingData['appointmentDate'] ?? 'N/A'),
                    _buildDetailRow(
                        'Time', bookingData['appointmentTime'] ?? 'N/A'),
                    _buildDetailRow(
                        'Amount', '\$${bookingData['amount'] ?? 0}'),
                    _buildDetailRow('Status', bookingData['status'] ?? 'N/A'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading booking details')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEndChatDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('End Chat'),
            content: Text(
                'Are you sure you want to end this conversation? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // Could add functionality to mark chat as inactive
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('End Chat'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
