import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import 'session_manager.dart';

class AppointmentService {
  static const String appointmentsKey = 'appointments_v2';
  static const String doctorsKey = 'doctors_v2';
  static const String patientsKey = 'patients_v2';

  // Singleton pattern
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  // ========== APPOINTMENT OPERATIONS ==========

  Future<List<Appointment>> getAppointments({String? userId, String? doctorId, String? status}) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = prefs.getString(appointmentsKey);
    
    if (appointmentsData == null) return [];
    
    final List<dynamic> json = jsonDecode(appointmentsData);
    List<Appointment> appointments = json.map((a) => Appointment.fromMap(a)).toList();
    
    // Filter by user
    if (userId != null) {
      appointments = appointments.where((a) => a.patientId.toString() == userId).toList();
    }
    
    // Filter by doctor
    if (doctorId != null) {
      appointments = appointments.where((a) => a.doctorId.toString() == doctorId).toList();
    }
    
    // Filter by status
    if (status != null) {
      appointments = appointments.where((a) => a.status == status).toList();
    }
    
    return appointments..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    final appointments = await getAppointments(userId: userId);
    final now = DateTime.now();
    
    return appointments.where((a) => 
      a.appointmentDate.isAfter(now) && 
      (a.status == 'scheduled' || a.status == 'confirmed')
    ).take(5).toList();
  }

  Future<List<Appointment>> getTodaysAppointments({String? doctorId}) async {
    final appointments = await getAppointments(doctorId: doctorId);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return appointments.where((a) => 
      a.appointmentDate.isAfter(todayStart) && 
      a.appointmentDate.isBefore(todayEnd) &&
      a.status != 'cancelled'
    ).toList();
  }

  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    required String reason,
    String? notes,
  }) async {
    try {
      // Check if slot is available
      final isAvailable = await isTimeSlotAvailable(
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
      );

      if (!isAvailable) {
        return false;
      }

      final appointments = await _getAllAppointments();
      final newId = appointments.isEmpty ? 1 : appointments.map((a) => a.id!).reduce((a, b) => a > b ? a : b) + 1;
      
      final newAppointment = Appointment(
        id: newId,
        doctorId: int.parse(doctorId),
        patientId: int.parse(patientId),
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        status: 'scheduled',
        reason: reason,
        notes: notes ?? '',
        prescription: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      appointments.add(newAppointment);
      await _saveAllAppointments(appointments);
      return true;
    } catch (e) {

      return false;
    }
  }

  Future<bool> isTimeSlotAvailable({
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
  }) async {
    final appointments = await getAppointments(doctorId: doctorId);
    final dayAppointments = appointments.where((a) {
      final appointmentDay = DateTime(
        a.appointmentDate.year,
        a.appointmentDate.month,
        a.appointmentDate.day,
      );
      final requestedDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      return appointmentDay.isAtSameMomentAs(requestedDay) && 
             a.status != 'cancelled';
    }).toList();

    return !dayAppointments.any((a) => a.timeSlot == timeSlot);
  }

  Future<List<String>> getAvailableTimeSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    // Default time slots (9 AM - 5 PM, 30-minute intervals)
    final allSlots = [
      '09:00 AM - 09:30 AM',
      '09:30 AM - 10:00 AM',
      '10:00 AM - 10:30 AM',
      '10:30 AM - 11:00 AM',
      '11:00 AM - 11:30 AM',
      '11:30 AM - 12:00 PM',
      '02:00 PM - 02:30 PM',
      '02:30 PM - 03:00 PM',
      '03:00 PM - 03:30 PM',
      '03:30 PM - 04:00 PM',
      '04:00 PM - 04:30 PM',
      '04:30 PM - 05:00 PM',
    ];

    final appointments = await getAppointments(doctorId: doctorId);
    final dayAppointments = appointments.where((a) {
      final appointmentDay = DateTime(
        a.appointmentDate.year,
        a.appointmentDate.month,
        a.appointmentDate.day,
      );
      final requestedDay = DateTime(date.year, date.month, date.day);
      return appointmentDay.isAtSameMomentAs(requestedDay) && 
             a.status != 'cancelled';
    }).map((a) => a.timeSlot).toList();

    return allSlots.where((slot) => !dayAppointments.contains(slot)).toList();
  }

  Future<bool> updateAppointmentStatus(int appointmentId, String status, {String? notes}) async {
    try {
      final appointments = await _getAllAppointments();
      final index = appointments.indexWhere((a) => a.id == appointmentId);
      
      if (index == -1) return false;
      
      appointments[index] = appointments[index].copyWith(
        status: status,
        notes: notes ?? appointments[index].notes,
        updatedAt: DateTime.now(),
      );
      
      await _saveAllAppointments(appointments);
      return true;
    } catch (e) {

      return false;
    }
  }

  Future<bool> rescheduleAppointment({
    required int appointmentId,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    try {
      final appointments = await _getAllAppointments();
      final index = appointments.indexWhere((a) => a.id == appointmentId);
      
      if (index == -1) return false;
      
      final appointment = appointments[index];
      
      // Check if new slot is available
      final isAvailable = await isTimeSlotAvailable(
        doctorId: appointment.doctorId.toString(),
        appointmentDate: newDate,
        timeSlot: newTimeSlot,
      );

      if (!isAvailable) return false;

      appointments[index] = appointment.copyWith(
        appointmentDate: newDate,
        timeSlot: newTimeSlot,
        status: 'rescheduled',
        updatedAt: DateTime.now(),
      );
      
      await _saveAllAppointments(appointments);
      return true;
    } catch (e) {

      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId, {String? reason}) async {
    try {
      final appointments = await _getAllAppointments();
      final index = appointments.indexWhere((a) => a.id == appointmentId);
      
      if (index == -1) return false;
      
      appointments[index] = appointments[index].copyWith(
        status: 'cancelled',
        notes: reason != null 
            ? '${appointments[index].notes}\nCancellation reason: $reason'
            : appointments[index].notes,
        updatedAt: DateTime.now(),
      );
      
      await _saveAllAppointments(appointments);
      return true;
    } catch (e) {

      return false;
    }
  }

  // ========== DOCTOR OPERATIONS ==========

  Future<List<Doctor>> getAvailableDoctors({String? specialization}) async {
    final prefs = await SharedPreferences.getInstance();
    final doctorsData = prefs.getString(doctorsKey);
    
    List<Doctor> doctors = [];
    
    if (doctorsData != null) {
      final List<dynamic> json = jsonDecode(doctorsData);
      doctors = json.map((d) => Doctor.fromMap(d)).toList();
    } else {
      // Initialize with demo doctors
      await _initializeDoctors();
      doctors = await getAvailableDoctors();
    }
    
    if (specialization != null) {
      doctors = doctors.where((d) => 
        d.specialization.toLowerCase().contains(specialization.toLowerCase())
      ).toList();
    }
    
    return doctors.where((d) => d.isAvailable).toList();
  }

  Future<Doctor?> getDoctorById(String doctorId) async {
    final doctors = await getAvailableDoctors();
    try {
      return doctors.firstWhere((d) => d.id.toString() == doctorId);
    } catch (e) {
      return null;
    }
  }

  // ========== PATIENT OPERATIONS ==========

  Future<Patient?> getPatientById(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final patientsData = prefs.getString(patientsKey);
    
    if (patientsData == null) return null;
    
    final List<dynamic> json = jsonDecode(patientsData);
    final patients = json.map((p) => Patient.fromMap(p)).toList();
    
    try {
      return patients.firstWhere((p) => p.id.toString() == patientId);
    } catch (e) {
      return null;
    }
  }

  // ========== STATISTICS ==========

  Future<Map<String, dynamic>> getAppointmentStats({String? doctorId}) async {
    final appointments = await getAppointments(doctorId: doctorId);
    final now = DateTime.now();
    
    final total = appointments.length;
    final scheduled = appointments.where((a) => a.status == 'scheduled').length;
    final completed = appointments.where((a) => a.status == 'completed').length;
    final cancelled = appointments.where((a) => a.status == 'cancelled').length;
    final upcoming = appointments.where((a) => 
      a.appointmentDate.isAfter(now) && 
      a.status != 'cancelled'
    ).length;
    
    return {
      'total': total,
      'scheduled': scheduled,
      'completed': completed,
      'cancelled': cancelled,
      'upcoming': upcoming,
      'completionRate': total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0.0',
    };
  }

  // ========== PRIVATE HELPER METHODS ==========

  Future<List<Appointment>> _getAllAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = prefs.getString(appointmentsKey);
    
    if (appointmentsData == null) return [];
    
    final List<dynamic> json = jsonDecode(appointmentsData);
    return json.map((a) => Appointment.fromMap(a)).toList();
  }

  Future<void> _saveAllAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsData = jsonEncode(appointments.map((a) => a.toMap()).toList());
    await prefs.setString(appointmentsKey, appointmentsData);
  }

  Future<void> _initializeDoctors() async {
    final now = DateTime.now();
    final demoDoctors = [
      Doctor(
        id: 1,
        name: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@hospital.com',
        phone: '+1-555-0101',
        specialization: 'Obstetrics & Gynecology',
        licenseNumber: 'MD123456',
        hospital: 'City General Hospital',
        experience: '10 years',
        bio: 'Specialized in high-risk pregnancies and maternal-fetal medicine.',
        rating: 4.8,
        totalPatients: 150,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      ),
      Doctor(
        id: 2,
        name: 'Dr. Michael Chen',
        email: 'michael.chen@hospital.com',
        phone: '+1-555-0102',
        specialization: 'Pediatrics',
        licenseNumber: 'MD123457',
        hospital: 'Children\'s Medical Center',
        experience: '8 years',
        bio: 'Expert in newborn care and pediatric development.',
        rating: 4.7,
        totalPatients: 200,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      ),
      Doctor(
        id: 3,
        name: 'Dr. Emily Rodriguez',
        email: 'emily.rodriguez@hospital.com',
        phone: '+1-555-0103',
        specialization: 'Maternal-Fetal Medicine',
        licenseNumber: 'MD123458',
        hospital: 'Women\'s Health Center',
        experience: '12 years',
        bio: 'Specializes in high-risk pregnancies and prenatal diagnosis.',
        rating: 4.9,
        totalPatients: 120,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    final doctorsData = jsonEncode(demoDoctors.map((d) => d.toMap()).toList());
    await prefs.setString(doctorsKey, doctorsData);
  }

  // ========== INITIALIZATION ==========

  Future<void> initializeDemoAppointments() async {
    final appointments = await _getAllAppointments();
    if (appointments.isNotEmpty) return; // Already initialized

    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final demoAppointments = [
      Appointment(
        id: 1,
        doctorId: 1,
        patientId: int.parse(userId),
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
        timeSlot: '10:00 AM - 10:30 AM',
        status: 'scheduled',
        reason: 'Monthly prenatal checkup',
        notes: 'Regular checkup to monitor baby\'s growth',
        prescription: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: 2,
        doctorId: 3,
        patientId: int.parse(userId),
        appointmentDate: DateTime.now().add(const Duration(days: 10)),
        timeSlot: '02:00 PM - 02:30 PM',
        status: 'scheduled',
        reason: 'Ultrasound appointment',
        notes: 'Anatomy scan and growth assessment',
        prescription: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Appointment(
        id: 3,
        doctorId: 1,
        patientId: int.parse(userId),
        appointmentDate: DateTime.now().subtract(const Duration(days: 14)),
        timeSlot: '09:00 AM - 09:30 AM',
        status: 'completed',
        reason: 'First trimester screening',
        notes: 'Completed blood work and NT scan',
        prescription: 'Prenatal vitamins, Folic acid 400mg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await _saveAllAppointments(demoAppointments);
  }
}
