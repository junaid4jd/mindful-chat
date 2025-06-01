import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/providers/login_provider.dart';
import 'package:mental_health_app/screens/createAccount/create_account_screen.dart';
import 'package:mental_health_app/screens/dashboard/dashboard_screen.dart';
import 'package:mental_health_app/screens/counselor_dashboard/counselor_dashboard_screen.dart';
import 'package:mental_health_app/screens/admin_dashboard/admin_dashboard_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final String userRole;

  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<LogInProvider>(context, listen: false).init());
  }

  String _getRoleTitle() {
    switch (widget.userRole) {
      case 'counselor':
        return 'Counselor Login';
      case 'admin':
        return 'Admin Login';
      default:
        return 'User Login';
    }
  }

  String _getRoleSubtitle() {
    switch (widget.userRole) {
      case 'counselor':
        return 'Access your counselor dashboard';
      case 'admin':
        return 'Access admin panel';
      default:
        return 'Access your mental health support';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LogInProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                Icon(Icons.health_and_safety, size: 32, color: AppColors.purpleColor),
                SizedBox(width: 8),
                Text(
                  'Mindful',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purpleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Login card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRoleTitle(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getRoleSubtitle(),
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    const Text('Email Address'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: provider.emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.mail, color: AppColors.purpleColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    const Text('Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: provider.passwordController,
                      obscureText: provider.obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock, color: AppColors.purpleColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            provider.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: provider.togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) =>
                      value != null && value.length < 6
                          ? 'Minimum 6 characters'
                          : null,
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child:  Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppColors.purpleColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Login button
                    provider.isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.purpleColor,
                      ),
                    )
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(41),
                        ),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        String result = await provider.signInWithRole(widget
                            .userRole);
                        if (result == 'Sign-in successful') {
                          // Navigate based on role
                          switch (widget.userRole) {
                            case 'counselor':
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CounselorDashboardScreen()),
                              );
                              break;
                            case 'admin':
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AdminDashboardScreen()),
                              );
                              break;
                            default:
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DashboardScreen()),
                              );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        }
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sign Up
            if (widget.userRole != 'admin')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateAccountScreen(userRole: widget.userRole),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: AppColors.purpleColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
