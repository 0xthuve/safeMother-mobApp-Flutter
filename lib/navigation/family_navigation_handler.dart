import 'package:flutter/material.dart';

class FamilyNavigationHandler {
  static void navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/familyHome');
        break;
      case 1: // View Log
        Navigator.pushReplacementNamed(context, '/familyViewLog');
        break;
      case 2: // Appointments
        Navigator.pushReplacementNamed(context, '/familyAppointments');
        break;
      case 3: // Contacts
        Navigator.pushReplacementNamed(context, '/familyContacts');
        break;
      case 4: // Learn
        Navigator.pushReplacementNamed(context, '/familyLearn');
        break;
    }
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/familyProfile');
  }

  static int getCurrentIndex(String routeName) {
    switch (routeName) {
      case '/familyHome':
        return 0;
      case '/familyViewLog':
        return 1;
      case '/familyAppointments':
        return 2;
      case '/familyContacts':
        return 3;
      case '/familyLearn':
        return 4;
      case '/familyProfile':
        return -1; // Profile is not in bottom nav
      default:
        return 0;
    }
  }
}