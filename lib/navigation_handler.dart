// navigation_handler.dart
import 'package:flutter/material.dart';
import 'reminderPatientDashboard.dart';
import 'chatPatient.dart';
import 'patientDashboard.dart';

class NavigationHandler {
  static void navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        break;
      case 1:
        // Navigate to Log Screen
        // TODO: Add LogScreen navigation here if available
        break;
      case 2:
        // Navigate to Reminders
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const RemindersScreen(),
          ),
        );
        break;
      case 3:
        // Navigate to Learn
        // TODO: Add LearnScreen navigation here if available
        break;
      case 4:
        // Navigate to Chat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
        break;
    }
  }
}