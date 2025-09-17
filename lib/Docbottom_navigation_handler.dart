// navigation_handler.dart
import 'package:flutter/material.dart';
import 'DoctorDashboard.dart';


class NavigationHandler {
  static void navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
        break;

      case 1:
        
        break;

      case 2:
       
        break;

      case 3:
        // Navigate to Appointments
        
        break;
    }
  }
}
