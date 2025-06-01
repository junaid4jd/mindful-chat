import 'package:flutter/material.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/providers/create_account_provider.dart';
import 'package:mental_health_app/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

class CreateAccountScreen extends StatefulWidget {
  final String userRole;

  const CreateAccountScreen({Key? key, required this.userRole})
      : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CreateAccountProvider>(context, listen: false).init());
  }

  String _getRoleTitle() {
    switch (widget.userRole) {
      case 'counselor':
        return 'Counselor Registration';
      case 'admin':
        return 'Admin Registration';
      default:
        return 'User Registration';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreateAccountProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset("assets/images/loving.png", height: 150),
              const SizedBox(height: 20),
              Text(
                _getRoleTitle(),
                style: const TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              const Text("Your journey to better mental health starts here",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.deepPurple)),

              const SizedBox(height: 30),
              _buildTextField(
                  "Full Name", Icons.person, provider.fullNameController),
              const SizedBox(height: 12),
              _buildTextField(
                  "Email", Icons.email, provider.emailController, email: true),
              const SizedBox(height: 12),
              _buildTextField(
                  "Password", Icons.lock, provider.passwordController,
                  obscure: true),
              const SizedBox(height: 12),
              _buildTextField("Confirm Password", Icons.lock_outline,
                  provider.confirmController, obscure: true),

              if (widget.userRole == 'counselor') ...[
                const SizedBox(height: 12),
                _buildTextField(
                    "Specialization", Icons.medical_services_outlined,
                    provider.specializationController,
                    hint: 'e.g., Clinical Psychology, Family Therapy'),
                const SizedBox(height: 12),
                _buildTextField("Years of Experience", Icons.work_outline,
                    provider.experienceController, hint: 'e.g., 5 years'),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      provider.createAccount(context, widget.userRole),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Create Account',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) =>
                          LoginScreen(userRole: widget.userRole)));
                },
                child: const Text("Already have an account? Log in",
                    style: TextStyle(color: Colors.deepPurple)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller,
      {String? hint, bool obscure = false, bool email = false}) {
    final provider = Provider.of<CreateAccountProvider>(context);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter $label';
        if (email && !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter valid email';
        if (label == "Confirm Password" && value != provider.passwordController.text) return 'Passwords do not match';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF7C3AED)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
