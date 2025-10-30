import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FamilyNotificationService {
  static final FamilyNotificationService _instance = FamilyNotificationService._internal();
  factory FamilyNotificationService() => _instance;
  FamilyNotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<QuerySnapshot>? _highRiskSubscription;
  String? _lastProcessedLogId; // Track last processed log to avoid duplicates

  // Initialize notifications
  Future<void> initialize([BuildContext? context]) async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInitializationSettings = 
      AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings = 
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTap(response, context);
      },
    );

    await _requestPermissions();
    await createNotificationChannels();
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    // For Android 13+, request permission
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // For Android 13+, we need to request permission
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS permissions
    final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Start monitoring for high-risk conditions
  Future<void> startMonitoring() async {
    await stopMonitoring();
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final familyMemberDoc = await FirebaseFirestore.instance
        .collection('family_members')
        .doc(currentUser.uid)
        .get();

    if (familyMemberDoc.exists) {
      final familyMemberData = familyMemberDoc.data();
      final linkedPatientId = familyMemberData?['patientUserId'];
      
      if (linkedPatientId != null && linkedPatientId.isNotEmpty) {
        _highRiskSubscription = FirebaseFirestore.instance
            .collection('symptom_logs')
            .where('patientId', isEqualTo: linkedPatientId)
            .where('riskLevel', isEqualTo: 'High Risk')
            .orderBy('logDate', descending: true)
            .limit(1) // Only get the latest one
            .snapshots()
            .listen((QuerySnapshot snapshot) async {
              if (snapshot.docs.isNotEmpty) {
                final latestDoc = snapshot.docs.first;
                final latestLog = latestDoc.data() as Map<String, dynamic>;
                final logId = latestDoc.id;
                
                // Check if this is a new log to avoid duplicate notifications
                if (logId != _lastProcessedLogId) {
                  _lastProcessedLogId = logId;
                  await _triggerHighRiskNotification(latestLog, linkedPatientId, logId);
                }
              }
            });
      }
    }
  }

  // Stop monitoring for high-risk conditions
  Future<void> stopMonitoring() async {
    await _highRiskSubscription?.cancel();
    _highRiskSubscription = null;
    _lastProcessedLogId = null;
  }

  // Trigger high-risk notification
  Future<void> _triggerHighRiskNotification(
    Map<String, dynamic> log, 
    String patientId,
    String logId,
  ) async {
    final riskMessage = log['riskMessage'] ?? 'High risk condition detected';
    final Timestamp? logDateTimestamp = log['logDate'] as Timestamp?;
    final DateTime logDate = logDateTimestamp?.toDate() ?? DateTime.now();
    
    await showHighRiskNotification(
      title: '🚨 High Risk Alert',
      body: riskMessage,
      payload: {
        'type': 'high_risk',
        'patientId': patientId,
        'logId': logId,
        'timestamp': logDate.millisecondsSinceEpoch.toString(),
      },
    );
  }

  // Show high-risk notification
  Future<void> showHighRiskNotification({
    required String title,
    required String body,
    required Map<String, String> payload,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_risk_channel',
      'High Risk Alerts',
      channelDescription: 'Notifications for high-risk pregnancy conditions',
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFFE91E63),
      enableVibration: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      styleInformation: BigTextStyleInformation(body),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert payload to string properly
    final payloadString = payload.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payloadString,
    );
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response, BuildContext? context) {
    final String? payload = response.payload;
    
    if (payload != null && context != null && context.mounted) {
      // Parse the payload
      final params = Uri.splitQueryString(payload);
      final type = params['type'];
      
      if (type == 'high_risk') {
        Navigator.of(context).pushNamed('/familyViewLog');
      }
    } else if (payload != null) {
      print('Notification tapped with payload: $payload (no context available)');
    }
  }

  // Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time.hour, time.minute);
    
    await _notificationsPlugin.zonedSchedule(
      time.hour * 60 + time.minute, // Unique ID based on time
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily health check reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<bool> isNotificationEnabled() async {
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    
    return result ?? true;
  }

  Future<void> createNotificationChannels() async {
    const AndroidNotificationChannel highRiskChannel = AndroidNotificationChannel(
      'high_risk_channel',
      'High Risk Alerts',
      description: 'Notifications for high-risk pregnancy conditions',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminders',
      description: 'Daily health check reminders',
      importance: Importance.defaultImportance,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highRiskChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
  }

  Future<void> showSimpleNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'simple_channel',
      'Simple Notifications',
      channelDescription: 'Simple notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> testNotification() async {
    await showSimpleNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Safe Mother app',
    );
  }

  // Clean up resources
  void dispose() {
    stopMonitoring();
  }
}