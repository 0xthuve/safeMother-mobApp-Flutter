import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../services/appointment_service.dart';
import '../../services/session_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAppointments extends StatefulWidget {
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  final int _currentIndex = 2;
  List<Appointment> _appointments = [];
  Map<String, Patient> _patientsMap = {};
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final AppointmentService _appointmentService = AppointmentService();
  String? _currentDoctorId;
  String _currentDoctorName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current doctor ID from session
      _currentDoctorId = await SessionManager.getUserId();
      
      if (_currentDoctorId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load current doctor's name
      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final doctorDoc = await firestore
            .collection('users')
            .doc(_currentDoctorId!)
            .get();
        
        if (doctorDoc.exists && doctorDoc.data() != null) {
          final doctorData = doctorDoc.data()!;
          print('Doctor data fields: ${doctorData.keys.toList()}');
          
          String doctorName = doctorData['name']?.toString() ?? 
                            doctorData['fullName']?.toString() ?? 
                            doctorData['firstName']?.toString() ?? 
                            'Unknown Doctor';
          
          if (doctorData['firstName'] != null && doctorData['lastName'] != null) {
            doctorName = '${doctorData['firstName']} ${doctorData['lastName']}';
          }
          
          _currentDoctorName = 'Dr. $doctorName';
          print('Loaded doctor name: $_currentDoctorName');
        }
      } catch (e) {
        print('Error loading doctor name: $e');
        _currentDoctorName = 'Dr. Unknown';
      }

      // Load appointments for the current doctor
      final appointments = await _appointmentService.getDoctorAppointments(_currentDoctorId!);
      
      // Debug: Print all appointment details
      print('Found ${appointments.length} appointments for doctor $_currentDoctorId');
      for (final appointment in appointments) {
        print('Appointment: ${appointment.id}, Patient: ${appointment.patientId}, Date: ${appointment.appointmentDate}, Status: ${appointment.status}');
      }
      
      // Load patient data for each appointment
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      _patientsMap.clear();
      
      for (final appointment in appointments) {
        if (!_patientsMap.containsKey(appointment.patientId)) {
          try {
            // First try to get basic user info from users collection
            final userDoc = await firestore
                .collection('users')
                .doc(appointment.patientId)
                .get();
            
            if (userDoc.exists && userDoc.data() != null) {
              final userData = userDoc.data()!;
              print('Found user data for ${appointment.patientId}: ${userData['name'] ?? userData['fullName'] ?? 'No name field'}');
              print('User data fields: ${userData.keys.toList()}');
              
              try {
                // Try to get additional patient-specific data from patients collection
                final patientDoc = await firestore
                    .collection('patients')
                    .doc(appointment.patientId)
                    .get();
                
                // Helper function to safely parse dates
                String safeDate(dynamic dateValue, DateTime defaultDate) {
                  if (dateValue == null) return defaultDate.toIso8601String();
                  if (dateValue is String) {
                    try {
                      DateTime.parse(dateValue); // Validate the string
                      return dateValue;
                    } catch (e) {
                      return defaultDate.toIso8601String();
                    }
                  }
                  if (dateValue is DateTime) return dateValue.toIso8601String();
                  return defaultDate.toIso8601String();
                }
                
                // Start with user data
                final now = DateTime.now();
                final defaultBirthDate = now.subtract(const Duration(days: 365 * 25));
                
                // Get patient name from various possible fields
                String patientName = userData['name']?.toString() ?? 
                                   userData['fullName']?.toString() ?? 
                                   userData['firstName']?.toString() ?? 
                                   'Unknown Patient';
                
                // If we have both first and last name, combine them
                if (userData['firstName'] != null && userData['lastName'] != null) {
                  patientName = '${userData['firstName']} ${userData['lastName']}';
                }
                
                // Combine user and patient data safely
                final combinedData = <String, dynamic>{
                  'id': appointment.patientId,
                  'name': patientName,
                  'email': userData['email']?.toString() ?? '',
                  'phone': userData['phone']?.toString() ?? '',
                  'dateOfBirth': safeDate(userData['dateOfBirth'], defaultBirthDate),
                  'bloodType': userData['bloodType']?.toString() ?? 'Unknown',
                  'emergencyContact': userData['emergencyContact']?.toString() ?? '',
                  'emergencyPhone': userData['emergencyPhone']?.toString() ?? '',
                  'medicalHistory': userData['medicalHistory']?.toString() ?? '',
                  'allergies': userData['allergies']?.toString() ?? '',
                  'currentMedications': userData['currentMedications']?.toString() ?? '',
                  'lastVisit': safeDate(userData['lastVisit'], now),
                  'assignedDoctorId': _currentDoctorId,
                  'createdAt': safeDate(userData['createdAt'], now),
                  'updatedAt': safeDate(userData['updatedAt'], now),
                };
                
                // Override with patient-specific data if available
                if (patientDoc.exists) {
                  final patientData = patientDoc.data()!;
                  print('Found additional patient data for ${appointment.patientId}');
                  
                  // Safely merge patient data
                  patientData.forEach((key, value) {
                    if (value != null) {
                      if (key.contains('Date') || key == 'lastVisit' || key == 'createdAt' || key == 'updatedAt') {
                        combinedData[key] = safeDate(value, now);
                      } else {
                        combinedData[key] = value.toString();
                      }
                    }
                  });
                }
                
                _patientsMap[appointment.patientId] = Patient.fromMap(combinedData);
                print('Successfully loaded patient: ${combinedData['name']}');
              } catch (e) {
                print('Error processing patient data for ${appointment.patientId}: $e');
                // Get patient name from various possible fields
                String fallbackName = userData['name']?.toString() ?? 
                                     userData['fullName']?.toString() ?? 
                                     userData['firstName']?.toString() ?? 
                                     'Unknown Patient';
                
                if (userData['firstName'] != null && userData['lastName'] != null) {
                  fallbackName = '${userData['firstName']} ${userData['lastName']}';
                }
                
                // Create a simple patient with basic user data only
                _patientsMap[appointment.patientId] = Patient(
                  id: appointment.patientId,
                  name: fallbackName,
                  email: userData['email']?.toString() ?? '',
                  phone: userData['phone']?.toString() ?? '',
                  dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
                  bloodType: 'Unknown',
                  emergencyContact: '',
                  emergencyPhone: '',
                  lastVisit: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
              }
            } else {
              print('No user data found for patient ID: ${appointment.patientId}');
              print('User document exists: ${userDoc.exists}, Data: ${userDoc.data()}');
              
              // Try to get patient data directly from patients collection
              try {
                final patientDoc = await firestore
                    .collection('patients')
                    .doc(appointment.patientId)
                    .get();
                
                if (patientDoc.exists && patientDoc.data() != null) {
                  final patientData = patientDoc.data()!;
                  print('Found direct patient data: ${patientData.keys.toList()}');
                  
                  String patientName = patientData['name']?.toString() ?? 
                                     patientData['fullName']?.toString() ?? 
                                     patientData['firstName']?.toString() ?? 
                                     'Patient ${appointment.patientId.substring(0, 8)}...';
                  
                  if (patientData['firstName'] != null && patientData['lastName'] != null) {
                    patientName = '${patientData['firstName']} ${patientData['lastName']}';
                  }
                  
                  _patientsMap[appointment.patientId] = Patient(
                    id: appointment.patientId,
                    name: patientName,
                    email: patientData['email']?.toString() ?? '',
                    phone: patientData['phone']?.toString() ?? '',
                    dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
                    bloodType: patientData['bloodType']?.toString() ?? 'Unknown',
                    emergencyContact: patientData['emergencyContact']?.toString() ?? '',
                    emergencyPhone: patientData['emergencyPhone']?.toString() ?? '',
                    lastVisit: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                } else {
                  print('No patient data found either');
                  // Create a placeholder patient
                  _patientsMap[appointment.patientId] = Patient(
                    id: appointment.patientId,
                    name: 'Patient ${appointment.patientId.substring(0, 8)}...',
                    email: '',
                    phone: '',
                    dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
                    bloodType: 'Unknown',
                    emergencyContact: '',
                    emergencyPhone: '',
                    lastVisit: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                }
              } catch (e) {
                print('Error loading direct patient data: $e');
                // Create a placeholder patient
                _patientsMap[appointment.patientId] = Patient(
                  id: appointment.patientId,
                  name: 'Unknown Patient',
                  email: '',
                  phone: '',
                  dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
                  bloodType: 'Unknown',
                  emergencyContact: '',
                  emergencyPhone: '',
                  lastVisit: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
              }
            }
          } catch (e, stackTrace) {
            print('Error loading patient ${appointment.patientId}: $e');
            print('Stack trace: $stackTrace');
            // Create a placeholder patient on error
            _patientsMap[appointment.patientId] = Patient(
              id: appointment.patientId,
              name: 'Patient ${appointment.patientId.substring(0, 8)}...',
              email: '',
              phone: '',
              dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
              bloodType: 'Unknown',
              emergencyContact: '',
              emergencyPhone: '',
              lastVisit: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
      }

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load appointments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  List<Appointment> get _filteredAppointments {
    if (_selectedFilter == 'all') return _appointments;
    return _appointments.where((apt) => apt.status == _selectedFilter).toList();
  }

  Patient? _getPatientById(String? patientId) {
    if (patientId == null) return null;
    return _patientsMap[patientId];
  }

  String _getDoctorName() {
    return _currentDoctorName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFF8F6F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1976D2),
                        letterSpacing: -1.5,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1976D2).withOpacity(0.15),
                            const Color(0xFF1976D2).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded, color: Color(0xFF1976D2), size: 24),
                        onPressed: () {
                          _showAddAppointmentDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // Enhanced Filter Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1E40AF).withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                // Stats Summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFFF8FAFC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E293B).withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total', _appointments.length.toString(), const Color(0xFF3B82F6)),
                      _buildStatCard('Today', _appointments.where((a) => _isToday(a.appointmentDate)).length.toString(), const Color(0xFF10B981)),
                      _buildStatCard('Pending', _appointments.where((a) => a.status == 'pending').length.toString(), const Color(0xFFF59E0B)),
                    ],
                  ),
                ),
                
                // Filter Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Scheduled', 'scheduled'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Completed', 'completed'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Cancelled', 'cancelled'),
                        const SizedBox(width: 12),
                        _buildFilterChip('Rescheduled', 'rescheduled'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Appointments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No appointments found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _filteredAppointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(
          colors: [
            const Color(0xFF2563EB),
            const Color(0xFF1D4ED8),
          ],
        ) : null,
        color: isSelected ? null : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final patient = _getPatientById(appointment.patientId);
    final statusColor = _getStatusColor(appointment.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFFAFBFC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor.withOpacity(0.05),
                  statusColor.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Enhanced Status Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        statusColor,
                        statusColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getStatusIcon(appointment.status),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient?.name ?? 'Unknown Patient',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [statusColor, statusColor.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              appointment.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatDate(appointment.appointmentDate)} • ${appointment.timeSlot}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getDoctorName(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (appointment.reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.reason,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.notes,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Enhanced Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _viewAppointmentDetails(appointment),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: const Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'View Details',
                              style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2563EB),
                        const Color(0xFF1D4ED8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _updateAppointmentStatus(appointment),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Update Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'rescheduled':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Icons.schedule_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'rescheduled':
        return Icons.update_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Appointment'),
        content: const Text('This feature will be implemented in the next phase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewAppointmentDetails(Appointment appointment) {
    final patient = _getPatientById(appointment.patientId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient', patient?.name ?? 'Unknown'),
              _buildDetailRow('Doctor', _getDoctorName()),
              _buildDetailRow('Date', _formatDate(appointment.appointmentDate)),
              _buildDetailRow('Time', appointment.timeSlot),
              _buildDetailRow('Status', appointment.status),
              if (appointment.reason.isNotEmpty)
                _buildDetailRow('Reason', appointment.reason),
              if (appointment.notes.isNotEmpty)
                _buildDetailRow('Notes', appointment.notes),
              if (appointment.prescription.isNotEmpty)
                _buildDetailRow('Prescription', appointment.prescription),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateAppointmentStatus(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Scheduled'),
              subtitle: const Text('Confirm the appointment'),
              onTap: () => _updateStatus(appointment, 'scheduled'),
            ),
            ListTile(
              title: const Text('Completed'),
              subtitle: const Text('Mark as completed'),
              onTap: () => _updateStatus(appointment, 'completed'),
            ),
            ListTile(
              title: const Text('Cancelled'),
              subtitle: const Text('Cancel the appointment'),
              onTap: () => _updateStatus(appointment, 'cancelled'),
            ),
            ListTile(
              title: const Text('Reschedule'),
              subtitle: const Text('Change date and time'),
              onTap: () => _rescheduleAppointment(appointment),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(Appointment appointment, String newStatus) async {
    Navigator.pop(context);
    
    try {
      // Update status in Firebase
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.id)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      setState(() {
        final idx = _appointments.indexWhere((a) => a.id == appointment.id);
        if (idx != -1) {
          _appointments[idx] = _appointments[idx].copyWith(status: newStatus);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rescheduleAppointment(Appointment appointment) async {
    Navigator.pop(context); // Close the status dialog first

    DateTime? selectedDate;
    String? selectedTimeSlot;

    // Show date picker first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: appointment.appointmentDate.isAfter(DateTime.now()) 
          ? appointment.appointmentDate 
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null) return;
    selectedDate = pickedDate;

    // Get available time slots for the selected date
    try {
      final availableSlots = await _appointmentService.getAvailableTimeSlotsForDate(
        appointment.doctorId,
        selectedDate,
      );

      if (availableSlots.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No available time slots for selected date'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show time slot selection dialog
      if (mounted) {
        selectedTimeSlot = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Select Time - ${DateFormat('MMM dd, yyyy').format(selectedDate!)}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = availableSlots[index];
                  return ListTile(
                    title: Text(slot),
                    onTap: () => Navigator.pop(context, slot),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }

      if (selectedTimeSlot == null) return;

      // Update appointment with new date, time, and status
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.id)
          .update({
        'appointmentDate': Timestamp.fromDate(selectedDate),
        'timeSlot': selectedTimeSlot,
        'status': 'rescheduled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      setState(() {
        final idx = _appointments.indexWhere((a) => a.id == appointment.id);
        if (idx != -1) {
          _appointments[idx] = _appointments[idx].copyWith(
            appointmentDate: selectedDate,
            timeSlot: selectedTimeSlot,
            status: 'rescheduled',
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment rescheduled to ${DateFormat('MMM dd, yyyy').format(selectedDate)} at $selectedTimeSlot'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

