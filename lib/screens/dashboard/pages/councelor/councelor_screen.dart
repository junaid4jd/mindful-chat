import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/constants/app_lists.dart';
import 'package:mental_health_app/model/counselor_model.dart';
import 'package:mental_health_app/screens/booking/booking_screen.dart';
import 'package:mental_health_app/screens/chat/user_counselor_chat_screen.dart';

class CounselorScreen extends StatefulWidget {
  @override
  State<CounselorScreen> createState() => _CounselorScreenState();
}

class _CounselorScreenState extends State<CounselorScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _debugFirebaseConnection();
  }

  void _debugFirebaseConnection() async {
    try {
      // Test authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      print('DEBUG - Current user: ${currentUser?.uid}');
      print('DEBUG - User email: ${currentUser?.email}');
      print('DEBUG - Is authenticated: ${currentUser != null}');

      // Test basic Firestore read
      print('DEBUG - Testing Firestore connection...');
      final testQuery = await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get();
      print('DEBUG - Firestore connection successful');
      print('DEBUG - Test query returned ${testQuery.docs.length} documents');

      // Test counselor query specifically
      final counselorQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'counselor')
          .get();
      print('DEBUG - Counselor query returned ${counselorQuery.docs
          .length} documents');

      // List all users to see what's in the collection
      final allUsers = await FirebaseFirestore.instance
          .collection('users')
          .get();
      print('DEBUG - Total users in collection: ${allUsers.docs.length}');

      for (var doc in allUsers.docs) {
        var data = doc.data();
        print(
            'DEBUG - User: ${data['fullName']} - Role: ${data['role']} - Availability: ${data['availability']}');
      }

      // Test bookings collection
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .get();
      print(
          'DEBUG - Total bookings in collection: ${bookingsQuery.docs.length}');
    } catch (e) {
      print('DEBUG - Firebase connection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTab == 0 ? AppColors.purpleColor : Colors
                          .transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Find Counselors',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedTab == 0 ? Colors.white : Colors
                            .grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTab == 1 ? AppColors.purpleColor : Colors
                          .transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'My Bookings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedTab == 1 ? Colors.white : Colors
                            .grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: _selectedTab == 0
              ? _buildCounselorsTab()
              : _buildBookingsTab(),
        ),
      ],
    );
  }

  Widget _buildCounselorsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            SizedBox(height: 24),
            Text("ONLINE NOW", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            SizedBox(height: 12),
            _buildCounselorsList(context, true),
            SizedBox(height: 24),
            Text("OFFLINE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            SizedBox(height: 12),
            _buildCounselorsList(context, false),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        print('User Bookings - Connection state: ${snapshot.connectionState}');
        print('User Bookings - Has data: ${snapshot.hasData}');
        print('User Bookings - Docs count: ${snapshot.data?.docs.length ?? 0}');
        print('User Bookings - Current user ID: ${currentUser?.uid}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('User Bookings - Error: ${snapshot.error}');
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
          return _buildEmptyBookingsState();
        }

        // Sort bookings by status and creation time
        List<QueryDocumentSnapshot> sortedBookings = snapshot.data!.docs
            .toList();
        sortedBookings.sort((a, b) {
          Map<String, dynamic> aData = a.data() as Map<String, dynamic>;
          Map<String, dynamic> bData = b.data() as Map<String, dynamic>;

          String aStatus = aData['status'] ?? 'pending';
          String bStatus = bData['status'] ?? 'pending';

          // Show pending bookings first
          if (aStatus == 'pending' && bStatus != 'pending') return -1;
          if (bStatus == 'pending' && aStatus != 'pending') return 1;

          return 0;
        });

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sortedBookings.length,
            itemBuilder: (context, index) {
              var booking = sortedBookings[index];
              print('Building user booking card for: ${booking.id}');
              return _buildBookingCard(booking);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyBookingsState() {
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
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Book a session with a counselor to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(QueryDocumentSnapshot booking) {
    Map<String, dynamic> data = booking.data() as Map<String, dynamic>;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purpleColor.withOpacity(0.1),
                child: Icon(
                    Icons.medical_services, color: AppColors.purpleColor),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['counselorName'] ?? 'Unknown Counselor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      data['sessionType'] ?? 'Session',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildBookingStatusChip(data['status'] ?? 'pending'),
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

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.payment, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Payment: ${data['paymentMethod'] ?? 'Unknown'}',
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
                    'Your Message:',
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

          // Show status-specific information
          if (data['status'] == 'accepted') ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your session has been confirmed! You can now chat with your counselor.',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            if (data['chatRoomId'] != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserCounselorChatScreen(
                              chatRoomId: data['chatRoomId'],
                              otherUserName: data['counselorName'] ??
                                  'Counselor',
                              bookingId: booking.id,
                            ),
                      ),
                    );
                  },
                  icon: Icon(Icons.chat, size: 18),
                  label: Text('Start Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ] else
            if (data['status'] == 'rejected') ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This session request was declined. Please try booking with another counselor.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ] else
            ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange,
                        size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waiting for counselor to respond to your request.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildBookingStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = 'Confirmed';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Declined';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search counselors...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorsList(BuildContext context, bool isOnline) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'counselor')
          .where(
          'availability', isEqualTo: isOnline ? 'Available' : 'Unavailable')
          .snapshots(),
      builder: (context, snapshot) {
        // Enhanced debugging
        print(
            'Counselors Query - Connection state: ${snapshot.connectionState}');
        print('Counselors Query - Has data: ${snapshot.hasData}');
        print('Counselors Query - Error: ${snapshot.error}');
        print('Counselors Query - Online filter: $isOnline');
        print('Counselors Query - Availability filter: ${isOnline
            ? 'Available'
            : 'Unavailable'}');

        if (snapshot.hasData) {
          print('Counselors Query - Total docs: ${snapshot.data!.docs.length}');
          // Log each counselor found
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            print(
                'Found counselor: ${data['fullName']} - Role: ${data['role']} - Availability: ${data['availability']}');
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('Counselors Query - Detailed Error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 60, color: Colors.red),
                SizedBox(height: 16),
                Text('Error loading counselors: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isOnline);
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return _buildCounselorCard(context, data, doc.id, isOnline);
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isOnline) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          isOnline ? 'No counselors online' : 'No offline counselors',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildCounselorCard(BuildContext context,
      Map<String, dynamic> counselorData, String counselorId, bool isOnline) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.purpleColor.withOpacity(0.1),
                child: Icon(
                    Icons.person, color: AppColors.purpleColor, size: 30),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counselorData['fullName'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  counselorData['specialization'] ?? 'General Counseling',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  'Experience: ${counselorData['experience'] ??
                      'Not specified'}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                SizedBox(height: 8),
                if (!isOnline)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Counselor not available right now',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                if (isOnline)
                  Row(
                    children: [
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingScreen(
                                      counselorId: counselorId,
                                      counselorName: counselorData['fullName'] ??
                                          'Unknown',
                                      counselorSpecialization: counselorData['specialization'] ??
                                          'General',
                                    ),
                              ),
                            );
                          },
                          child: Text('Book Session', style: TextStyle(
                              fontSize: 13, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purpleColor,
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Start Call', style: TextStyle(
                              fontSize: 13, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
