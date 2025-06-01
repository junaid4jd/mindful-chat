import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_health_app/screens/login/login_screen.dart';

class CreateAccountProvider extends ChangeNotifier {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();

  bool isLoading = false;

  void init() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmController.clear();
    specializationController.clear();
    experienceController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> createAccount(BuildContext context, String userRole) async {
    // Prevent admin account creation
    if (userRole == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Admin accounts cannot be created through signup')),
      );
      return;
    }

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name is required')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required')),
      );
      return;
    }

    if (confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirm Password is required')),
      );
      return;
    }

    if (confirm != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password and Confirm Password must be same')),
      );
      return;
    }

    // Additional validation for counselors
    if (userRole == 'counselor') {
      if (specializationController.text
          .trim()
          .isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Specialization is required for counselors')),
        );
        return;
      }

      if (experienceController.text
          .trim()
          .isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Experience is required for counselors')),
        );
        return;
      }
    }

    try {
      isLoading = true;
      notifyListeners();

      // Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Prepare user data
      Map<String, dynamic> userData = {
        'uid': userCredential.user!.uid,
        'fullName': fullName,
        'email': email,
        'role': userRole,
        'createdAt': Timestamp.now(),
      };

      // Add role-specific data
      if (userRole == 'counselor') {
        userData.addAll({
          'specialization': specializationController.text.trim(),
          'experience': experienceController.text.trim(),
          'availability': 'Available',
          'isVerified': false, // Counselors need verification
        });
      }

      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      // Navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen(userRole: userRole)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            'Account created successfully as ${userRole.toUpperCase()}')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Account creation failed')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
