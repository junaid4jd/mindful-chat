import 'package:flutter/material.dart';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/constants/app_lists.dart';
import 'package:mental_health_app/providers/bottom_nav_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNav = Provider.of<BottomNavProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle:  false,
        title: Text(
          bottomNav.currentIndex == 0 ? 'MindfulChat' :
          bottomNav.currentIndex == 1 ? 'MindfulBot' :
          bottomNav.currentIndex == 2 ? 'Counselors' : 'Profile',

          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: pages[bottomNav.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        elevation: 1,
        currentIndex: bottomNav.currentIndex,
        onTap: (index) => bottomNav.setIndex(index, context),
        selectedItemColor: AppColors.purpleColor,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Counselor',),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profile',),
        ],
      ),
    );
  }
}
