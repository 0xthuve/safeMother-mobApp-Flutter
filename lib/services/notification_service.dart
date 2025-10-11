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

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  Future<void> initialize({BuildContext? context}) async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings = InitializationSettings(
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

      print('Notification service initialized with flutter_local_notifications');
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
      print('🚨 HIGH RISK ALERT for patient $patientId');
      print('Risk Level: ${riskLevel.displayName}');
      print('Message: $message');

      final record = NotificationRecord(
        patientId: patientId,
        type: 'health_alert',
        riskLevel: riskLevel.toString(),
        message: message,
        timestamp: DateTime.now(),
        read: false,
      );
      _notifications.add(record);

      // Show local notification on Android
      await _showLocalNotification('High Risk Alert', message);

      print('✅ High risk alert processed for patient: $patientId');
    } catch (e) {
      print('Error sending high risk alert: $e');
    }
  }

  /// Show local notification using flutter_local_notifications
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_risk_channel',
      'High Risk Alerts',
      channelDescription: 'Notifications for high risk events',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'high_risk',
    );
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