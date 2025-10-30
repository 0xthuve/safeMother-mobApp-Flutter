// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/doctor.dart';
// import '../models/patient.dart';
// import '../models/appointment.dart';

// class DatabaseHelper {
//   static const String doctorsKey = 'doctors';
//   static const String patientsKey = 'patients';
//   static const String appointmentsKey = 'appointments';

//   // Singleton pattern
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   // Doctor operations
//   Future<List<Doctor>> getDoctors() async {
//     final prefs = await SharedPreferences.getInstance();
//     final doctorsJson = prefs.getString(doctorsKey);
//     if (doctorsJson == null) return [];
    
//     final List<dynamic> decoded = json.decode(doctorsJson);
//     return decoded.map((json) => Doctor.fromMap(json)).toList();
//   }

//   Future<int> insertDoctor(Doctor doctor) async {
//     final doctors = await getDoctors();
//     final newId = doctors.isEmpty ? 1 : doctors.map((d) => d.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
//     final newDoctor = doctor.copyWith(id: newId);
//     doctors.add(newDoctor);
//     await _saveDoctors(doctors);
//     return newId;
//   }

//   Future<void> updateDoctor(Doctor doctor) async {
//     final doctors = await getDoctors();
//     final index = doctors.indexWhere((d) => d.id == doctor.id);
//     if (index != -1) {
//       doctors[index] = doctor;
//       await _saveDoctors(doctors);
//     }
//   }

//   Future<void> deleteDoctor(int id) async {
//     final doctors = await getDoctors();
//     doctors.removeWhere((d) => d.id == id);
//     await _saveDoctors(doctors);
//   }

//   Future<void> _saveDoctors(List<Doctor> doctors) async {
//     final prefs = await SharedPreferences.getInstance();
//     final encoded = json.encode(doctors.map((d) => d.toMap()).toList());
//     await prefs.setString(doctorsKey, encoded);
//   }

//   // Patient operations
//   Future<List<Patient>> getPatients() async {
//     final prefs = await SharedPreferences.getInstance();
//     final patientsJson = prefs.getString(patientsKey);
//     if (patientsJson == null) return [];
    
//     final List<dynamic> decoded = json.decode(patientsJson);
//     return decoded.map((json) => Patient.fromMap(json)).toList();
//   }

//   Future<int> insertPatient(Patient patient) async {
//     final patients = await getPatients();
//     final newId = patients.isEmpty ? 1 : patients.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
//     final newPatient = patient.copyWith(id: newId);
//     patients.add(newPatient);
//     await _savePatients(patients);
//     return newId;
//   }

//   Future<void> updatePatient(Patient patient) async {
//     final patients = await getPatients();
//     final index = patients.indexWhere((p) => p.id == patient.id);
//     if (index != -1) {
//       patients[index] = patient;
//       await _savePatients(patients);
//     }
//   }

//   Future<void> deletePatient(int id) async {
//     final patients = await getPatients();
//     patients.removeWhere((p) => p.id == id);
//     await _savePatients(patients);
//   }

//   Future<void> _savePatients(List<Patient> patients) async {
//     final prefs = await SharedPreferences.getInstance();
//     final encoded = json.encode(patients.map((p) => p.toMap()).toList());
//     await prefs.setString(patientsKey, encoded);
//   }

//   // Appointment operations
//   Future<List<Appointment>> getAppointments() async {
//     final prefs = await SharedPreferences.getInstance();
//     final appointmentsJson = prefs.getString(appointmentsKey);
//     if (appointmentsJson == null) return [];
    
//     final List<dynamic> decoded = json.decode(appointmentsJson);
//     return decoded.map((json) => Appointment.fromMap(json)).toList();
//   }

//   Future<String> insertAppointment(Appointment appointment) async {
//     final appointments = await getAppointments();
//     final newId = 'appt_${DateTime.now().millisecondsSinceEpoch}';
//     final newAppointment = appointment.copyWith(id: newId);
//     appointments.add(newAppointment);
//     await _saveAppointments(appointments);
//     return newId;
//   }

//   Future<void> updateAppointment(Appointment appointment) async {
//     final appointments = await getAppointments();
//     final index = appointments.indexWhere((a) => a.id == appointment.id);
//     if (index != -1) {
//       appointments[index] = appointment;
//       await _saveAppointments(appointments);
//     }
//   }

//   Future<void> deleteAppointment(String id) async {
//     final appointments = await getAppointments();
//     appointments.removeWhere((a) => a.id == id);
//     await _saveAppointments(appointments);
//   }

//   Future<void> _saveAppointments(List<Appointment> appointments) async {
//     final prefs = await SharedPreferences.getInstance();
//     final encoded = json.encode(appointments.map((a) => a.toMap()).toList());
//     await prefs.setString(appointmentsKey, encoded);
//   }

//   // Utility methods
//   Future<void> clearAllData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(doctorsKey);
//     await prefs.remove(patientsKey);
//     await prefs.remove(appointmentsKey);
//   }
// }
