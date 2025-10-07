// navigation_handler.dart
import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'patient_dashboard_log.dart';
import 'reminder_patient_dashboard.dart';
import 'patient_dashboard_tip.dart';
import 'chat_patient.dart';

class NavigationHandler {
  static void navigateToScreen(BuildContext context, int index) {
    Widget targetScreen;
    
    switch (index) {
      case 0:
        targetScreen = const HomeScreen();
        break;
      case 1:
        targetScreen = PatientDashboardLog();
        break;
      case 2:
        targetScreen = const RemindersScreen();
        break;
      case 3:
        targetScreen = const LearnScreen();
        break;
      case 4:
        targetScreen = const ChatScreen();
        break;
      default:
        targetScreen = const HomeScreen();
    }
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
