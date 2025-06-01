import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mental_health_app/providers/bottom_nav_provider.dart';
import 'package:mental_health_app/providers/create_account_provider.dart';
import 'package:mental_health_app/providers/login_provider.dart';
import 'package:mental_health_app/providers/settings_provider.dart';
import 'package:mental_health_app/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create default admin account if it doesn't exist
  await createDefaultAdmin();

  runApp(const MyApp());
}

Future<void> createDefaultAdmin() async {
  try {
    // Check if admin already exists
    QuerySnapshot adminQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .where('email', isEqualTo: 'admin@mindfulchat.com')
        .get();

    if (adminQuery.docs.isNotEmpty) {
      print('Admin account already exists');
      return;
    }

    // Create admin account
    UserCredential adminCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
        email: "admin@mindfulchat.com",
        password: "Admin123!"
    );

    // Add admin data to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(adminCredential.user!.uid)
        .set({
      'uid': adminCredential.user!.uid,
      'fullName': 'System Administrator',
      'email': 'admin@mindfulchat.com',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Default admin account created:');
    print('Email: admin@mindfulchat.com');
    print('Password: Admin123!');

    // Sign out the admin account so user can log in normally
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    if (e.toString().contains('email-already-in-use')) {
      print('Admin email already registered in Firebase Auth');
    } else {
      print('Error creating admin account: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LogInProvider()),
        ChangeNotifierProvider(create: (_) => CreateAccountProvider()),
      ],
      child: MaterialApp(
        title: 'MindfulChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
