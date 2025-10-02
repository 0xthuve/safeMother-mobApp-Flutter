import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pregnancy_tracking.dart';
import '../models/medical_record.dart';
import '../models/reminder.dart';
import '../models/appointment.dart';
import 'session_manager.dart';

class BackendService {
  static const String pregnancyTrackingKey = 'pregnancy_tracking';
  static const String medicalRecordsKey = 'medical_records';
  static const String remindersKey = 'reminders';
  static const String appointmentsKey = 'appointments';
  static const String doctorsKey = 'doctors';
  static const String patientsKey = 'patients';

  // Singleton pattern
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  // ========== PREGNANCY TRACKING OPERATIONS ==========

  Future<PregnancyTracking?> getPregnancyTracking(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final trackingData = prefs.getString('${pregnancyTrackingKey}_$userId');
    
    if (trackingData == null) return null;
    
    final Map<String, dynamic> json = jsonDecode(trackingData);
    return PregnancyTracking.fromMap(json);
  }

  Future<bool> savePregnancyTracking(PregnancyTracking tracking) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackingData = jsonEncode(tracking.toMap());
      await prefs.setString('${pregnancyTrackingKey}_${tracking.userId}', trackingData);
      return true;
    } catch (e) {
      print('Error saving pregnancy tracking: $e');
      return false;
    }
  }

  Future<bool> updatePregnancyTracking(String userId, Map<String, dynamic> updates) async {
    try {
      final currentTracking = await getPregnancyTracking(userId);
      if (currentTracking == null) return false;

      final updatedTracking = PregnancyTracking.fromMap({
        ...currentTracking.toMap(),
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return await savePregnancyTracking(updatedTracking);
    } catch (e) {
      print('Error updating pregnancy tracking: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> calculatePregnancyProgress(String userId) async {
    final tracking = await getPregnancyTracking(userId);
    if (tracking == null) {
      return {
        'weeks': 0,
        'days': 0,
        'percentage': 0.0,
        'trimester': 'First',
        'weeksRemaining': 40,
      };
    }

    int currentWeek = tracking.currentWeek ?? 0;
    int currentDay = tracking.currentDay ?? 0;

    // Auto-calculate if we have LMP or confirmed date
    if (tracking.lastMenstrualPeriod != null || tracking.pregnancyConfirmedDate != null) {
      final referenceDate = tracking.lastMenstrualPeriod ?? tracking.pregnancyConfirmedDate!;
      final calculated = PregnancyTracking.calculatePregnancyWeek(referenceDate);
      currentWeek = calculated['weeks']!;
      currentDay = calculated['days']!;

      // Update tracking with calculated values
      await updatePregnancyTracking(userId, {
        'currentWeek': currentWeek,
        'currentDay': currentDay,
        'trimester': PregnancyTracking.getTrimester(currentWeek),
      });
    }

    // Calculate remaining days more precisely
    final totalPregnancyDays = 280; // 40 weeks * 7 days
    final currentTotalDays = (currentWeek * 7) + currentDay;
    final remainingDays = (totalPregnancyDays - currentTotalDays).clamp(0, totalPregnancyDays);
    
    return {
      'weeks': currentWeek,
      'days': currentDay,
      'percentage': (currentWeek / 40.0 * 100).clamp(0.0, 100.0),
      'trimester': PregnancyTracking.getTrimester(currentWeek),
      'weeksRemaining': (40 - currentWeek).clamp(0, 40),
      'daysRemaining': remainingDays,
      'totalDays': currentTotalDays,
      'babyName': tracking.babyName ?? 'Your Baby',
      'expectedDeliveryDate': tracking.expectedDeliveryDate?.toIso8601String(),
    };
  }

  // ========== MEDICAL RECORDS OPERATIONS ==========

  Future<List<MedicalRecord>> getMedicalRecords(String userId, {String? recordType}) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsData = prefs.getString('${medicalRecordsKey}_$userId');
    
    if (recordsData == null) return [];
    
    final List<dynamic> json = jsonDecode(recordsData);
    final records = json.map((r) => MedicalRecord.fromMap(r)).toList();
    
    if (recordType != null) {
      return records.where((r) => r.recordType == recordType).toList();
    }
    
    return records..sort((a, b) => b.recordDate.compareTo(a.recordDate));
  }

  Future<bool> saveMedicalRecord(MedicalRecord record) async {
    try {
      final records = await getMedicalRecords(record.userId);
      
      // Generate new ID if not provided
      final newRecord = record.id == null 
          ? record.copyWith(
              id: records.isEmpty ? 1 : records.map((r) => r.id!).reduce((a, b) => a > b ? a : b) + 1,
            )
          : record;
      
      records.add(newRecord);
      
      final prefs = await SharedPreferences.getInstance();
      final recordsData = jsonEncode(records.map((r) => r.toMap()).toList());
      await prefs.setString('${medicalRecordsKey}_${record.userId}', recordsData);
      return true;
    } catch (e) {
      print('Error saving medical record: $e');
      return false;
    }
  }

  Future<bool> updateMedicalRecord(MedicalRecord record) async {
    try {
      final records = await getMedicalRecords(record.userId);
      final index = records.indexWhere((r) => r.id == record.id);
      
      if (index == -1) return false;
      
      records[index] = record.copyWith(updatedAt: DateTime.now());
      
      final prefs = await SharedPreferences.getInstance();
      final recordsData = jsonEncode(records.map((r) => r.toMap()).toList());
      await prefs.setString('${medicalRecordsKey}_${record.userId}', recordsData);
      return true;
    } catch (e) {
      print('Error updating medical record: $e');
      return false;
    }
  }

  Future<bool> deleteMedicalRecord(String userId, int recordId) async {
    try {
      final records = await getMedicalRecords(userId);
      records.removeWhere((r) => r.id == recordId);
      
      final prefs = await SharedPreferences.getInstance();
      final recordsData = jsonEncode(records.map((r) => r.toMap()).toList());
      await prefs.setString('${medicalRecordsKey}_$userId', recordsData);
      return true;
    } catch (e) {
      print('Error deleting medical record: $e');
      return false;
    }
  }

  // ========== REMINDERS OPERATIONS ==========

  Future<List<Reminder>> getReminders(String userId, {bool activeOnly = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersData = prefs.getString('${remindersKey}_$userId');
    
    if (remindersData == null) return [];
    
    final List<dynamic> json = jsonDecode(remindersData);
    final reminders = json.map((r) => Reminder.fromMap(r)).toList();
    
    if (activeOnly) {
      return reminders.where((r) => r.isActive && !r.isCompleted).toList()
        ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
    }
    
    return reminders..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Reminder>> getDueReminders(String userId) async {
    final reminders = await getReminders(userId);
    final now = DateTime.now();
    
    return reminders.where((r) => 
      r.isActive && 
      !r.isCompleted && 
      (r.reminderDate.isBefore(now) || r.reminderDate.isAtSameMomentAs(now))
    ).toList();
  }

  Future<bool> saveReminder(Reminder reminder) async {
    try {
      final reminders = await getReminders(reminder.userId, activeOnly: false);
      
      // Generate new ID if not provided
      final newReminder = reminder.id == null 
          ? reminder.copyWith(
              id: reminders.isEmpty ? 1 : reminders.map((r) => r.id!).reduce((a, b) => a > b ? a : b) + 1,
            )
          : reminder;
      
      reminders.add(newReminder);
      
      final prefs = await SharedPreferences.getInstance();
      final remindersData = jsonEncode(reminders.map((r) => r.toMap()).toList());
      await prefs.setString('${remindersKey}_${reminder.userId}', remindersData);
      return true;
    } catch (e) {
      print('Error saving reminder: $e');
      return false;
    }
  }

  Future<bool> updateReminder(Reminder reminder) async {
    try {
      final reminders = await getReminders(reminder.userId, activeOnly: false);
      final index = reminders.indexWhere((r) => r.id == reminder.id);
      
      if (index == -1) return false;
      
      reminders[index] = reminder.copyWith(updatedAt: DateTime.now());
      
      final prefs = await SharedPreferences.getInstance();
      final remindersData = jsonEncode(reminders.map((r) => r.toMap()).toList());
      await prefs.setString('${remindersKey}_${reminder.userId}', remindersData);
      return true;
    } catch (e) {
      print('Error updating reminder: $e');
      return false;
    }
  }

  Future<bool> completeReminder(String userId, int reminderId) async {
    try {
      final reminders = await getReminders(userId, activeOnly: false);
      final index = reminders.indexWhere((r) => r.id == reminderId);
      
      if (index == -1) return false;
      
      final reminder = reminders[index];
      reminders[index] = reminder.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Create next recurring reminder if applicable
      final nextDate = reminder.getNextReminderDate();
      if (nextDate != null) {
        final nextReminder = reminder.copyWith(
          id: null, // Will get new ID when saved
          reminderDate: nextDate,
          isCompleted: false,
          completedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        reminders.add(nextReminder);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final remindersData = jsonEncode(reminders.map((r) => r.toMap()).toList());
      await prefs.setString('${remindersKey}_$userId', remindersData);
      return true;
    } catch (e) {
      print('Error completing reminder: $e');
      return false;
    }
  }

  // ========== APPOINTMENTS OPERATIONS ==========

  Future<List<Appointment>> getAppointments({String? userId, String? doctorId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = userId != null ? '${appointmentsKey}_user_$userId' : '${appointmentsKey}_doctor_$doctorId';
    final appointmentsData = prefs.getString(key);
    
    List<Appointment> appointments = [];
    
    if (appointmentsData != null) {
      final List<dynamic> json = jsonDecode(appointmentsData);
      appointments = json.map((a) => Appointment.fromMap(a)).toList();
    }
    
    return appointments..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    final appointments = await getAppointments(userId: userId);
    final now = DateTime.now();
    
    return appointments.where((a) => 
      a.appointmentDate.isAfter(now) && 
      a.status != 'cancelled'
    ).toList();
  }

  Future<bool> saveAppointment(Appointment appointment) async {
    try {
      // Save for both user and doctor
      await _saveAppointmentForUser(appointment);
      await _saveAppointmentForDoctor(appointment);
      return true;
    } catch (e) {
      print('Error saving appointment: $e');
      return false;
    }
  }

  Future<void> _saveAppointmentForUser(Appointment appointment) async {
    final appointments = await getAppointments(userId: appointment.patientId.toString());
    
    final newAppointment = appointment.id == null 
        ? appointment.copyWith(
            id: appointments.isEmpty ? 1 : appointments.map((a) => a.id!).reduce((a, b) => a > b ? a : b) + 1,
          )
        : appointment;
    
    appointments.add(newAppointment);
    
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = jsonEncode(appointments.map((a) => a.toMap()).toList());
    await prefs.setString('${appointmentsKey}_user_${appointment.patientId}', appointmentsData);
  }

  Future<void> _saveAppointmentForDoctor(Appointment appointment) async {
    final appointments = await getAppointments(doctorId: appointment.doctorId.toString());
    
    final newAppointment = appointment.id == null 
        ? appointment.copyWith(
            id: appointments.isEmpty ? 1 : appointments.map((a) => a.id!).reduce((a, b) => a > b ? a : b) + 1,
          )
        : appointment;
    
    appointments.add(newAppointment);
    
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = jsonEncode(appointments.map((a) => a.toMap()).toList());
    await prefs.setString('${appointmentsKey}_doctor_${appointment.doctorId}', appointmentsData);
  }

  Future<bool> updateAppointmentStatus(int appointmentId, String status, {String? notes}) async {
    try {
      // This is a simplified version - in a real app, you'd need to update both user and doctor records
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(appointmentsKey));
      
      for (final key in keys) {
        final appointmentsData = prefs.getString(key);
        if (appointmentsData != null) {
          final List<dynamic> json = jsonDecode(appointmentsData);
          final appointments = json.map((a) => Appointment.fromMap(a)).toList();
          
          final index = appointments.indexWhere((a) => a.id == appointmentId);
          if (index != -1) {
            appointments[index] = appointments[index].copyWith(
              status: status,
              notes: notes ?? appointments[index].notes,
              updatedAt: DateTime.now(),
            );
            
            final updatedData = jsonEncode(appointments.map((a) => a.toMap()).toList());
            await prefs.setString(key, updatedData);
          }
        }
      }
      return true;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  // ========== INITIALIZATION & DEMO DATA ==========

  Future<void> initializeDemoData() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    // Initialize pregnancy tracking if not exists
    final existingTracking = await getPregnancyTracking(userId);
    if (existingTracking == null) {
      final demoTracking = PregnancyTracking(
        userId: userId,
        lastMenstrualPeriod: DateTime.now().subtract(const Duration(days: 140)), // ~20 weeks
        pregnancyConfirmedDate: DateTime.now().subtract(const Duration(days: 120)),
        currentWeek: 20,
        currentDay: 0,
        trimester: 'Second',
        weight: 65.0,
        height: 165.0,
        babyName: 'Baby',
        isFirstChild: true,
        hasPregnancyLoss: false,
        symptoms: ['Morning sickness', 'Fatigue'],
        medications: ['Prenatal vitamins', 'Folic acid'],
        vitals: {
          'bloodPressure': '120/80',
          'heartRate': 75,
          'weight': 65.0,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await savePregnancyTracking(demoTracking);
    }

    // Initialize demo reminders
    final existingReminders = await getReminders(userId, activeOnly: false);
    if (existingReminders.isEmpty) {
      final demoReminders = [
        Reminder(
          userId: userId,
          title: 'Take Prenatal Vitamins',
          description: 'Take your daily prenatal vitamins with breakfast',
          type: 'medication',
          reminderDate: DateTime.now().add(const Duration(hours: 2)),
          recurrenceType: 'daily',
          recurrenceInterval: 1,
          metadata: {'dosage': '1 tablet', 'withFood': true},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Reminder(
          userId: userId,
          title: 'Doctor Appointment',
          description: 'Monthly prenatal checkup with Dr. Johnson',
          type: 'appointment',
          reminderDate: DateTime.now().add(const Duration(days: 7)),
          metadata: {'doctorName': 'Dr. Johnson', 'location': 'City General Hospital'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Reminder(
          userId: userId,
          title: 'Exercise Time',
          description: '30 minutes of light prenatal exercise',
          type: 'exercise',
          reminderDate: DateTime.now().add(const Duration(days: 1)),
          recurrenceType: 'daily',
          recurrenceInterval: 2,
          metadata: {'duration': '30 minutes', 'type': 'light'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final reminder in demoReminders) {
        await saveReminder(reminder);
      }
    }

    // Initialize demo medical records
    final existingRecords = await getMedicalRecords(userId);
    if (existingRecords.isEmpty) {
      final demoRecords = [
        MedicalRecord(
          userId: userId,
          doctorId: '1',
          recordType: 'checkup',
          title: '20 Week Ultrasound',
          description: 'Anatomy scan showing healthy development',
          data: {
            'weight': 65.0,
            'bloodPressure': '120/80',
            'heartRate': 75,
            'babyWeight': '300g',
            'babyLength': '16.4cm',
          },
          recordDate: DateTime.now().subtract(const Duration(days: 3)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        MedicalRecord(
          userId: userId,
          doctorId: '1',
          recordType: 'lab_result',
          title: 'Blood Work Results',
          description: 'Complete blood count and glucose screening',
          data: {
            'hemoglobin': '12.5 g/dL',
            'glucose': '95 mg/dL',
            'iron': 'Normal',
            'status': 'All values within normal range',
          },
          recordDate: DateTime.now().subtract(const Duration(days: 10)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final record in demoRecords) {
        await saveMedicalRecord(record);
      }
    }
  }

  // ========== UTILITY METHODS ==========

  Future<Map<String, dynamic>> getDashboardSummary(String userId) async {
    final pregnancyProgress = await calculatePregnancyProgress(userId);
    final upcomingAppointments = await getUpcomingAppointments(userId);
    final dueReminders = await getDueReminders(userId);
    final recentRecords = await getMedicalRecords(userId);

    return {
      'pregnancyProgress': pregnancyProgress,
      'upcomingAppointments': upcomingAppointments.take(3).map((a) => {
        'id': a.id,
        'date': a.appointmentDate.toIso8601String(),
        'timeSlot': a.timeSlot,
        'reason': a.reason,
        'doctorId': a.doctorId,
      }).toList(),
      'dueReminders': dueReminders.take(5).map((r) => {
        'id': r.id,
        'title': r.title,
        'type': r.type,
        'reminderDate': r.reminderDate.toIso8601String(),
      }).toList(),
      'recentRecords': recentRecords.take(3).map((r) => {
        'id': r.id,
        'title': r.title,
        'type': r.recordType,
        'recordDate': r.recordDate.toIso8601String(),
      }).toList(),
    };
  }

  Future<void> clearAllData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${pregnancyTrackingKey}_$userId');
    await prefs.remove('${medicalRecordsKey}_$userId');
    await prefs.remove('${remindersKey}_$userId');
    await prefs.remove('${appointmentsKey}_user_$userId');
  }
}