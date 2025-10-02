import '../services/backend_service.dart';
import '../services/appointment_service.dart';
import '../services/session_manager.dart';

class DemoDataInitializer {
  static bool _isInitialized = false;

  /// Initialize all demo data for the app
  static Future<bool> initializeAllDemoData() async {
    if (_isInitialized) return true;

    try {
      // Initialize demo user session if not logged in
      final isLoggedIn = await SessionManager.isLoggedIn();
      if (!isLoggedIn) {
        await _initializeDemoUserSession();
      }

      // Initialize backend services with demo data
      final backendService = BackendService();
      await backendService.initializeDemoData();

      // Initialize appointment service with demo data
      final appointmentService = AppointmentService();
      await appointmentService.initializeDemoAppointments();

      _isInitialized = true;
      print('Demo data initialization completed successfully');
      return true;
    } catch (e) {
      print('Error initializing demo data: $e');
      return false;
    }
  }

  /// Initialize demo user session
  static Future<void> _initializeDemoUserSession() async {
    await SessionManager.saveLoginSession(
      userType: SessionManager.userTypePatient,
      userId: '1',
      userName: 'Sarah Johnson',
      userEmail: 'sarah.johnson@email.com',
    );
  }

  /// Reset all demo data (useful for testing)
  static Future<bool> resetAllDemoData() async {
    try {
      // Clear session
      await SessionManager.clearSession();
      
      // Re-initialize everything
      _isInitialized = false;
      return await initializeAllDemoData();
    } catch (e) {
      print('Error resetting demo data: $e');
      return false;
    }
  }

  /// Check if demo data is initialized
  static bool get isInitialized => _isInitialized;

  /// Force re-initialization on next call
  static void markForReinitialization() {
    _isInitialized = false;
  }
}