import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogInProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text Editing Controllers for email and password
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Obscure password toggle
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void init() {
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Sign-in method with role validation
  Future<String> signInWithRole(String expectedRole) async {
    try {
      _isLoading = true;
      notifyListeners();

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter both email and password';
      }

      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter a valid email address';
      }

      // Attempt Firebase sign-in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Check user role in Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String userRole = userDoc.get('role') ?? 'user';

          // Validate role matches expected role
          if (userRole != expectedRole) {
            await _auth.signOut(); // Sign out if role doesn't match
            _isLoading = false;
            notifyListeners();
            return 'Access denied. Please check your role and try again.';
          }

          _isLoading = false;
          notifyListeners();
          return 'Sign-in successful';
        } else {
          await _auth.signOut();
          _isLoading = false;
          notifyListeners();
          return 'User data not found. Please contact support.';
        }
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Error: Sign-in failed';
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message ?? 'An error occurred';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Something went wrong. Please try again later';
    }
  }

  // Original sign-in method (keep for backward compatibility)
  Future<String> signIn() async {
    return signInWithRole('user'); // Default to user role
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
