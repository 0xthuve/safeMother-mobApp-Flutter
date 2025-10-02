import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../services/route_guard.dart';
import '../../services/user_management_service.dart';
import '../../services/session_manager.dart';


class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final int _currentIndex = 0;
  Doctor? _currentDoctor;
  List<Appointment> _todayAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get actual logged-in user data
      final userData = await UserManagementService.getCurrentUserData();
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      
      final now = DateTime.now();
      
      if (userData != null) {
        // Create doctor object from real user data
        final doctorData = Doctor(
          id: (userData['id'] as int?) ?? 1,
          name: userName ?? userData['fullName'] ?? 'Dr. User',
          email: userEmail ?? userData['email'] ?? '',
          phone: userData['phone'] ?? userData['contact'] ?? '',
          specialization: userData['specialization'] ?? 'General Medicine',
          licenseNumber: userData['licenseNumber'] ?? 'Not specified',
          hospital: userData['hospital'] ?? 'Not specified',
          experience: userData['experience']?.toString() ?? '0 years',
          bio: userData['bio'] ?? 'Healthcare professional dedicated to patient care.',
          rating: (userData['rating'] as num?)?.toDouble() ?? 4.5,
          totalPatients: (userData['totalPatients'] as int?) ?? (userData['reviewCount'] as int?) ?? 0,
          isAvailable: userData['isAvailable'] ?? true,
          createdAt: now,
          updatedAt: now,
        );

        // Demo appointments for now - in a real app, these would come from a database
        final demoAppointments = <Appointment>[
          Appointment(
            id: 101,
            doctorId: doctorData.id ?? 1,
            patientId: 1001,
            appointmentDate: now,
            timeSlot: '09:00 AM - 09:30 AM',
            status: 'scheduled',
            reason: 'Routine prenatal checkup',
            notes: '',
            prescription: '',
            createdAt: now,
            updatedAt: now,
          ),
          Appointment(
            id: 102,
            doctorId: doctorData.id ?? 1,
            patientId: 1002,
            appointmentDate: now,
            timeSlot: '10:00 AM - 10:30 AM',
            status: 'scheduled',
            reason: 'Ultrasound review',
            notes: '',
            prescription: '',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        setState(() {
          _currentDoctor = doctorData;
          _todayAppointments = demoAppointments;
          _isLoading = false;
        });
      } else {
        // Fallback to demo data if user data is not available
        final demoDoctor = Doctor(
          id: 1,
          name: userName ?? 'Dr. User',
          email: userEmail ?? 'doctor@safemother.com',
          phone: '',
          specialization: 'General Medicine',
          licenseNumber: 'Demo Mode',
          hospital: 'Demo Hospital',
          experience: 'Demo Mode',
          bio: 'Demo healthcare professional.',
          rating: 4.5,
          totalPatients: 0,
          isAvailable: true,
          createdAt: now,
          updatedAt: now,
        );

        setState(() {
          _currentDoctor = demoDoctor;
          _todayAppointments = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Fallback to basic data
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final now = DateTime.now();
      
      final fallbackDoctor = Doctor(
        id: 1,
        name: userName ?? 'Dr. User',
        email: userEmail ?? 'doctor@safemother.com',
        phone: '',
        specialization: 'General Medicine',
        licenseNumber: 'Not available',
        hospital: 'Not available',
        experience: 'Not available',
        bio: 'Healthcare professional.',
        rating: 4.5,
        totalPatients: 0,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      );

      setState(() {
        _currentDoctor = fallbackDoctor;
        _todayAppointments = [];
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return RouteGuard.doctorRouteGuard(
      context: context,
      child: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2), // Blue theme
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF1E88E5)], // Blue gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentDoctor?.name ?? 'Dr. User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentDoctor?.specialization ?? 'Specialist',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today\'s Appointments',
                          _todayAppointments.length.toString(),
                          Icons.calendar_today,
                          const Color(0xFF1976D2), // Blue theme
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Patients',
                          _currentDoctor?.totalPatients.toString() ?? '0',
                          Icons.people,
                          const Color(0xFF1E88E5), // Lighter blue
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Rating',
                          _currentDoctor?.rating.toString() ?? '0.0',
                          Icons.star,
                          const Color(0xFF42A5F5), // Medium blue
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Available',
                          _currentDoctor?.isAvailable == true ? 'Yes' : 'No',
                          Icons.check_circle,
                          const Color(0xFF64B5F6), // Light blue
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Today's Appointments
                  const Text(
                    'Today\'s Appointments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_todayAppointments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: Text(
                          'No appointments scheduled for today',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._todayAppointments.map((appointment) => _buildAppointmentCard(appointment)),

                  const SizedBox(height: 24),

                  // Alerts Section
                  const Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAlertCard(
                    'Sophia Carter',
                    'High blood pressure detected',
                    Icons.warning,
                    Colors.red,
                    'Now',
                  ),
                  const SizedBox(height: 8),
                  _buildAlertCard(
                    'Olivia Bennett',
                    'Missed appointment',
                    Icons.calendar_today,
                    Colors.orange,
                    'Yesterday',
                  ),
                  const SizedBox(height: 8),
                  _buildAlertCard(
                    'Emma Hayes',
                    'Lab results ready for review',
                    Icons.science,
                    Colors.blue,
                    '2 hours ago',
                  ),
                ],
              ),
            ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
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
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1), // Blue theme
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF1976D2), // Blue theme
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.timeSlot,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient ID: ${appointment.patientId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.reason.isNotEmpty ? appointment.reason : 'No reason specified',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
    );
  }



  Widget _buildAlertCard(String patientName, String message, IconData icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
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
}

