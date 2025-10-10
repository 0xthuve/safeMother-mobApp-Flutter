import 'package:flutter/material.dart';
import '../pages/doctor/doctor_dashboard.dart';
import '../pages/doctor/doctor_patient_management.dart';
import '../pages/doctor/doctor_appointments.dart';
import '../pages/doctor/doctor_profile.dart';

class DoctorNavigationHandler {
  static void navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to Doctor Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorDashboard(),
          ),
        );
        break;
      case 1:
        // Navigate to Patient Management
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorPatientManagement(),
          ),
        );
        break;
      case 2:
        // Navigate to Appointments
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorAppointments(),
          ),
        );
        break;
      case 3:
        // Navigate to Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorProfile(),
          ),
        );
        break;
    }
  }

  static void navigateToPatientManagement(BuildContext context, {int initialTab = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorPatientManagement(initialTabIndex: initialTab),
      ),
    );
  }
}

