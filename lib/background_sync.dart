import 'services/backend_service.dart';
import 'services/notification_service.dart';
import 'services/ai_risk_assessment_service.dart';

/// Utility class for background sync operations
class BackgroundSync {
  static final BackendService _backendService = BackendService();

  /// Sync patient data
  static Future<void> syncPatientData(String userId) async {
    await _backendService.getPregnancyTracking(userId);
    await _backendService.getMedicalRecords(userId);
    await _backendService.getUpcomingAppointments(userId);
    await _backendService.getDueReminders(userId);
  }

  /// Sync doctor data and send notifications for new alerts
  static Future<void> syncDoctorData(String doctorId) async {
    final alerts = await _backendService.getDoctorAlerts(doctorId);
    for (final alert in alerts) {
      if (!alert.isRead) {
        await NotificationService().sendHighRiskAlert(
          patientId: alert.patientId,
          riskLevel: _parseRiskLevel(alert.riskLevel),
          message: 'Patient ${alert.patientName} is at ${alert.riskLevel} risk: ${alert.riskMessage}',
        );
      }
    }
    await _backendService.getAcceptedPatientsForDoctor(doctorId);
    await _backendService.getPatientRequestsForDoctor(doctorId);
  }

  static RiskLevel _parseRiskLevel(String riskLevel) {
    final normalized = riskLevel.toLowerCase().replaceAll(' risk', '');
    switch (normalized) {
      case 'high':
        return RiskLevel.high;
      case 'moderate':
        return RiskLevel.moderate;
      default:
        return RiskLevel.low;
    }
  }
}
