import 'package:flutter/material.dart';
import '../pages/doctor/doctor_dashboard.dart';
import '../pages/doctor/doctor_patients.dart';
import '../pages/doctor/doctor_appointments.dart';
import '../pages/doctor/doctor_profile.dart';
import '../pages/doctor/doctor_settings.dart';

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
        // Navigate to Patients
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorPatients(),
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
      case 4:
        // Navigate to Settings
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorSettings(),
          ),
        );
        break;
    }
  }
}

