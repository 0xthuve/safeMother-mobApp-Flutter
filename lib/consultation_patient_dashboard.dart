import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'navigation_handler.dart';
import 'bottom_navigation.dart';
import 'services/backend_service.dart';
import 'services/appointment_service.dart';
import 'services/session_manager.dart';
import 'models/doctor.dart';
import 'models/appointment.dart';
import 'l10n/app_localizations.dart';
import 'utils/conversation_utils.dart';

void main() {
  runApp(const PregnancyApp());
}

class PregnancyApp extends StatelessWidget {
  const PregnancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - Consultation',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF9F7F9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFF7B68EE),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const ConsultationScreen(),
    );
  }
}

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final int _currentIndex = 2; // Consultation is active
  final BackendService _backendService = BackendService();
  final AppointmentService _appointmentService = AppointmentService();
  
  List<Doctor> _linkedDoctors = [];
  List<Appointment> _upcomingAppointments = [];
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadDataOptimized();
  }

  Future<void> _loadDataOptimized() async {
    // Show loading only on first load
    if (!_hasLoadedOnce) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      _userId = await SessionManager.getUserId();
      if (_userId != null) {
        // Load data in parallel for better performance
        await Future.wait([
          _loadAllDoctors(),
          _loadUpcomingAppointments(),
        ]);
      }
    } catch (e) {
      print('Error loading consultation data: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    }
  }

Future<void> _loadAllDoctors() async {
  try {
    print('🔍 _loadAllDoctors: Starting to load doctors for user: $_userId');
    final doctorsData = await _backendService.getLinkedDoctorsForPatient(_userId!);
    
    // Debug: Print doctor data to verify Firebase UID
    print('🔍 _loadAllDoctors: Received ${doctorsData.length} doctors from backend');
    for (var doctorData in doctorsData) {
      print('  - Doctor: ${doctorData['doctorName']}');
      print('    License: ${doctorData['doctorId']}');
      print('    Firebase UID: ${doctorData['doctorId']}');
    }
    
    // Convert Map data to Doctor objects
    final doctors = doctorsData.map((data) => Doctor(
      id: data['doctorId']?.toString(),
      firebaseUid: data['doctorId']?.toString(), // Firebase UID from doctorId field
      name: data['doctorName'] ?? 'Unknown Doctor',
      email: data['doctorEmail'] ?? '',
      phone: data['doctorPhone'] ?? '',
      specialization: data['specialization'] ?? 'General Practice',
      licenseNumber: data['doctorId']?.toString() ?? '', // Use doctorId as license number
      hospital: data['hospital'] ?? 'Unknown Hospital',
      experience: '0 years',
      bio: 'Healthcare professional',
      profileImage: '',
      rating: 0.0,
      totalPatients: 0,
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();
    
    // Debug: Print doctor data to verify Firebase UID and phone
    print('🔍 Converting ${doctors.length} doctors to objects:');
    for (int i = 0; i < doctors.length; i++) {
      final doctor = doctors[i];
      final data = doctorsData[i];
      print('  - Doctor ${i+1}: ${doctor.name}');
      print('    Raw data phone: ${data['doctorPhone']}');
      print('    Object phone: ${doctor.phone}');
      print('    Email: ${doctor.email}');
      print('    Specialization: ${doctor.specialization}');
    }
    
    // Only setState if data actually changed
    if (_linkedDoctors.length != doctors.length || 
        !_listsEqual(_linkedDoctors, doctors)) {
      setState(() {
        _linkedDoctors = doctors;
      });
    }
    
    print('✅ Successfully loaded ${doctors.length} linked doctors for patient $_userId');
  } catch (e) {
    print('❌ Error loading linked doctors: $e');
    if (_linkedDoctors.isNotEmpty) {
      setState(() {
        _linkedDoctors = [];
      });
    }
  }
}
  // Helper method to compare doctor lists
  bool _listsEqual(List<Doctor> list1, List<Doctor> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }
    return true;
  }

  Future<void> _loadUpcomingAppointments() async {
    try {
      final appointments = await _appointmentService.getUpcomingAppointments(_userId!);
      
      // Only setState if data actually changed
      if (_upcomingAppointments.length != appointments.length || 
          !_appointmentListsEqual(_upcomingAppointments, appointments)) {
        setState(() {
          _upcomingAppointments = appointments;
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      if (_upcomingAppointments.isNotEmpty) {
        setState(() {
          _upcomingAppointments = [];
        });
      }
    }
  }

  // Helper method to compare appointment lists
  bool _appointmentListsEqual(List<Appointment> list1, List<Appointment> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || 
          list1[i].status != list2[i].status) return false;
    }
    return true;
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  // Safe method to get localized strings
  dynamic _getLocalizedString(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Fallback English strings if localization is not available
      final fallbackStrings = {
        'loadingConsultationData': 'Loading consultation data...',
        'consultation': 'Consultation',
        'quickActions': 'Quick Actions',
        'bookAppointment': 'Book Appointment',
        'quickChat': 'Quick Chat',
        'upcomingAppointments': 'Upcoming Appointments',
        'noUpcomingAppointments': 'No upcoming appointments',
        'scheduleAppointment': 'Schedule an appointment to get started',
        'goToProfileSettings': 'Go to Profile Settings',
        'refresh': 'Refresh',
        'bookAppointmentButton': 'Book Appointment',
        'selectDoctor': 'Select Doctor',
        'chooseYourDoctor': 'Choose your doctor',
        'selectDate': 'Select Date',
        'chooseAppointmentDate': 'Choose appointment date',
        'selectTime': 'Select Time',
        'reasonForVisit': 'Reason for Visit',
        'appointmentExample': 'e.g., Routine checkup, Specific concern',
        'additionalNotesOptional': 'Additional Notes (Optional)',
        'specificConcerns': 'Any specific concerns or questions',
        'appointmentBookedSuccess': 'Appointment booked successfully!',
        'startConversation': (name) => 'Start a conversation with Dr. $name',
        'messagesSecure': 'Your messages are secure and private',
        'typeMessage': 'Type a message...',
        'now': 'now',
        'minutesAgo': (minutes) => '$minutes min ago',
        'hoursAgo': (hours) => '$hours h ago',
        'failedSendMessage': 'Failed to send message',
      };
      return fallbackStrings[key] ?? key;
    }

    // Use the actual localization methods
    switch (key) {
      case 'loadingConsultationData': return localizations.loadingConsultationData;
      case 'consultation': return localizations.consultation;
      case 'quickActions': return localizations.quickActions;
      case 'bookAppointment': return localizations.bookAppointment;
      case 'quickChat': return localizations.quickChat;
      case 'upcomingAppointments': return localizations.upcomingAppointments;
      case 'noUpcomingAppointments': return localizations.noUpcomingAppointments;
      case 'scheduleAppointment': return localizations.scheduleAppointment;
      case 'goToProfileSettings': return localizations.goToProfileSettings;
      case 'refresh': return localizations.refresh;
      case 'bookAppointmentButton': return localizations.bookAppointmentButton;
      case 'selectDoctor': return localizations.selectDoctor;
      case 'chooseYourDoctor': return localizations.chooseYourDoctor;
      case 'selectDate': return localizations.selectDate;
      case 'chooseAppointmentDate': return localizations.chooseAppointmentDate;
      case 'selectTime': return localizations.selectTime;
      case 'reasonForVisit': return localizations.reasonForVisit;
      case 'appointmentExample': return localizations.appointmentExample;
      case 'additionalNotesOptional': return localizations.additionalNotesOptional;
      case 'specificConcerns': return localizations.specificConcerns;
      case 'appointmentBookedSuccess': return localizations.appointmentBookedSuccess;
      case 'startConversation': return (name) => localizations.startConversation(name);
      case 'messagesSecure': return localizations.messagesSecure;
      case 'typeMessage': return localizations.typeMessage;
      case 'now': return localizations.now;
      case 'minutesAgo': return (minutes) => localizations.minutesAgo(minutes);
      case 'hoursAgo': return (hours) => localizations.hoursAgo(hours);
      case 'failedSendMessage': return localizations.failedSendMessage;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('🔍 Build called - isLoading: $_isLoading, linkedDoctors: ${_linkedDoctors.length}, hasLoadedOnce: $_hasLoadedOnce');
    
    return Scaffold(
      body: Stack(
        children: [
          // Background (similar to health log)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5E8FF), Color(0xFFF9F7F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Simplified decorative elements for better performance
          if (!_isLoading) ...[
            Positioned(
              top: -30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD1C4E9).withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE1BEE7).withOpacity(0.2),
                ),
              ),
            ),
          ],

          // Content
          SafeArea(
            child: _isLoading 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF7B1FA2),
                      ),
                      SizedBox(height: 16),
                      Text(
                        _getLocalizedString(context, 'loadingConsultationData'),
                        style: const TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (similar to health log)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              NavigationHandler.navigateToScreen(context, 0); // Navigate to Home
                            },
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),
                          ),
                          Text(
                            _getLocalizedString(context, 'consultation'),
                            style: const TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: _hasLoadedOnce ? () {
                              _loadDataOptimized(); // Optimized refresh
                            } : null,
                            icon: const Icon(Icons.refresh, color: Color(0xFF5A5A5A)),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quick Actions
                      _buildQuickActions(),
                      
                      const SizedBox(height: 32),
                      
                      // Available Doctors Section
                      _buildSectionHeader("Linked Doctors"),
                      
                      const SizedBox(height: 16),
                      
                      _linkedDoctors.isEmpty
                        ? (() {
                            print('🔍 Showing empty doctors card - linkedDoctors is empty');
                            return _buildEmptyDoctorsCard();
                          })()
                        : (() {
                            print('🔍 Showing doctors list - linkedDoctors has ${_linkedDoctors.length} items');
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _linkedDoctors.length,
                              itemBuilder: (context, index) => _buildDoctorCard(_linkedDoctors[index]),
                            );
                          })(),
                      
                      const SizedBox(height: 32),
                      
                      // Upcoming Appointments Section
                      _buildSectionHeader(_getLocalizedString(context, 'upcomingAppointments')),
                      
                      const SizedBox(height: 16),
                      
                      _upcomingAppointments.isEmpty
                        ? _buildNoAppointmentsCard()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _upcomingAppointments.length,
                            itemBuilder: (context, index) => _buildAppointmentCard(_upcomingAppointments[index]),
                          ),
                      
                      const SizedBox(height: 24), // Bottom spacing
                    ],
                  ),
                ),
          ),
          
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.medical_services,
            color: Color(0xFF7B1FA2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7B1FA2),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B1FA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: Color(0xFF7B1FA2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getLocalizedString(context, 'quickActions'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.calendar_today,
                  title: _getLocalizedString(context, 'bookAppointment'),
                  color: const Color(0xFF4A90E2),
                  onTap: () => _showBookAppointmentDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat,
                  title: _getLocalizedString(context, 'quickChat'),
                  color: const Color(0xFFE91E63),
                  onTap: () => _showQuickChatOptions(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF7B1FA2).withOpacity(0.1),
            child: Text(
              doctor.name.split(' ').map((n) => n[0]).take(2).join(),
              style: const TextStyle(
                color: Color(0xFF7B1FA2),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Doctor Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialization,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.rating}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Column(
            children: [
              IconButton(
                onPressed: () => _showChatDialog(doctor),
                icon: const Icon(Icons.chat, color: Color(0xFF7B1FA2)),
                iconSize: 20,
              ),
              IconButton(
                onPressed: () => _bookAppointmentWithDoctor(doctor),
                icon: const Icon(Icons.calendar_today, color: Color(0xFF81C784)),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDoctorsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No linked doctors found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't been linked with any doctors yet. Doctors will appear here once they accept your connection request.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_getLocalizedString(context, 'goToProfileSettings')),
                        backgroundColor: Color(0xFF7B1FA2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B1FA2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    "Add Doctor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _loadDataOptimized();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81C784),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text(
                    _getLocalizedString(context, 'refresh'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B1FA2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFF7B1FA2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.reason,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A5A5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(appointment.appointmentDate)} at ${appointment.timeSlot}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(appointment.status),
                  ),
                ),
              ),
            ],
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              appointment.notes,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoAppointmentsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getLocalizedString(context, 'noUpcomingAppointments'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getLocalizedString(context, 'scheduleAppointment'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookAppointmentDialog() {
    print('📅 Opening appointment booking dialog');
    print('📅 Linked doctors count: ${_linkedDoctors.length}');
    for (var doctor in _linkedDoctors) {
      print('  - ${doctor.name}: ${doctor.phone}');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BookAppointmentDialog(
        linkedDoctors: _linkedDoctors,
        onAppointmentBooked: () {
          _loadUpcomingAppointments();
        },
      ),
    );
  }

  void _showQuickChatOptions() {
    if (_linkedDoctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No linked doctors available for chat at the moment"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Quick Chat",
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose a doctor to start chatting:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...(_linkedDoctors.take(3).map((doctor) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
                  child: Text(
                    doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  doctor.specialization,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chat,
                  color: Color(0xFFE91E63),
                  size: 20,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showChatDialog(doctor);
                },
              ),
            )).toList()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF9575CD)),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => _ChatDialog(doctor: doctor, userId: _userId!),
    );
  }

  void _bookAppointmentWithDoctor(Doctor doctor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BookAppointmentDialog(
        linkedDoctors: [doctor],
        selectedDoctor: doctor,
        onAppointmentBooked: () {
          _loadUpcomingAppointments();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

// Book Appointment Dialog
class _BookAppointmentDialog extends StatefulWidget {
  final List<Doctor> linkedDoctors;
  final Doctor? selectedDoctor;
  final VoidCallback onAppointmentBooked;

  const _BookAppointmentDialog({
    required this.linkedDoctors,
    this.selectedDoctor,
    required this.onAppointmentBooked,
  });

  @override
  State<_BookAppointmentDialog> createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<_BookAppointmentDialog> {
  final AppointmentService _appointmentService = AppointmentService();
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _reason = '';
  String _notes = '';
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.selectedDoctor;
    if (_selectedDoctor != null) {
      _loadAvailableTimeSlotsForToday();
    }
  }

  // Safe method to get localized strings
  String _getLocalizedString(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Fallback English strings if localization is not available
      final fallbackStrings = {
        'bookAppointmentButton': 'Book Appointment',
        'selectDoctor': 'Select Doctor',
        'chooseYourDoctor': 'Choose your doctor',
        'selectDate': 'Select Date',
        'chooseAppointmentDate': 'Choose appointment date',
        'selectTime': 'Select Time',
        'reasonForVisit': 'Reason for Visit',
        'appointmentExample': 'e.g., Routine checkup, Specific concern',
        'additionalNotesOptional': 'Additional Notes (Optional)',
        'specificConcerns': 'Any specific concerns or questions',
        'appointmentBookedSuccess': 'Appointment booked successfully!',
      };
      return fallbackStrings[key] ?? key;
    }

    // Use the actual localization methods
    switch (key) {
      case 'bookAppointmentButton': return localizations.bookAppointmentButton;
      case 'selectDoctor': return localizations.selectDoctor;
      case 'chooseYourDoctor': return localizations.chooseYourDoctor;
      case 'selectDate': return localizations.selectDate;
      case 'chooseAppointmentDate': return localizations.chooseAppointmentDate;
      case 'selectTime': return localizations.selectTime;
      case 'reasonForVisit': return localizations.reasonForVisit;
      case 'appointmentExample': return localizations.appointmentExample;
      case 'additionalNotesOptional': return localizations.additionalNotesOptional;
      case 'specificConcerns': return localizations.specificConcerns;
      case 'appointmentBookedSuccess': return localizations.appointmentBookedSuccess;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Selection
                    _buildSectionTitle(_getLocalizedString(context, 'selectDoctor')),
                    const SizedBox(height: 8),
                    if (widget.linkedDoctors.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No linked doctors found. Please contact support or refresh the page.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Doctor>(
                            value: _selectedDoctor,
                            isExpanded: true,
                            hint: Text(_getLocalizedString(context, 'chooseYourDoctor')),
                            items: widget.linkedDoctors.map((doctor) {
                              return DropdownMenuItem(
                                value: doctor,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                                      child: Text(
                                        doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                                        style: const TextStyle(
                                          color: Color(0xFF4A90E2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            doctor.specialization,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (doctor) {
                              setState(() {
                                _selectedDoctor = doctor;
                                _selectedDate = null;
                                _selectedTimeSlot = null;
                                _availableTimeSlots = [];
                              });
                              if (doctor != null) {
                                _loadAvailableTimeSlotsForToday();
                              }
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Date Selection
                    _buildSectionTitle(_getLocalizedString(context, 'selectDate')),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectedDoctor != null ? _selectDate : null,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: _selectedDoctor == null ? Colors.grey.shade50 : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _selectedDoctor == null ? Colors.grey : const Color(0xFF4A90E2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!)
                                    : _getLocalizedString(context, 'chooseAppointmentDate'),
                                style: TextStyle(
                                  color: _selectedDate != null ? Colors.black : Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = null;
                                    _selectedTimeSlot = null;
                                    _availableTimeSlots = [];
                                  });
                                },
                                icon: const Icon(Icons.clear, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Time Slot Selection
                    if (_selectedDate != null) ...[
                      _buildSectionTitle(_getLocalizedString(context, 'selectTime')),
                      const SizedBox(height: 8),
                      if (_isLoadingSlots)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_availableTimeSlots.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No available time slots for this date. Please select a different date.',
                                  style: TextStyle(color: Colors.orange.shade700),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _availableTimeSlots.length,
                            itemBuilder: (context, index) {
                              final slot = _availableTimeSlots[index];
                              final isSelected = _selectedTimeSlot == slot;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedTimeSlot = slot; // Always select the clicked slot
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],

                    // Reason
                    _buildSectionTitle(_getLocalizedString(context, 'reasonForVisit')),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: _getLocalizedString(context, 'appointmentExample'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _reason = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Notes
                    _buildSectionTitle(_getLocalizedString(context, 'additionalNotesOptional')),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: _getLocalizedString(context, 'specificConcerns'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _notes = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Book Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canBookAppointment() ? _bookAppointment : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _getLocalizedString(context, 'bookAppointmentButton'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 90));

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTimeSlot = null;
      });
      await _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlotsForToday() async {
    if (_selectedDoctor == null) return;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    setState(() {
      _selectedDate = todayOnly;
      _isLoadingSlots = true;
    });

    try {
      final slots = await _appointmentService.getAvailableTimeSlots(
        doctorId: _selectedDoctor!.firebaseUid ?? _selectedDoctor!.id.toString(),
        date: todayOnly,
      );
      setState(() {
        _availableTimeSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      print('Error loading time slots: $e');
      setState(() {
        _availableTimeSlots = [];
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;

    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final slots = await _appointmentService.getAvailableTimeSlots(
        doctorId: _selectedDoctor!.firebaseUid ?? _selectedDoctor!.id.toString(),
        date: _selectedDate!,
      );
      setState(() {
        _availableTimeSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      print('Error loading time slots: $e');
      setState(() {
        _availableTimeSlots = [];
        _isLoadingSlots = false;
      });
    }
  }

  bool _canBookAppointment() {
    return _selectedDoctor != null &&
           _selectedDate != null &&
           _selectedTimeSlot != null &&
           !_isLoading &&
           !_isLoadingSlots;
  }

  Future<void> _bookAppointment() async {
    if (!_canBookAppointment()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('User not logged in');

      // CRITICAL FIX: Use firebaseUid instead of id (license number)
      final doctorFirebaseUid = _selectedDoctor!.firebaseUid;
      if (doctorFirebaseUid == null || doctorFirebaseUid.isEmpty) {
        throw Exception('Doctor Firebase UID not available. Please contact support.');
      }

      // Debug information
      print('📅 Booking appointment details:');
      print('  - Patient ID: $userId');
      print('  - Doctor Name: ${_selectedDoctor!.name}');
      print('  - Doctor License: ${_selectedDoctor!.id}');
      print('  - Doctor Firebase UID: $doctorFirebaseUid');
      print('  - Date: $_selectedDate');
      print('  - Time: $_selectedTimeSlot');
      print('  - Reason: $_reason');

      final success = await _appointmentService.bookAppointment(
        patientId: userId,
        doctorId: doctorFirebaseUid, // Use Firebase UID, NOT license number
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        reason: _reason.isNotEmpty ? _reason : 'General consultation', // Provide default if empty
        notes: _notes,
      );

      if (success) {
        widget.onAppointmentBooked();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString(context, 'appointmentBookedSuccess')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      print('❌ Appointment booking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Chat Dialog
class _ChatDialog extends StatefulWidget {
  final Doctor doctor;
  final String userId;

  const _ChatDialog({required this.doctor, required this.userId});

  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;
  bool _hasNewMessage = false;
  StreamSubscription? _messagesSubscription;

  // Safe method to get localized strings
  dynamic _getLocalizedString(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Fallback English strings if localization is not available
      final fallbackStrings = {
        'startConversation': (name) => 'Start a conversation with Dr. $name',
        'messagesSecure': 'Your messages are secure and private',
        'typeMessage': 'Type a message...',
        'now': 'now',
        'minutesAgo': (minutes) => '$minutes min ago',
        'hoursAgo': (hours) => '$hours h ago',
        'failedSendMessage': 'Failed to send message',
      };
      
      return fallbackStrings[key] ?? key;
    }

    // Use the actual localization methods
    switch (key) {
      case 'startConversation': return (name) => localizations.startConversation(name);
      case 'messagesSecure': return localizations.messagesSecure;
      case 'typeMessage': return localizations.typeMessage;
      case 'now': return localizations.now;
      case 'minutesAgo': return (minutes) => localizations.minutesAgo(minutes);
      case 'hoursAgo': return (hours) => localizations.hoursAgo(hours);
      case 'failedSendMessage': return localizations.failedSendMessage;
      default: return key;
    }
  }

  // Create standardized conversation ID using doctor's Firebase UID
  String _createConversationId(String patientId, Doctor doctor) {
    // Use doctor's Firebase UID for consistent conversation ID generation
    final doctorUid = doctor.firebaseUid ?? ConversationUtils.sanitizeEmail(doctor.email); // Fallback to sanitized email if UID not available
    final conversationId = ConversationUtils.createConversationId(patientId, doctorUid);
    print('🔍 Generated conversation ID: $conversationId');
    print('🔍 Doctor: ${doctor.name} (UID: $doctorUid)');
    print('🔍 Patient: $patientId');
    return conversationId;
  }

  @override
  void initState() {
    super.initState();
    _setupRealTimeChat();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupRealTimeChat() {
    try {
      final patientId = widget.userId;
      final DatabaseReference db = FirebaseDatabase.instance.ref();
      
      // Create standardized conversation ID for this specific doctor-patient pair
      final conversationId = _createConversationId(patientId, widget.doctor);
      
      // Set up real-time listener for messages
      final messagesRef = db.child('consultation_messages/$conversationId/messages')
          .orderByChild('timestamp');
      
      print('🔄 Setting up real-time listener for: consultation_messages/$conversationId/messages');
      
      _messagesSubscription = messagesRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        
        List<Map<String, dynamic>> messages = [];
        
        if (snapshot.exists && snapshot.value != null) {
          final messageData = snapshot.value as Map<dynamic, dynamic>;
          
          messageData.forEach((key, value) {
            final msgData = value as Map<dynamic, dynamic>;
            final senderId = msgData['senderId'] ?? '';
            final timestamp = msgData['timestamp'];
            DateTime messageTime;
            
            if (timestamp is int) {
              messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            } else {
              messageTime = DateTime.now();
            }
            
            // Determine if message is from doctor
            final isFromDoctor = senderId != patientId;
            
            messages.add({
              'id': key,
              'text': msgData['message'] ?? '',
              'isDoctor': isFromDoctor,
              'timestamp': messageTime,
              'read': msgData['read'] ?? false,
              'senderId': senderId,
            });
          });
        }
        
        // Sort messages by timestamp
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        
        // Update UI with new messages
        if (mounted) {
          final hasNewMessages = messages.length > _messages.length;
          final previousCount = _messages.length;
          
          setState(() {
            _messages.clear();
            _messages.addAll(messages);
            _hasNewMessage = hasNewMessages;
          });
          
          print('📱 UI Updated: ${messages.length} messages (was $previousCount)');
          
          // Show brief notification for new messages
          if (hasNewMessages && _messages.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _hasNewMessage = false;
                });
              }
            });
          }
        }
        
        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
      }, onError: (error) {
        print('❌ REAL-TIME CHAT ERROR: $error');
        if (mounted) {
          setState(() {
            _messages.clear();
          });
        }
      });
      
    } catch (e) {
      print('❌ CHAT SETUP ERROR: $e');
      if (mounted) {
        setState(() {
          _messages.clear();
        });
      }
    }
  }

  Future<void> _updateConversationMetadata(String conversationId, String patientId, Doctor doctor) async {
    try {
      final DatabaseReference db = FirebaseDatabase.instance.ref();
      
      // Use doctor's Firebase UID for consistent metadata
      final doctorId = doctor.firebaseUid ?? ConversationUtils.sanitizeEmail(doctor.email); // Fallback to sanitized email if UID not available
      
      // Update conversation metadata to help doctor-side find this conversation
      final conversationMeta = {
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'patientId': patientId,
        'doctorId': doctorId,
        'patientName': 'Patient', // Could be passed from patient data
        'doctorName': doctor.name,
        'doctorEmail': doctor.email,
        'lastActivity': DateTime.now().millisecondsSinceEpoch,
      };
      
      await db.child('consultation_messages/$conversationId/info').set(conversationMeta);
      print('✅ Updated conversation metadata for doctor visibility');
      
    } catch (e) {
      print('⚠️ Failed to update conversation metadata: $e');
      // Don't throw error as message was already sent successfully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.doctor.specialization,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),

                            if (_hasNewMessage) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getLocalizedString(context, 'startConversation')(widget.doctor.name),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getLocalizedString(context, 'messagesSecure'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),
            
            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: _getLocalizedString(context, 'typeMessage'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDoctor = message['isDoctor'] ?? false;
    final text = message['text'] ?? '';
    final timestamp = message['timestamp'] as DateTime;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDoctor) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4A90E2),
                child: Text(
                  widget.doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDoctor
                        ? Colors.grey[200]
                        : const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isDoctor ? Radius.zero : const Radius.circular(20),
                      bottomRight: isDoctor ? const Radius.circular(20) : Radius.zero,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: isDoctor ? Colors.black87 : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(timestamp),
                        style: TextStyle(
                          color: isDoctor ? Colors.grey[600] : Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isDoctor) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE91E63),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return _getLocalizedString(context, 'now');
    } else if (difference.inHours < 1) {
      return _getLocalizedString(context, 'minutesAgo')(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return _getLocalizedString(context, 'hoursAgo')(difference.inHours);
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final patientId = widget.userId;
      final DatabaseReference db = FirebaseDatabase.instance.ref();
      
      // Use the same standardized conversation ID as loading
      final conversationId = _createConversationId(patientId, widget.doctor);
      
      // Create message data matching Firebase rules
      final messageData = {
        'message': text,
        'senderId': patientId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'messageType': 'text', // Required by Firebase rules
        'read': false,
      };
      
      // Save message to Firebase using push() to generate unique key
      await db.child('consultation_messages/$conversationId/messages').push().set(messageData);
      
      // Update conversation metadata for doctor-side visibility
      await _updateConversationMetadata(conversationId, patientId, widget.doctor);
      
      // Clear input field - real-time listener will update UI
      _messageController.clear();
      
      print('✅ Message sent successfully to conversation: $conversationId');
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
    } catch (e) {
      print('❌ MESSAGE SEND ERROR: $e');
      print('Error type: ${e.runtimeType}');
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString(context, 'failedSendMessage')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
    
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}