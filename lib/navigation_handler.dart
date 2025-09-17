// navigation_handler.dart
import 'package:flutter/material.dart';
class NavigationHandler {
  static void navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/log');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/reminders');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/learn');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/chat');
        break;
    }
  }
}