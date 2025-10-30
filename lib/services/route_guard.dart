import 'package:flutter/material.dart';
import 'user_management_service.dart';
import 'session_manager.dart';
import '../signin.dart';

class RouteGuard {
  /// Check if user has permission to access patient dashboard
  static Future<bool> canAccessPatientDashboard() async {
    try {
      final isAuthenticated = await UserManagementService.isAuthenticated();
      if (!isAuthenticated) return false;

      final userRole = await UserManagementService.getUserRole();
      // Only patients and mothers can access patient dashboard
      return userRole == 'patient' || userRole == 'mother' || userRole == null;
    } catch (e) {

      return false;
    }
  }

  /// Check if user has permission to access doctor dashboard
  static Future<bool> canAccessDoctorDashboard() async {
    try {
      final isAuthenticated = await UserManagementService.isAuthenticated();
      if (!isAuthenticated) return false;

      final userRole = await UserManagementService.getUserRole();
      // Only doctors and healthcare professionals can access doctor dashboard
      return userRole == 'doctor' || userRole == 'healthcare';
    } catch (e) {

      return false;
    }
  }

  /// Redirect to appropriate login if user doesn't have access
  static Future<void> redirectToLogin(BuildContext context, {String? message}) async {
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Clear session and redirect to login
    await SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  /// Wrapper widget to protect patient routes
  static Widget patientRouteGuard({
    required Widget child,
    required BuildContext context,
  }) {
    return FutureBuilder<bool>(
      future: canAccessPatientDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return child;
        } else {
          // Redirect to login with message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            redirectToLogin(
              context,
              message: 'Access denied. Please log in with a patient account.',
            );
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            ),
          );
        }
      },
    );
  }

  /// Wrapper widget to protect doctor routes
  static Widget doctorRouteGuard({
    required Widget child,
    required BuildContext context,
  }) {
    return FutureBuilder<bool>(
      future: canAccessDoctorDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return child;
        } else {
          // Redirect to login with message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            redirectToLogin(
              context,
              message: 'Access denied. Please log in with a healthcare professional account.',
            );
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            ),
          );
        }
      },
    );
  }
}
