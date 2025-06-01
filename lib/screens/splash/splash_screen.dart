import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/screens/dashboard/dashboard_screen.dart';
import 'package:mental_health_app/screens/role_selection/role_selection_screen.dart';
import 'package:mental_health_app/screens/counselor_dashboard/counselor_dashboard_screen.dart';
import 'package:mental_health_app/screens/admin_dashboard/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _navigateAfterDelay();
  }

  _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 4));
    if (mounted) {
      // Check if user is already logged in
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Get user role from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (userDoc.exists) {
            String role = userDoc.get('role') ?? 'user';
            switch (role) {
              case 'admin':
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AdminDashboardScreen()));
                break;
              case 'counselor':
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CounselorDashboardScreen()));
                break;
              default:
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen()));
            }
            return;
          }
        } catch (e) {
          print('Error getting user data: $e');
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Heart icon and title
            Column(
              children: [
                // Logo with animation
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 3,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 60,
                      color: AppColors.purpleColor,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // App name
                Text(
                  'MindfulChat',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Your Mental Health Companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Loading indicator
            Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.purpleColor),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Bottom tagline
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                'Connecting you with care',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
