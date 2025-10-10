import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/family_home_screen.dart';
import 'pages/family_log_page.dart';
import 'pages/family_appointment_page.dart';
import 'pages/family_contact_page.dart';
import 'pages/family_learn_page.dart';
import 'pages/family_profile_page.dart';
import 'pages/family_logIn_page.dart';
import 'pages/family_signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF8F6F8),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF9C27B0),
        ),
      ),
      initialRoute: '/',
      routes: {
  '/': (context) => const FamilyLoginScreen(),
  '/familyHome': (context) => const FamilyHomeScreen(),
  '/familyViewLog': (context) => const FamilyViewLogScreen(),
  '/familyAppointments': (context) => const FamilyAppointmentsScreen(),
  '/familyContacts': (context) => const FamilyContactsScreen(),
  '/familyLearn': (context) => const FamilyLearnScreen(),
  '/familyProfile': (context) => const FamilyProfileScreen(),
  '/signup': (context) => const FamilySignUpScreen(),
},
    );
  }
}