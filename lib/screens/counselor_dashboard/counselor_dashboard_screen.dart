import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/model/booking_model.dart';
import 'package:mental_health_app/services/chat_service.dart';
import 'package:mental_health_app/screens/splash/splash_screen.dart';
import 'package:mental_health_app/screens/chat/user_counselor_chat_screen.dart';

class CounselorDashboardScreen extends StatefulWidget {
  @override
  State<CounselorDashboardScreen> createState() =>
      _CounselorDashboardScreenState();
}

class _CounselorDashboardScreenState extends State<CounselorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _getTitle(),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.purpleColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Booking Requests';
      case 1:
        return 'Chats';
      case 2:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return BookingRequestsTab();
      case 1:
        return ChatsTab();
      case 2:
        return CounselorProfileTab();
      default:
        return BookingRequestsTab();
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false,
    );
  }
}

class BookingRequestsTab extends StatefulWidget {
  @override
  State<BookingRequestsTab> createState() => _BookingRequestsTabState();
}

class _BookingRequestsTabState extends State<BookingRequestsTab> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('counselorId', isEqualTo: currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        print('Counselor Dashboard - Connection state: ${snapshot
            .connectionState}');
        print('Counselor Dashboard - Has data: ${snapshot.hasData}');
        print('Counselor Dashboard - Docs count: ${snapshot.data?.docs.length ??
            0}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Counselor Dashboard - Error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 60, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading bookings: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // Sort bookings by status (pending first) and then by creation
        List<QueryDocumentSnapshot> sortedBookings = snapshot.data!.docs
            .toList();
        sortedBookings.sort((a, b) {
          Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
          Map<String, dynamic> bData = b.data() as Map<String, dynamic>;

          String aStatus = aData['status'] ?? 'pending';
          String bStatus = bData['status'] ?? 'pending';

          // Pending bookings first
          if (aStatus == 'pending' && bStatus != 'pending') return -1;
          if (bStatus == 'pending' && aStatus != 'pending') return 1;

          return 0;
        });

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh
            setState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sortedBookings.length,
            itemBuilder: (context, index) {
              var booking = sortedBookings[index];
              print('Building booking card for: ${booking.id}');
              return _buildBookingCard(context, booking);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No booking requests yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context,
      QueryDocumentSnapshot booking) {
    Map<String, dynamic> data = booking.data() as Map<String, dynamic>;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purpleColor.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: AppColors.purpleColor),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['userName'] ?? 'Unknown User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      data['userEmail'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Session: ${data['sessionType'] ?? 'Unknown'}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(data['status'] ?? 'pending'),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Date: ${data['appointmentDate'] ?? 'Not specified'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Time: ${data['appointmentTime'] ?? 'Not specified'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Amount: \$${data['amount'] ?? '0'}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),

          if (data['message'] != null && data['message'].isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    data['message'],
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],

          if (data['status'] == 'pending') ...[
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateBookingStatus(booking.id, 'accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Accept'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _updateBookingStatus(booking.id, 'rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  void _updateBookingStatus(String bookingId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If booking is accepted, create a chat room
      if (status == 'accepted') {
        // Get the booking details to create chat room
        DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .get();

        if (bookingDoc.exists) {
          Map<String, dynamic> bookingData = bookingDoc.data() as Map<
              String,
              dynamic>;

          // Create chat room
          await ChatService.createChatRoom(
            bookingId: bookingId,
            userId: bookingData['userId'],
            userName: bookingData['userName'],
            counselorId: bookingData['counselorId'],
            counselorName: bookingData['counselorName'],
          );
        }
      }

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'accepted'
              ? 'Booking accepted successfully! Chat room created.'
              : 'Booking ${status.toLowerCase()} successfully'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ChatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: ChatService.getCounselorChatRooms(currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 60, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading chats: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () {
                    // Trigger rebuild
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Filter and sort chat rooms client-side
        List<QueryDocumentSnapshot> chatRooms = snapshot.data!.docs
            .where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['isActive'] == true;
        })
            .toList();

        // Sort by last message time (newest first)
        chatRooms.sort((a, b) {
          Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
          Map<String, dynamic> bData = b.data() as Map<String, dynamic>;

          Timestamp? aTime = aData['lastMessageTime'] as Timestamp?;
          Timestamp? bTime = bData['lastMessageTime'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });

        if (chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No active chats',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Chat rooms will appear here when you accept booking requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            var chatDoc = chatRooms[index];
            Map<String, dynamic> chatData = chatDoc.data() as Map<
                String,
                dynamic>;

            return _buildChatTile(context, chatDoc.id, chatData);
          },
        );
      },
    );
  }

  Widget _buildChatTile(BuildContext context, String chatRoomId,
      Map<String, dynamic> chatData) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.purpleColor.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: AppColors.purpleColor,
          ),
        ),
        title: Text(
          chatData['userName'] ?? 'Unknown User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              chatData['lastMessage'] ?? 'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              ChatUtils.formatTimestamp(chatData['lastMessageTime']),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if ((chatData['unreadCountCounselor'] ?? 0) > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purpleColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chatData['unreadCountCounselor']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserCounselorChatScreen(
                    chatRoomId: chatRoomId,
                    otherUserName: chatData['userName'] ?? 'Unknown User',
                    bookingId: chatData['bookingId'] ?? '',
                  ),
            ),
          );
        },
      ),
    );
  }
}

class CounselorProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('Profile not found'));
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<
            String,
            dynamic>;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.purpleColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.purpleColor,
                ),
              ),

              SizedBox(height: 20),

              Text(
                userData['fullName'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                userData['email'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 8),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.purpleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Counselor',
                  style: TextStyle(
                    color: AppColors.purpleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 30),

              _buildInfoCard('Specialization',
                  userData['specialization'] ?? 'General Counseling'),
              SizedBox(height: 16),
              _buildInfoCard(
                  'Experience', userData['experience'] ?? 'Not specified'),
              SizedBox(height: 16),
              _buildInfoCard(
                  'Availability', userData['availability'] ?? 'Available'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatUtils {
  static String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
