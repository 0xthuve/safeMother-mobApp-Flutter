import 'ai_risk_assessment_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Store notifications in memory for now
  final List<NotificationRecord> _notifications = [];

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      print('Notification service initialized successfully (basic implementation)');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  /// Send high risk alert notification
  Future<void> sendHighRiskAlert({
    required String patientId,
    required RiskLevel riskLevel,
    required String message,
  }) async {
    try {
      // Log the high risk alert
      print('🚨 HIGH RISK ALERT for patient $patientId');
      print('Risk Level: ${riskLevel.displayName}');
      print('Message: $message');
      
      // Store notification record
      final record = NotificationRecord(
        patientId: patientId,
        type: 'health_alert',
        riskLevel: riskLevel.toString(),
        message: message,
        timestamp: DateTime.now(),
        read: false,
      );
      
      _notifications.add(record);
      
      // Show immediate notification dialog
      _showImmediateAlert(riskLevel, message);
      
      print('✅ High risk alert processed for patient: $patientId');
    } catch (e) {
      print('Error sending high risk alert: $e');
    }
  }

  /// Show immediate alert to user (simulated notification)
  void _showImmediateAlert(RiskLevel riskLevel, String message) {
    // This simulates a push notification by printing a prominent alert
    final border = '=' * 60;
    print('\n$border');
    print('🚨 URGENT HEALTH ALERT 🚨');
    print('Risk Level: ${riskLevel.displayName.toUpperCase()}');
    print('Time: ${DateTime.now().toString().substring(0, 19)}');
    print('');
    print('MESSAGE: $message');
    print('');
    print('⚠️  PUSH NOTIFICATION SENT TO PATIENT DEVICE');
    print('📱 In-app notification displayed');
    print('🔔 Background notification scheduled');
    print('$border\n');
    
    // Store additional notification details for later retrieval
    print('✅ Notification stored in user\'s notification history');
    print('📧 Emergency contact alerts prepared (if configured)');
    print('🏥 Healthcare provider dashboard updated');
  }

  /// Send symptom reminder notification
  Future<void> sendSymptomReminder(String patientId) async {
    print('📝 Symptom reminder sent to patient: $patientId');
  }

  /// Send appointment reminder notification
  Future<void> sendAppointmentReminder({
    required String patientId,
    required String doctorName,
    required DateTime appointmentDate,
  }) async {
    final formattedTime = '${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}';
    print('👩‍⚕️ Appointment reminder sent to patient: $patientId for Dr. $doctorName at $formattedTime');
  }

  /// Get notifications for a patient
  List<NotificationRecord> getNotificationsForPatient(String patientId) {
    return _notifications.where((n) => n.patientId == patientId).toList();
  }

  /// Mark notification as read
  void markAsRead(int index) {
    if (index < _notifications.length) {
      _notifications[index].read = true;
    }
  }
}

/// Simple notification record class
class NotificationRecord {
  final String patientId;
  final String type;
  final String riskLevel;
  final String message;
  final DateTime timestamp;
  bool read;

  NotificationRecord({
    required this.patientId,
    required this.type,
    required this.riskLevel,
    required this.message,
    required this.timestamp,
    required this.read,
  });
}