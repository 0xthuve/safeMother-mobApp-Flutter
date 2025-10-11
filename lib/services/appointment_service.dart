import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/appointment.dart';

class AppointmentService {
  static const String _collectionName = 'appointments';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate available time slots (20-minute intervals)
  static List<String> getAllTimeSlots() {
    List<String> slots = [];

    // Morning slots: 8:00 AM - 12:00 PM
    for (int hour = 8; hour < 12; hour++) {
      for (int minute = 0; minute < 60; minute += 20) {
        slots.add(_formatTime(hour, minute));
      }
    }

    // Afternoon slots: 1:00 PM - 5:00 PM
    for (int hour = 13; hour < 17; hour++) {
      for (int minute = 0; minute < 60; minute += 20) {
        slots.add(_formatTime(hour, minute));
      }
    }

    return slots;
  }

  static String _formatTime(int hour, int minute) {
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  // Create appointment
  Future<String> createAppointment({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    String? reason,
    String? notes,
    String status = 'pending',
  }) async {
    try {
      final appointmentRef = _firestore.collection(_collectionName).doc();

      final appointment = Appointment(
        id: appointmentRef.id,
        patientId: patientId,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        status: status,
        reason: reason ?? '',
        notes: notes ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVideoCallEnabled: true,
        videoCallUrl: '',
        videoCallId: '',
      );

      // Save appointmentDate as ISO string to match existing data
      final data = appointment.toMap();
      data['appointmentDate'] = appointment.appointmentDate.toIso8601String();

      await appointmentRef.set(data);
      return appointmentRef.id;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Get patient appointments
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Appointment.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get patient appointments: $e');
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _firestore.collection(_collectionName).doc(appointmentId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  // Confirm appointment
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _firestore.collection(_collectionName).doc(appointmentId).update({
        'status': 'confirmed',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to confirm appointment: $e');
    }
  }

  // Check if a time slot is available
  Future<bool> isTimeSlotAvailable(
      String doctorId, DateTime date, String timeSlot) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isEqualTo: date.toIso8601String())
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status',
              whereIn: ['pending', 'confirmed', 'scheduled', 'rescheduled'])
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get available time slots
  Future<List<String>> getAvailableTimeSlotsForDate(
      String doctorId, DateTime date) async {
    try {
      final allSlots = getAllTimeSlots();
      final bookedSlots = <String>{};

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isEqualTo: date.toIso8601String())
          .where('status',
              whereIn: ['pending', 'confirmed', 'scheduled', 'rescheduled'])
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final appointment = Appointment.fromMap(data);
        bookedSlots.add(appointment.timeSlot);
      }

      return allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
    } catch (e) {
      return getAllTimeSlots();
    }
  }

  // Get upcoming appointments for patient (for dashboard)
  Future<List<Appointment>> getUpcomingAppointments(String patientId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('patientId', isEqualTo: patientId)
          .orderBy('appointmentDate', descending: false)
          .get();

      final appointments = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Appointment.fromMap(data);
      }).toList();

      // Filter for upcoming appointments with active statuses
      final activeStatuses = ['pending', 'scheduled', 'rescheduled', 'confirmed'];
      
      return appointments.where((appointment) {
        final appointmentDateOnly = DateTime(
          appointment.appointmentDate.year, 
          appointment.appointmentDate.month, 
          appointment.appointmentDate.day
        );
        final isNotPast = appointmentDateOnly.isAfter(today) || 
                         appointmentDateOnly.isAtSameMomentAs(today);
        final status = appointment.status.toLowerCase().trim();
        return isNotPast && activeStatuses.contains(status);
      }).take(5).toList(); // Limit to 5 for dashboard
    } catch (e) {
      throw Exception('Failed to get upcoming appointments: $e');
    }
  }

  // Get doctor appointments
  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Appointment.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get doctor appointments: $e');
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status, {DateTime? newDate, String? newTimeSlot}) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (newDate != null) {
        updates['appointmentDate'] = newDate.toIso8601String();
      }
      
      if (newTimeSlot != null) {
        updates['timeSlot'] = newTimeSlot;
      }
      
      await _firestore.collection(_collectionName).doc(appointmentId).update(updates);
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }

  // Get available time slots (wrapper for existing method with named parameters)
  Future<List<String>> getAvailableTimeSlots({
    required String doctorId, 
    required DateTime date
  }) async {
    return await getAvailableTimeSlotsForDate(doctorId, date);
  }

  // Book appointment (wrapper for createAppointment) - returns bool for success
  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    required String timeSlot,
    String? reason,
    String? notes,
    String status = 'pending',
  }) async {
    try {
      await createAppointment(
        patientId: patientId,
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        reason: reason,
        notes: notes,
        status: status,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Real-time listener for patient appointments
  Stream<List<Appointment>> getPatientAppointmentsStream(String patientId) {
    return _firestore
        .collection(_collectionName)
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Appointment.fromMap(data);
      }).toList();
    });
  }

  // Real-time listener for doctor appointments
  Stream<List<Appointment>> getDoctorAppointmentsStream(String doctorId) {
    return _firestore
        .collection(_collectionName)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Appointment.fromMap(data);
      }).toList();
    });
  }
}
