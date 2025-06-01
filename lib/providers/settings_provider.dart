import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/screens/role_selection/role_selection_screen.dart';

class SettingsProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  bool _isLoading = false;

  String get name => _name;

  String get email => _email;

  bool get isLoading => _isLoading;

  SettingsProvider() {
    init();
  }

  Future<String> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _name = data['fullName'] ?? 'User';
          _email = data['email'] ?? user.email ?? '';
        } else {
          _name = user.displayName ?? 'User';
          _email = user.email ?? '';
        }
      } catch (e) {
        _name = user.displayName ?? 'User';
        _email = user.email ?? '';
      }
    }
    notifyListeners();
    return _name;
  }

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  // Sign out method
  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
