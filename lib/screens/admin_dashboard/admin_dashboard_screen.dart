import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/screens/splash/splash_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
            icon: Icon(Icons.add_circle, color: Colors.green),
            onPressed: _createTestData,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Counselors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Manage Users';
      case 2:
        return 'Manage Counselors';
      case 3:
        return 'All Bookings';
      default:
        return 'Admin Panel';
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return AdminOverviewTab();
      case 1:
        return ManageUsersTab();
      case 2:
        return ManageCounselorsTab();
      case 3:
        return AllBookingsTab();
      default:
        return AdminOverviewTab();
    }
  }

  void _createTestData() async {
    try {
      // Create test counselor
      await FirebaseFirestore.instance.collection('users').add({
        'uid': 'test_counselor_${DateTime
            .now()
            .millisecondsSinceEpoch}',
        'fullName': 'Dr. Test Counselor',
        'email': 'test.counselor@example.com',
        'role': 'counselor',
        'specialization': 'Clinical Psychology',
        'experience': '5 years',
        'availability': 'Available',
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create test booking
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance.collection('bookings').add({
          'userId': currentUser.uid,
          'userName': 'Test User',
          'userEmail': currentUser.email ?? 'test@example.com',
          'counselorId': 'test_counselor_id',
          'counselorName': 'Dr. Test Counselor',
          'sessionType': 'Video Call',
          'appointmentDate': '01/01/2025',
          'appointmentTime': '10:00 AM',
          'message': 'This is a test booking',
          'amount': 50.00,
          'paymentMethod': 'Credit Card',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test data created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test data: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

class AdminOverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),

          // Statistics Cards
          Row(
            children: [
              Expanded(child: _buildStatCard(
                  'Total Users', Icons.people, _getUserCount)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard(
                  'Total Counselors', Icons.medical_services,
                  _getCounselorCount)),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildStatCard(
                  'Total Bookings', Icons.book_online, _getBookingCount)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard(
                  'Pending Requests', Icons.pending, _getPendingBookings)),
            ],
          ),

          SizedBox(height: 30),

          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  'New user registered',
                  'John Doe joined as a user',
                  Icons.person_add,
                  Colors.green,
                ),
                _buildActivityItem(
                  'Booking confirmed',
                  'Dr. Smith accepted a session',
                  Icons.check_circle,
                  Colors.blue,
                ),
                _buildActivityItem(
                  'New counselor',
                  'Dr. Jane registered as counselor',
                  Icons.medical_services,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon,
      Future<int> Function() countFunction) {
    return Container(
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
              Icon(icon, color: AppColors.purpleColor),
              Spacer(),
              FutureBuilder<int>(
                future: countFunction(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data?.toString() ?? '0',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.purpleColor,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon,
      Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _getUserCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getCounselorCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'counselor')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getBookingCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getPendingBookings() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

class ManageUsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No users found', Icons.people);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var user = snapshot.data!.docs[index];
            Map<String, dynamic> userData = user.data() as Map<String, dynamic>;
            return _buildUserCard(userData, user.id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String userId) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.purpleColor.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.purpleColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['fullName'] ?? 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  userData['email'] ?? '',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Role: ${userData['role'] ?? 'user'}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) =>
            [
              PopupMenuItem(
                child: Text('View Details'),
                value: 'view',
              ),
              PopupMenuItem(
                child: Text('Suspend User'),
                value: 'suspend',
              ),
            ],
            onSelected: (value) {
              if (value == 'view') {
                _showUserDetails(userData);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> userData) {
    // Implementation for showing user details
  }
}

class ManageCounselorsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'counselor')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
              'No counselors found', Icons.medical_services);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var counselor = snapshot.data!.docs[index];
            Map<String, dynamic> counselorData = counselor.data() as Map<
                String,
                dynamic>;
            return _buildCounselorCard(counselorData, counselor.id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselorCard(Map<String, dynamic> counselorData,
      String counselorId) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.purpleColor.withValues(alpha: 0.1),
                child: Icon(
                    Icons.medical_services, color: AppColors.purpleColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counselorData['fullName'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      counselorData['email'] ?? '',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (counselorData['availability'] == 'Available' ? Colors
                      .green : Colors.grey).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  counselorData['availability'] ?? 'Unknown',
                  style: TextStyle(
                    color: counselorData['availability'] == 'Available' ? Colors
                        .green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          if (counselorData['specialization'] != null)
            Text(
              'Specialization: ${counselorData['specialization']}',
              style: TextStyle(color: Colors.grey[700]),
            ),

          if (counselorData['experience'] != null)
            Text(
              'Experience: ${counselorData['experience']}',
              style: TextStyle(color: Colors.grey[700]),
            ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _toggleAvailability(counselorId, counselorData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Toggle Status'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewCounselorBookings(counselorId),
                  child: Text('View Bookings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(String counselorId,
      Map<String, dynamic> counselorData) async {
    String newStatus = counselorData['availability'] == 'Available'
        ? 'Unavailable'
        : 'Available';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(counselorId)
          .update({'availability': newStatus});
    } catch (e) {
      print('Error updating availability: $e');
    }
  }

  void _viewCounselorBookings(String counselorId) {
    // Implementation for viewing counselor bookings
  }
}

class AllBookingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No bookings found', Icons.book_online);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var booking = snapshot.data!.docs[index];
            Map<String, dynamic> bookingData = booking.data() as Map<
                String,
                dynamic>;
            return _buildBookingCard(bookingData, booking.id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> bookingData, String bookingId) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bookingData['userName']} → ${bookingData['counselorName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      bookingData['sessionType'] ?? 'Unknown Session',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(bookingData['status'] ?? 'pending'),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                  '${bookingData['appointmentDate']} at ${bookingData['appointmentTime']}'),
            ],
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                  '\$${bookingData['amount']} via ${bookingData['paymentMethod']}'),
            ],
          ),

          if (bookingData['message'] != null &&
              bookingData['message'].isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bookingData['message'],
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
