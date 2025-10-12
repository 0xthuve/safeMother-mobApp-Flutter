import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart'; // 👈 Add this for localization support

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/family_home_screen.dart';
import 'services/family_notification_service.dart';
import 'services/session_manager.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/backend_service.dart';
import 'patient_dashboard.dart';
import 'pages/doctor/doctor_dashboard.dart';
import 'signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // For development, continue without Firebase if there's an error
    print('Firebase initialization error: $e');
  }

  // Initialize Firebase service (will use mock if Firebase not configured)
  await FirebaseService.initialize();

  // Initialize NotificationService for local notifications
  await NotificationService().initialize();

  // Initialize notification channels (without context)
  await FamilyNotificationService().createNotificationChannels();
  
  runApp(const SafeMotherApp());
}

class SafeMotherApp extends StatefulWidget {
  const SafeMotherApp({super.key});

  static _SafeMotherAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SafeMotherAppState>();

  @override
  _SafeMotherAppState createState() => _SafeMotherAppState();
}

class _SafeMotherAppState extends State<SafeMotherApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final backendService = BackendService();
      final languageCode = await backendService.getLanguagePreference();
      setState(() {
        _locale = Locale(languageCode);
      });
    } catch (e) {
      // Keep default locale if loading fails
      print('Error loading language preference: $e');
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    // Save the language preference
    _saveLanguagePreference(locale.languageCode);
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      final backendService = BackendService();
      await backendService.saveLanguagePreference(languageCode);
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Safe Mother',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF8F6F8),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF9C27B0),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Add a small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Check Firebase authentication state
      if (FirebaseService.isLoggedIn) {
        final currentUserData = FirebaseService.currentUserData;
        if (currentUserData != null) {
          final uid = currentUserData['uid'] as String?;
          if (uid != null) {
            // Get user data from Firestore
            final userData = await FirebaseService.getUserData(uid);

            if (userData != null) {
              final userRole = userData['role'] as String?;

              // Update session manager with Firebase data
              await SessionManager.saveLoginSession(
                userType: userRole == 'doctor' || userRole == 'healthcare'
                    ? SessionManager.userTypeDoctor
                    : SessionManager.userTypePatient,
                userId: uid,
                userName: userData['fullName'] ??
                    currentUserData['displayName'] as String? ??
                    'User',
                userEmail: currentUserData['email'] as String? ?? '',
              );

              // Navigate to appropriate dashboard
              if (userRole == 'doctor' || userRole == 'healthcare') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DoctorDashboard()),
                );
              } else if (userRole == 'family') {
                // Navigate to family home screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FamilyHomeScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
              return;
            }
          }
        }
      }

      // Fallback to session manager check
      final isSessionValid = await SessionManager.isSessionValid();

      if (isSessionValid) {
        final userType = await SessionManager.getUserType();

        // Refresh session since user is returning
        await SessionManager.refreshSession();

        // Navigate to appropriate dashboard based on user type
        if (userType == SessionManager.userTypePatient) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (userType == SessionManager.userTypeDoctor) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDashboard()),
          );
        } else if (userType == 'family') {
          // Family member route
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FamilyHomeScreen()),
          );
        } else {
          // Invalid user type, go to login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      } else {
        // No valid session, clear any old data and go to login
        await SessionManager.clearSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } catch (e) {
      // Error checking session, go to login
      print('Error checking login status: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTitle = AppLocalizations.of(context)?.appTitle ?? 'Safe Mother';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/logo.png'),
              ),
              const SizedBox(height: 24),
              Text(
                appTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B1FA2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.welcomeMessage ??
                    'Empowering Every Step of Motherhood',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9575CD),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}