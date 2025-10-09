import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation_handler.dart';
import 'bottom_navigation.dart';
import 'services/backend_service.dart';
import 'services/appointment_service.dart';
import 'services/session_manager.dart';
import 'models/doctor.dart';
import 'models/appointment.dart';



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
          _loadLinkedDoctors(),
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



  Future<void> _loadLinkedDoctors() async {
    try {
      final linkedDoctorsData = await _backendService.getLinkedDoctorsForPatient(_userId!);
      
      // Filter and process doctors more efficiently
      final acceptedDoctors = linkedDoctorsData.where((doctor) => doctor['status'] == 'accepted');
      
      // Use map instead of for-loop for better performance
      final doctors = acceptedDoctors.map((doctorData) {
        return Doctor(
          id: doctorData['doctorId']?.toString(),
          firebaseUid: doctorData['doctorFirebaseUid'],
          name: doctorData['doctorName'] ?? 'Unknown Doctor',
          email: doctorData['doctorEmail'] ?? '',
          phone: doctorData['doctorPhone'] ?? '',
          specialization: doctorData['doctorSpecialization'] ?? 'General Practice',
          licenseNumber: doctorData['doctorLicenseNumber'] ?? '',
          hospital: doctorData['doctorHospital'] ?? '',
          experience: doctorData['doctorExperience'] ?? '',
          bio: doctorData['doctorBio'] ?? '',
          profileImage: doctorData['doctorProfileImage'] ?? '',
          rating: (doctorData['doctorRating'] as num?)?.toDouble() ?? 4.5,
          totalPatients: doctorData['doctorTotalPatients'] ?? 0,
          isAvailable: doctorData['doctorIsAvailable'] ?? true,
          createdAt: doctorData['doctorCreatedAt'] != null 
            ? DateTime.parse(doctorData['doctorCreatedAt']) 
            : DateTime.now(),
          updatedAt: doctorData['doctorUpdatedAt'] != null 
            ? DateTime.parse(doctorData['doctorUpdatedAt']) 
            : DateTime.now(),
        );
      }).toList();
      
      // Only setState if data actually changed
      if (_linkedDoctors.length != doctors.length || 
          !_listsEqual(_linkedDoctors, doctors)) {
        setState(() {
          _linkedDoctors = doctors;
        });
      }
      
      print('Successfully loaded ${doctors.length} accepted doctors');
    } catch (e) {
      print('Error loading linked doctors: $e');
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

  @override
  Widget build(BuildContext context) {
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF7B1FA2),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading consultation data...',
                        style: TextStyle(
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
                          const Text(
                            'Consultation',
                            style: TextStyle(
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
                      
                      // Linked Doctors Section
                      _buildSectionHeader('Your Doctors'),
                      
                      const SizedBox(height: 16),
                      
                      _linkedDoctors.isEmpty
                        ? _buildEmptyDoctorsCard()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _linkedDoctors.length,
                            itemBuilder: (context, index) => _buildDoctorCard(_linkedDoctors[index]),
                          ),
                      
                      const SizedBox(height: 32),
                      
                      // Upcoming Appointments Section
                      _buildSectionHeader('Upcoming Appointments'),
                      
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
              const Text(
                'Quick Actions',
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
                  title: 'Book\nAppointment',
                  color: const Color(0xFF4A90E2),
                  onTap: () => _showBookAppointmentBottomSheet(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat,
                  title: 'Quick\nChat',
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
          const Text(
            'No Doctors Linked',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t linked with any doctors yet. Visit your profile to send connection requests to healthcare professionals.',
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
                      const SnackBar(
                        content: Text('Go to Profile → Settings → Link with Doctors'),
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
                  label: const Text(
                    'Link Doctors',
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
                  label: const Text(
                    'Refresh',
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
          const Text(
            'No Upcoming Appointments',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Schedule an appointment with your doctor',
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



  void _showBookAppointmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookAppointmentBottomSheet(
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
        const SnackBar(
          content: Text('Please link with a doctor first to start chatting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Quick Chat',
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a doctor to start chatting:',
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9575CD)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              NavigationHandler.navigateToScreen(context, 4); // Navigate to AI Chat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
            label: const Text(
              'AI Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookAppointmentBottomSheet(
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

// Book Appointment Bottom Sheet
class _BookAppointmentBottomSheet extends StatefulWidget {
  final List<Doctor> linkedDoctors;
  final Doctor? selectedDoctor;
  final VoidCallback onAppointmentBooked;

  const _BookAppointmentBottomSheet({
    required this.linkedDoctors,
    this.selectedDoctor,
    required this.onAppointmentBooked,
  });

  @override
  State<_BookAppointmentBottomSheet> createState() => _BookAppointmentBottomSheetState();
}

class _BookAppointmentBottomSheetState extends State<_BookAppointmentBottomSheet> {
  final AppointmentService _appointmentService = AppointmentService();
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _reason = '';
  String _notes = '';
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.selectedDoctor;
  }

  @override  
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Selection
                  const Text(
                    'Select Doctor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Doctor>(
                    value: _selectedDoctor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: widget.linkedDoctors.map((doctor) {
                      return DropdownMenuItem(
                        value: doctor,
                        child: Text(doctor.name),
                      );
                    }).toList(),
                    onChanged: (doctor) {
                      setState(() {
                        _selectedDoctor = doctor;
                        _selectedDate = null;
                        _selectedTimeSlot = null;
                        _availableTimeSlots = [];
                      });
                    },
                    hint: const Text('Choose your doctor'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date Selection
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectedDoctor != null ? _selectDate : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Choose appointment date',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time Slot Selection
                  if (_availableTimeSlots.isNotEmpty) ...[
                    const Text(
                      'Select Time',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimeSlots.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Reason
                  const Text(
                    'Reason for Visit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'e.g., Regular checkup, Consultation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _reason = value,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notes
                  const Text(
                    'Additional Notes (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Any specific concerns or information',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _notes = value,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Book Appointment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 90));

    final date = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTimeSlot = null;
      });
      await _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;

    try {
      final slots = await _appointmentService.getAvailableTimeSlots(
        doctorId: _selectedDoctor!.id.toString(),
        date: _selectedDate!,
      );
      setState(() {
        _availableTimeSlots = slots;
      });
    } catch (e) {
      print('Error loading time slots: $e');
    }
  }

  bool _canBookAppointment() {
    return _selectedDoctor != null &&
           _selectedDate != null &&
           _selectedTimeSlot != null &&
           _reason.isNotEmpty &&
           !_isLoading;
  }

  Future<void> _bookAppointment() async {
    if (!_canBookAppointment()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final success = await _appointmentService.bookAppointment(
        patientId: userId,
        doctorId: _selectedDoctor!.id.toString(),
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        reason: _reason,
        notes: _notes,
      );

      if (success) {
        widget.onAppointmentBooked();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
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

  // Create standardized conversation ID for doctor-patient pair
  String _createConversationId(String patientId, Doctor doctor) {
    // Known doctor Firebase UID mappings (workaround for backend issue)
    final Map<String, String> doctorEmailToFirebaseUid = {
      'tanu@gmail.com': '0AludVmmD2OXGCn1i3M5UElBMSG2',
      'clerin@gmail.com': 'clerin_firebase_uid_placeholder', // Add other doctors as needed
      // Add more mappings as needed
    };
    
    String doctorId;
    
    // PRIORITY 1: Try the mapping for known doctors first (since firebaseUid field isn't populated)
    if (doctorEmailToFirebaseUid.containsKey(doctor.email)) {
      doctorId = doctorEmailToFirebaseUid[doctor.email]!;
      print('🔍 Using mapped Firebase UID for ${doctor.email}: $doctorId');
    } 
    // PRIORITY 2: Use the Firebase UID if available and not empty
    else if (doctor.firebaseUid != null && doctor.firebaseUid!.isNotEmpty) {
      doctorId = doctor.firebaseUid!;
      print('🔍 Using doctor Firebase UID: $doctorId');
    } 
    // PRIORITY 3: Fallback to sanitized email
    else {
      doctorId = doctor.email
          .replaceAll('.', '_DOT_')
          .replaceAll('@', '_AT_')
          .replaceAll('#', '_HASH_')
          .replaceAll('\$', '_DOLLAR_')
          .replaceAll('[', '_LBRACKET_')
          .replaceAll(']', '_RBRACKET_');
      print('🔍 Using sanitized email as doctorId: $doctorId');
    }
    
    // Always use format: doctorId_patientId for consistency
    final conversationId = '${doctorId}_$patientId';
    print('🔍 Generated conversation ID: $conversationId');
    print('🔍 Doctor: ${doctor.name} (${doctor.email})');
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
      
      // Update conversation metadata to help doctor-side find this conversation
      final conversationMeta = {
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'patientId': patientId,
        'doctorId': doctor.firebaseUid ?? doctor.email,
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
                            'Start a conversation with\nDr. ${widget.doctor.name}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your messages are secure and private',
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
                        hintText: 'Type your message...',
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
      child: Row(
        mainAxisAlignment: isDoctor ? MainAxisAlignment.start : MainAxisAlignment.end,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDoctor 
                    ? Colors.grey[200] 
                    : const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(20),
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
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
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
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
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
