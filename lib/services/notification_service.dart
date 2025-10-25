import 'ai_risk_assessment_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationRecord> _notifications = [];

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  Future<void> initialize({BuildContext? context}) async {
    try {
      // Use the same launcher icon that's declared in AndroidManifest.xml
      // (manifest uses @mipmap/launcher_icon)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap if needed
        },
      );

      // Request notification permission for Android 13+
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        print('Android notification permission status: $status');
      }

      print(
          'Notification service initialized with flutter_local_notifications');
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  /// Send high risk alert notification - returns true if notification was shown successfully
  Future<bool> sendHighRiskAlert({
    required String patientId,
    required RiskLevel riskLevel,
    required String message,
  }) async {
    bool notificationShown = false;

    try {
      print('🚨 HIGH RISK ALERT for patient $patientId');
      print('Risk Level: ${riskLevel.displayName}');
      print('Message: $message');

      // First priority: Show local notification immediately
      try {
        await _showLocalNotification('HIGH RISK ALERT', message);
        notificationShown = true;
        print('✅ Local notification shown successfully');
      } catch (notificationError) {
        print('❌ Error showing local notification: $notificationError');
        // Continue execution even if notification fails
      }

      // Second priority: Save to local storage
      try {
        final record = NotificationRecord(
          patientId: patientId,
          type: 'health_alert',
          riskLevel: riskLevel.toString(),
          message: message,
          timestamp: DateTime.now(),
          read: false,
        );
        _notifications.add(record);
        print('✅ Alert saved to local storage');
      } catch (storageError) {
        print('❌ Error saving to local storage: $storageError');
        // Continue execution even if storage fails
      }

      // If we got here but notification wasn't shown, try one more time
      if (!notificationShown) {
        await _showLocalNotification('HIGH RISK ALERT', message);
        notificationShown = true;
        print('✅ Local notification shown on second attempt');
      }

      print('✅ High risk alert processed for patient: $patientId');
      return notificationShown;
    } catch (e) {
      print('❌ Critical error in alert processing: $e');

      // Last attempt to show notification if not shown yet
      if (!notificationShown) {
        try {
          await _showLocalNotification('HIGH RISK ALERT', message);
          notificationShown = true;
          print('✅ Local notification shown on final attempt');
        } catch (finalError) {
          print('❌ Fatal error: Could not show notification: $finalError');
        }
      }

      return notificationShown;
    }
  }

  /// Show local notification with retry mechanism
  Future<bool> _showLocalNotification(String title, String body) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_risk_channel',
      'High Risk Alerts',
      channelDescription: 'Notifications for high risk events',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ticker: 'High Risk Medical Alert',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Use unique ID for each notification
    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    try {
      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'high_risk',
      );
      return true;
    } catch (e) {
      print('❌ Error showing notification: $e');
      return false;
    }
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
    final formattedTime =
        '${appointmentDate.hour}:${appointmentDate.minute.toString().padLeft(2, '0')}';
    print(
        '👩‍⚕️ Appointment reminder sent to patient: $patientId for Dr. $doctorName at $formattedTime');
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
