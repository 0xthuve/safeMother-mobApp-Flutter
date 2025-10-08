import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pregnancy_tracking.dart';
import '../models/medical_record.dart';
import '../models/reminder.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient_doctor_link.dart';
import '../models/symptom_log.dart';
import 'session_manager.dart';
import 'tips_service.dart';
import 'firebase_service.dart';

class BackendService {
  static const String pregnancyTrackingKey = 'pregnancy_tracking';
  static const String medicalRecordsKey = 'medical_records';
  static const String remindersKey = 'reminders';
  static const String appointmentsKey = 'appointments';
  static const String doctorsKey = 'doctors';
  static const String patientsKey = 'patients';
  static const String symptomLogsKey = 'symptom_logs';

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
        'daysRemaining': 280,
        'totalDays': 0,
        'babyName': 'Your Baby',
        'expectedDeliveryDate': null,
        'confirmationDate': null,
        'isOverdue': false,
        'trimesterProgress': 0.0,
      };
    }

    int currentWeek = tracking.currentWeek ?? 0;
    int currentDay = tracking.currentDay ?? 0;
    DateTime? calculationBaseDate;

    // Auto-calculate if we have LMP or confirmed date
    if (tracking.lastMenstrualPeriod != null || tracking.pregnancyConfirmedDate != null) {
      DateTime? expectedDeliveryDate = tracking.expectedDeliveryDate;
      
      if (tracking.lastMenstrualPeriod != null) {
        // Use LMP for most accurate calculation
        calculationBaseDate = tracking.lastMenstrualPeriod!;
        final calculated = PregnancyTracking.calculatePregnancyWeek(calculationBaseDate);
        currentWeek = calculated['weeks']!;
        currentDay = calculated['days']!;
        
        // Auto-calculate expected delivery date if not set (280 days from LMP)
        if (expectedDeliveryDate == null) {
          expectedDeliveryDate = PregnancyTracking.calculateExpectedDeliveryDate(tracking.lastMenstrualPeriod);
        }
      } else if (tracking.pregnancyConfirmedDate != null) {
        // Use confirmation date as the start of pregnancy journey (day 0)
        calculationBaseDate = tracking.pregnancyConfirmedDate!;
        final daysSinceConfirmation = DateTime.now().difference(calculationBaseDate).inDays;
        currentWeek = (daysSinceConfirmation / 7).floor().clamp(0, 45);
        currentDay = (daysSinceConfirmation % 7).clamp(0, 6);
        
        // Ensure no negative values
        if (daysSinceConfirmation < 0) {
          currentWeek = 0;
          currentDay = 0;
        }
        
        // Auto-calculate expected delivery date if not set (280 days from confirmation)
        if (expectedDeliveryDate == null) {
          expectedDeliveryDate = calculationBaseDate.add(const Duration(days: 280));
        }
      }

      // Update tracking with calculated values
      await updatePregnancyTracking(userId, {
        'currentWeek': currentWeek,
        'currentDay': currentDay,
        'trimester': PregnancyTracking.getTrimester(currentWeek),
        'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      });
    }

    // Calculate remaining days more precisely
    final totalPregnancyDays = 280; // 40 weeks * 7 days
    final currentTotalDays = (currentWeek * 7) + currentDay;
    final remainingDays = (totalPregnancyDays - currentTotalDays).clamp(0, totalPregnancyDays);
    
    // Calculate trimester progress
    final trimester = PregnancyTracking.getTrimester(currentWeek);
    double trimesterProgress = 0.0;
    if (trimester == 'First') {
      trimesterProgress = (currentWeek / 12.0 * 100).clamp(0.0, 100.0);
    } else if (trimester == 'Second') {
      trimesterProgress = ((currentWeek - 12) / 16.0 * 100).clamp(0.0, 100.0);
    } else if (trimester == 'Third') {
      trimesterProgress = ((currentWeek - 28) / 12.0 * 100).clamp(0.0, 100.0);
    }

    // Check if overdue (past 40 weeks)
    final isOverdue = currentWeek > 40;

    // Get expected delivery date
    final expectedDeliveryDate = tracking.expectedDeliveryDate;

    return {
      'weeks': currentWeek,
      'days': currentDay,
      'percentage': (currentWeek / 40.0 * 100).clamp(0.0, 100.0),
      'trimester': trimester,
      'trimesterProgress': trimesterProgress,
      'weeksRemaining': (40 - currentWeek).clamp(0, 40),
      'daysRemaining': remainingDays,
      'totalDays': currentTotalDays,
      'babyName': tracking.babyName ?? 'Your Baby',
      'babyGender': tracking.babyGender,
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'confirmationDate': tracking.pregnancyConfirmedDate?.toIso8601String(),
      'lastMenstrualPeriod': tracking.lastMenstrualPeriod?.toIso8601String(),
      'isOverdue': isOverdue,
      'weight': tracking.weight,
      'height': tracking.height,
      'isFirstChild': tracking.isFirstChild,
      'medicalHistory': tracking.medicalHistory,
      'symptoms': tracking.symptoms,
      'medications': tracking.medications,
      'vitals': tracking.vitals,
      'calculationBaseDate': calculationBaseDate?.toIso8601String(),
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

      return false;
    }
  }

  Future<void> _saveAppointmentForUser(Appointment appointment) async {
    final appointments = await getAppointments(userId: appointment.patientId.toString());
    
    final newAppointment = appointment.id == null 
        ? appointment.copyWith(
            id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
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
            id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
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

      return false;
    }
  }

  // ========== INITIALIZATION & DEMO DATA ==========

  Future<void> initializeDemoData() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    // Initialize tips service (will create default tips if none exist)
    final tipsService = TipsService();
    await tipsService.getTodaysTip(); // This will trigger initialization if needed

    // Initialize pregnancy tracking if not exists
    final existingTracking = await getPregnancyTracking(userId);
    if (existingTracking == null) {
      // Use confirmation date approach (more realistic for new users)
      final confirmationDate = DateTime.now().subtract(const Duration(days: 60)); // 60 days ago
      final expectedDueDate = confirmationDate.add(const Duration(days: 280)); // 280 days from confirmation
      
      final demoTracking = PregnancyTracking(
        userId: userId,
        pregnancyConfirmedDate: confirmationDate,
        expectedDeliveryDate: expectedDueDate,
        currentWeek: 8, // 60 days / 7 = 8 weeks, 4 days
        currentDay: 4,
        trimester: 'Second',
        weight: 65.0,
        height: 165.0,
        babyName: 'Baby',
        isFirstChild: true,
        hasPregnancyLoss: false,
        medicalHistory: 'No significant medical history. Taking prenatal vitamins.',
        symptoms: ['Morning sickness (reduced)', 'Increased appetite', 'Mild fatigue'],
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

  // ========== DOCTOR MANAGEMENT OPERATIONS ==========

  Future<List<Doctor>> getAllDoctors() async {
    try {
      print('BackendService: getAllDoctors - Starting to fetch doctors from Firebase');
      // Get doctors from Firebase instead of SharedPreferences
      final doctorsData = await FirebaseService.getAllDoctors();
      print('BackendService: getAllDoctors - Received ${doctorsData.length} doctors from Firebase');
      
      final doctors = doctorsData.map((data) {
        print('BackendService: getAllDoctors - Converting doctor data: ${data['name']} (${data['specialization']})');
        return Doctor.fromMap(data);
      }).toList();
      
      print('BackendService: getAllDoctors - Successfully converted ${doctors.length} doctors');
      return doctors;
    } catch (e) {
      print('BackendService: getAllDoctors - ERROR: $e');
      print('BackendService: getAllDoctors - Stack trace: ${StackTrace.current}');
      throw e; // Re-throw the exception instead of returning empty list
    }
  }

  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      // Get doctor from Firebase instead of SharedPreferences
      final doctorData = await FirebaseService.getDoctorById(doctorId);
      
      if (doctorData != null) {
        return Doctor.fromMap(doctorData);
      }
      return null;
    } catch (e) {

      return null;
    }
  }

  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    try {
      // Get doctors by specialization from Firebase
      final doctorsData = await FirebaseService.getDoctorsBySpecialization(specialization);
      
      return doctorsData.map((data) => Doctor.fromMap(data)).toList();
    } catch (e) {

      return [];
    }
  }

  Future<List<String>> getAvailableSpecializations() async {
    try {
      // Get available specializations from Firebase
      return await FirebaseService.getAvailableSpecializations();
    } catch (e) {

      return [];
    }
  }

  Future<List<PatientDoctorLink>> getLinkedDoctors(String patientId) async {
    // This method is now deprecated - use Firebase methods instead
    return [];
  }

  Future<bool> linkPatientWithDoctor(String patientId, String doctorId) async {
    try {

      
      // Check if there's already a request/link for this patient-doctor pair
      final existingLink = await FirebaseService.getPatientDoctorLink(patientId, doctorId);
      
      if (existingLink != null) {

        return false; // Request already exists
      }
      

      
      // Create patient-doctor link in Firebase
      final linkId = await FirebaseService.createPatientDoctorLink(
        patientId: patientId,
        doctorId: doctorId,
        status: 'requested',
      );
      
      if (linkId != null) {

        return true;
      } else {

        return false;
      }
    } catch (e) {

      return false;
    }
  }

  Future<bool> unlinkPatientFromDoctor(String patientId, String doctorId) async {
    try {
      final existingLinks = await getLinkedDoctors(patientId);
      
      // Find and deactivate the link
      final linkIndex = existingLinks.indexWhere((link) => 
        link.doctorId == doctorId && link.isActive
      );
      
      if (linkIndex == -1) {
        return false; // Link not found
      }

      // Deactivate the link instead of removing it (for audit trail)
      existingLinks[linkIndex] = existingLinks[linkIndex].copyWith(
        isActive: false,
        status: 'unlinked',
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final linksData = jsonEncode(existingLinks.map((l) => l.toMap()).toList());
      await prefs.setString('patient_doctor_links_$patientId', linksData);

      return true;
    } catch (e) {

      return false;
    }
  }

  // ========== DOCTOR-SIDE PATIENT MANAGEMENT ==========

  // Get all patient requests for a doctor from Firebase
  Future<List<PatientDoctorLink>> getPatientRequestsForDoctor(String doctorId) async {
    try {

      
      final requestsData = await FirebaseService.getPatientRequestsForDoctor(doctorId);
      
      List<PatientDoctorLink> requests = [];
      
      for (final data in requestsData) {
        requests.add(PatientDoctorLink(
          id: data['id'],
          patientId: data['patientId'],
          doctorId: data['doctorId'],
          status: data['status'],
          isActive: data['isActive'],
          linkedDate: data['linkedDate'],
          createdAt: data['createdAt'],
          updatedAt: data['updatedAt'],
        ));
      }
      

      return requests;
    } catch (e) {

      return [];
    }
  }

  // Get all accepted patients for a doctor from Firebase
  Future<List<PatientDoctorLink>> getAcceptedPatientsForDoctor(String doctorId) async {
    try {

      
      final patientsData = await FirebaseService.getAcceptedPatientsForDoctor(doctorId);
      
      List<PatientDoctorLink> patients = [];
      
      for (final data in patientsData) {
        patients.add(PatientDoctorLink(
          id: data['id'],
          patientId: data['patientId'],
          doctorId: data['doctorId'],
          status: data['status'],
          isActive: data['isActive'],
          linkedDate: data['linkedDate'],
          createdAt: data['createdAt'],
          updatedAt: data['updatedAt'],
        ));
      }
      

      return patients;
    } catch (e) {

      return [];
    }
  }

  // Get all linked patients for a doctor (all statuses)
  Future<List<PatientDoctorLink>> getLinkedPatientsForDoctor(String doctorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('patient_doctor_links_'));
      
      List<PatientDoctorLink> allPatients = [];
      
      for (final key in keys) {
        final linksData = prefs.getString(key);
        if (linksData != null) {
          final List<dynamic> json = jsonDecode(linksData);
          final links = json.map((l) => PatientDoctorLink.fromMap(l)).toList();
          
          // Filter for this doctor's patients (all statuses)
          final doctorPatients = links.where((link) => 
            link.doctorId == doctorId && 
            link.isActive
          ).toList();
          
          allPatients.addAll(doctorPatients);
        }
      }
      
      // Sort by most recent first
      allPatients.sort((a, b) => b.linkedDate.compareTo(a.linkedDate));
      return allPatients;
    } catch (e) {

      return [];
    }
  }

  // Accept a patient request in Firebase
  Future<bool> acceptPatientRequest(String doctorId, String patientId, String linkId) async {
    try {

      
      final success = await FirebaseService.acceptPatientRequest(linkId);
      
      if (success) {

        return true;
      } else {

        return false;
      }
    } catch (e) {

      return false;
    }
  }

  // Decline a patient request in Firebase
  Future<bool> declinePatientRequest(String doctorId, String patientId, String linkId) async {
    try {

      
      final success = await FirebaseService.declinePatientRequest(linkId);
      
      if (success) {

        return true;
      } else {

        return false;
      }
    } catch (e) {

      return false;
    }
  }

  // Remove an accepted patient (unlink) permanently in Firebase
  Future<bool> removePatient(String doctorId, String patientId, String linkId) async {
    try {

      
      final success = await FirebaseService.removePatientFromDoctor(linkId);
      
      if (success) {

        return true;
      } else {

        return false;
      }
    } catch (e) {

      return false;
    }
  }

  // ========== PATIENT COUNT OPERATIONS ==========

  // Get total patient count from Firebase
  Future<int> getTotalPatientCount() async {
    try {
      return await FirebaseService.getTotalPatientCount();
    } catch (e) {

      return 0;
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

  // ========== PATIENT'S LINKED DOCTORS OPERATIONS ==========

  // Get all linked doctors for a patient (both pending and accepted)
  Future<List<Map<String, dynamic>>> getLinkedDoctorsForPatient(String patientId) async {
    try {

      
      final linkedDoctors = await FirebaseService.getLinkedDoctorsForPatient(patientId);
      

      return linkedDoctors;
    } catch (e) {

      return [];
    }
  }

  // ========== SYMPTOM LOGS OPERATIONS (FIRESTORE) ==========

  Future<List<SymptomLog>> getSymptomLogs(String patientId) async {
    try {
      // Get symptom logs from Firestore
      final logsData = await FirebaseService.getSymptomLogsForPatient(patientId);
      
      return logsData.map((data) => SymptomLog.fromMap(data)).toList()
        ..sort((a, b) => b.logDate.compareTo(a.logDate));
    } catch (e) {

      
      // Fallback to SharedPreferences (for migration period)
      final prefs = await SharedPreferences.getInstance();
      final logsData = prefs.getString('${symptomLogsKey}_$patientId');
      
      if (logsData == null) return [];
      
      final List<dynamic> json = jsonDecode(logsData);
      final logs = json.map((l) => SymptomLog.fromMap(l)).toList();
      
      return logs..sort((a, b) => b.logDate.compareTo(a.logDate));
    }
  }

  Future<bool> saveSymptomLog(SymptomLog log) async {
    try {
      // Save to Firestore
      final logId = await FirebaseService.saveSymptomLog(log.toMap());
      
      if (logId != null) {

        return true;
      } else {

        return false;
      }
    } catch (e) {

      
      // Fallback to SharedPreferences
      try {
        final logs = await getSymptomLogs(log.patientId);
        
        // Generate new ID if not provided
        final newLog = log.id == null 
            ? log.copyWith(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
              )
            : log;
        
        logs.add(newLog);
        
        final prefs = await SharedPreferences.getInstance();
        final logsData = jsonEncode(logs.map((l) => l.toMap()).toList());
        await prefs.setString('${symptomLogsKey}_${log.patientId}', logsData);
        return true;
      } catch (fallbackError) {

        return false;
      }
    }
  }

  Future<List<SymptomLog>> getRecentSymptomLogs(String patientId, {int days = 7}) async {
    final logs = await getSymptomLogs(patientId);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    return logs.where((log) => log.logDate.isAfter(cutoffDate)).toList();
  }

  // Method for doctors to get all symptom logs for their patients
  Future<Map<String, List<SymptomLog>>> getSymptomLogsForDoctorPatients(String doctorId) async {
    try {
      final acceptedPatients = await getAcceptedPatientsForDoctor(doctorId);
      final Map<String, List<SymptomLog>> patientLogs = {};
      
      for (final patientLink in acceptedPatients) {
        final logs = await getSymptomLogs(patientLink.patientId);
        if (logs.isNotEmpty) {
          patientLogs[patientLink.patientId] = logs;
        }
      }
      
      return patientLogs;
    } catch (e) {

      return {};
    }
  }

  // Get symptom logs by date range (useful for specific period analysis)
  Future<List<SymptomLog>> getSymptomLogsByDateRange(
    String patientId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final logsData = await FirebaseService.getSymptomLogsByDateRange(
        patientId, 
        startDate, 
        endDate
      );
      
      return logsData.map((data) => SymptomLog.fromMap(data)).toList()
        ..sort((a, b) => b.logDate.compareTo(a.logDate));
    } catch (e) {

      
      // Fallback: filter existing logs
      final allLogs = await getSymptomLogs(patientId);
      return allLogs.where((log) => 
        log.logDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
        log.logDate.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    }
  }

  Future<void> clearAllData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${pregnancyTrackingKey}_$userId');
    await prefs.remove('${medicalRecordsKey}_$userId');
    await prefs.remove('${remindersKey}_$userId');
    await prefs.remove('${appointmentsKey}_user_$userId');
    await prefs.remove('${symptomLogsKey}_$userId');
  }

  // Get doctor recommendations for meals and exercises
  Future<Map<String, dynamic>?> getDoctorRecommendations(String userId) async {
    try {
      print('BackendService: Getting doctor recommendations for user: $userId');
      
      // Try to get from Firebase first
      final recommendations = await FirebaseService.getDoctorRecommendations(userId);
      print('BackendService: Firebase recommendations: $recommendations');
      
      if (recommendations != null) {
        print('BackendService: Returning Firebase recommendations');
        return recommendations;
      }

      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final recommendationsJson = prefs.getString('doctor_recommendations_$userId');
      print('BackendService: Local storage data: $recommendationsJson');
      
      if (recommendationsJson != null) {
        final localData = json.decode(recommendationsJson);
        print('BackendService: Returning local recommendations: $localData');
        return localData;
      }

      print('BackendService: No recommendations found');
      return null;
    } catch (e) {
      print('BackendService: Error getting recommendations: $e');
      return null;
    }
  }

  // Save doctor recommendations (for doctors to set recommendations for patients)
  Future<bool> saveDoctorRecommendations(String patientId, Map<String, dynamic> recommendations) async {
    try {
      print('BackendService: Saving doctor recommendations for patient: $patientId');
      print('BackendService: Recommendations data: $recommendations');
      
      // Save to Firebase
      final firebaseSuccess = await FirebaseService.saveDoctorRecommendations(patientId, recommendations);
      print('BackendService: Firebase save result: $firebaseSuccess');

      // Also save locally as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_recommendations_$patientId', json.encode(recommendations));
      print('BackendService: Saved to local storage as backup');

      return firebaseSuccess;
    } catch (e) {
      print('BackendService: Error saving recommendations: $e');
      return false;
    }
  }
}
