import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../models/patient_doctor_link.dart';
import '../../services/route_guard.dart';
import '../../services/user_management_service.dart';
import '../../services/session_manager.dart';
import '../../services/backend_service.dart';
import '../../services/firebase_service.dart';
import '../../models/doctor_alert.dart';
import '../patient_requests_page.dart';


class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final int _currentIndex = 0;
  final BackendService _backendService = BackendService();
  Doctor? _currentDoctor;
  List<Appointment> _todayAppointments = [];
  List<PatientDoctorLink> _pendingRequests = [];
  List<PatientDoctorLink> _acceptedPatients = [];
  int _totalPatientsCount = 0;
  List<Map<String, dynamic>> _recentPrescriptions = [];
  List<DoctorAlert> _recentAlerts = [];
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
      final userId = await SessionManager.getUserId();
      
      final now = DateTime.now();
      
      // Load pending patient requests, accepted patients, and total patient count
      List<PatientDoctorLink> pendingRequests = [];
      List<PatientDoctorLink> acceptedPatients = [];
      int totalPatientsCount = 0;
      if (userId != null) {
        try {
          // Use the Firebase UID directly (no hash conversion needed)
          // ...existing code...
          
          pendingRequests = await _backendService.getPatientRequestsForDoctor(userId);
          acceptedPatients = await _backendService.getAcceptedPatientsForDoctor(userId);
          totalPatientsCount = await _backendService.getTotalPatientCount();
          
          // Load recent prescriptions made by this doctor
          _recentPrescriptions = await _loadRecentPrescriptions(userId);
          
          // Load recent high-risk alerts
          print('🔍 Doctor Dashboard: Loading alerts for doctor ID: $userId');
          _recentAlerts = await _backendService.getDoctorAlerts(userId);
          print('🔍 Doctor Dashboard: Loaded ${_recentAlerts.length} alerts');
        } catch (e) {
          // ...existing code...
        }
      }
      
      if (userData != null) {
        // Create doctor object from real user data
        final doctorData = Doctor(
          id: (userData['id'] as String?) ?? '1',
          name: userName ?? userData['fullName'] ?? 'Dr. User',
          email: userEmail ?? userData['email'] ?? '',
          phone: userData['phone'] ?? userData['contact'] ?? '',
          specialization: userData['specialization'] ?? 'General Medicine',
          licenseNumber: userData['licenseNumber'] ?? 'Not specified',
          hospital: userData['hospital'] ?? 'Not specified',
          experience: userData['experience']?.toString() ?? '0 years',
          bio: userData['bio'] ?? 'Healthcare professional dedicated to patient care.',
          rating: (userData['rating'] as num?)?.toDouble() ?? 4.5,
          totalPatients: acceptedPatients.length, // Use actual accepted patients count
          isAvailable: userData['isAvailable'] ?? true,
          createdAt: now,
          updatedAt: now,
        );

        // No hardcoded appointments - use real appointment data only
        final List<Appointment> realAppointments = [];
  // ...existing code...
        // For now, keeping empty to show only real data

        setState(() {
          _currentDoctor = doctorData;
          _todayAppointments = realAppointments;
          _pendingRequests = pendingRequests;
          _acceptedPatients = acceptedPatients;
          _totalPatientsCount = totalPatientsCount;
          _isLoading = false;
        });
      } else {
        // Fallback to demo data if user data is not available
        final demoDoctor = Doctor(
          id: '1',
          name: userName ?? 'Dr. User',
          email: userEmail ?? 'doctor@safemother.com',
          phone: '',
          specialization: 'General Medicine',
          licenseNumber: 'Demo Mode',
          hospital: 'Demo Hospital',
          experience: 'Demo Mode',
          bio: 'Demo healthcare professional.',
          rating: 4.5,
          totalPatients: acceptedPatients.length, // Use actual accepted patients count
          isAvailable: true,
          createdAt: now,
          updatedAt: now,
        );

        setState(() {
          _currentDoctor = demoDoctor;
          _todayAppointments = []; // No hardcoded appointments
          _pendingRequests = pendingRequests;
          _acceptedPatients = acceptedPatients;
          _totalPatientsCount = totalPatientsCount;
          _isLoading = false;
        });
      }
    } catch (e) {
  // ...existing code...
      // Fallback to basic data
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final now = DateTime.now();
      
      final fallbackDoctor = Doctor(
        id: '1',
        name: userName ?? 'Dr. User',
        email: userEmail ?? 'doctor@safemother.com',
        phone: '',
        specialization: 'General Medicine',
        licenseNumber: 'Not available',
        hospital: 'Not available',
        experience: 'Not available',
        bio: 'Healthcare professional.',
        rating: 4.5,
        totalPatients: 0, // Will be 0 in error case anyway
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      );

      setState(() {
        _currentDoctor = fallbackDoctor;
        _todayAppointments = [];
        _pendingRequests = [];
        _acceptedPatients = [];
        _totalPatientsCount = 0; // Will be 0 in error case anyway
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadRecentPrescriptions(String doctorId) async {
    try {
      List<Map<String, dynamic>> prescriptions = [];
      
      // Method 1: Get prescriptions from accepted patients
      for (final patient in _acceptedPatients) {
        try {
          final recommendations = await _backendService.getDoctorRecommendations(patient.patientId);
          if (recommendations != null && recommendations['doctorId'] == doctorId) {
            final patientData = await FirebaseService.getUserData(patient.patientId);
            
            prescriptions.add({
              'patientId': patient.patientId,
              'patientName': patientData?['fullName'] ?? 'Unknown Patient',
              'recommendations': recommendations,
              'prescribedAt': recommendations['prescribedAt'] ?? recommendations['createdAt']?.toString(),
            });
          }
        } catch (e) {
          print('Error loading prescription for patient ${patient.patientId}: $e');
        }
      }
      
      // Method 2: Also check Firebase directly for any prescriptions made by this doctor
      // This helps catch prescriptions that might not show up through the patient relationship
      try {
        final allDoctorPrescriptions = await FirebaseService.getDoctorPrescriptionsByDoctorId(doctorId);
        for (final prescription in allDoctorPrescriptions) {
          // Check if we already have this prescription from Method 1
          final existingIndex = prescriptions.indexWhere((p) => 
            p['patientId'] == prescription['patientId'] && 
            p['prescribedAt'] == prescription['prescribedAt']);
          
          if (existingIndex == -1) {
            // This is a new prescription not found in Method 1
            try {
              final patientData = await FirebaseService.getUserData(prescription['patientId']);
              prescriptions.add({
                'patientId': prescription['patientId'],
                'patientName': patientData?['fullName'] ?? 'Unknown Patient',
                'recommendations': prescription,
                'prescribedAt': prescription['prescribedAt'] ?? prescription['createdAt']?.toString(),
              });
            } catch (e) {
              print('Error loading patient data for ${prescription['patientId']}: $e');
              // Add prescription without patient name
              prescriptions.add({
                'patientId': prescription['patientId'],
                'patientName': 'Unknown Patient',
                'recommendations': prescription,
                'prescribedAt': prescription['prescribedAt'] ?? prescription['createdAt']?.toString(),
              });
            }
          }
        }
      } catch (e) {
        print('Error loading doctor prescriptions directly: $e');
        // Continue with Method 1 results only
      }
      
      // Sort by prescription date (most recent first)
      prescriptions.sort((a, b) {
        final dateA = a['prescribedAt'] as String?;
        final dateB = b['prescribedAt'] as String?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
      
      return prescriptions.take(5).toList(); // Return only the 5 most recent
    } catch (e) {
      print('Error loading recent prescriptions: $e');
      return [];
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
        body: Stack(
          children: [
            // Soft gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFF8F6F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            
            // Decorative shapes
            Positioned(
              top: 120,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFBBDEFB).withOpacity(0.4),
                ),
              ),
            ),
            
            Positioned(
              top: -60,
              right: -40,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: const Color(0xFF90CAF9).withOpacity(0.3),
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // Custom header with refresh and notification buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Doctor Portal',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue[100]!.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Color(0xFF1976D2),
                                  size: 20,
                                ),
                                onPressed: () {
                                  _loadDashboardData();
                                },
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue[100]!.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF1976D2),
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Handle notifications
                                },
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Scrollable content
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                          ))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF90CAF9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE3F2FD).withOpacity(0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue[100]!,
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _currentDoctor?.name ?? 'Dr. User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _currentDoctor?.specialization ?? 'Specialist',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 32,
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
                          Icons.calendar_today_rounded,
                          const Color(0xFF1976D2), // Blue theme
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Patients',
                          _totalPatientsCount.toString(),
                          Icons.people_rounded,
                          const Color(0xFF42A5F5), // Light blue
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to doctor patient management page (My Patients tab)
                            DoctorNavigationHandler.navigateToPatientManagement(context, initialTab: 0);
                          },
                          child: _buildStatCard(
                            'My Patients',
                            _acceptedPatients.length.toString(),
                            Icons.medical_services_rounded,
                            const Color(0xFF5C6BC0), // Indigo blue
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to doctor patient management page (Requests tab)
                            DoctorNavigationHandler.navigateToPatientManagement(context, initialTab: 1);
                          },
                          child: _buildStatCard(
                            'Pending Requests',
                            _pendingRequests.length.toString(),
                            Icons.pending_actions_rounded,
                            const Color(0xFF26A69A), // Teal blue
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // High-Risk Alerts Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red.shade600.withOpacity(0.15),
                              Colors.red.shade600.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade600.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'High-Risk Patient Alerts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Alerts Cards
                  _buildAlertsSection(),

                  const SizedBox(height: 24),

                  // Today's Appointments
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1976D2).withOpacity(0.15),
                              const Color(0xFF1976D2).withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF1976D2),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Today\'s Appointments',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_todayAppointments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF3B82F6),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No appointments today',
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your schedule is clear for today',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._todayAppointments.map((appointment) => _buildAppointmentCard(appointment)),

                  const SizedBox(height: 24),

                  // Patient Requests Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF26A69A).withOpacity(0.15),
                                  const Color(0xFF26A69A).withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF26A69A).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.pending_actions_rounded,
                              color: Color(0xFF26A69A),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Patient Requests',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      if (_pendingRequests.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PatientRequestsPage(),
                              ),
                            );
                            // Refresh dashboard data when returning
                            if (result == true || result == null) {
                              _loadDashboardData();
                            }
                          },
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_pendingRequests.isEmpty)
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
                          'No pending patient requests',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...(_pendingRequests.take(3).map((request) => _buildPatientRequestCard(request))),

                  const SizedBox(height: 24),

                  // Recent Prescriptions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Prescriptions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      if (_recentPrescriptions.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            // Navigate to doctor patient management page (My Patients tab)
                            DoctorNavigationHandler.navigateToPatientManagement(context, initialTab: 0);
                          },
                          child: const Text('View All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_recentPrescriptions.isEmpty)
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
                          'No recent prescriptions',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentPrescriptions.map((prescription) => _buildPrescriptionCard(prescription)),

                  const SizedBox(height: 24),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon, 
              color: color, 
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1976D2),
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5E7489),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFF1976D2).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1976D2).withOpacity(0.15),
                  const Color(0xFF1976D2).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF1976D2),
              size: 24,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1976D2),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Patient ID: ${appointment.patientId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5E7489),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.reason.isNotEmpty ? appointment.reason : 'No reason specified',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B9DC3),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(appointment.status).withOpacity(0.15),
                  _getStatusColor(appointment.status).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(appointment.status).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              appointment.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _getStatusColor(appointment.status),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildPatientRequestCard(PatientDoctorLink request) {
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
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient ID: ${request.patientId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested: ${_formatDateTime(request.createdAt)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PENDING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final recommendations = prescription['recommendations'] as Map<String, dynamic>;
    final meals = recommendations['meals'] as List<dynamic>? ?? [];
    final exercises = recommendations['exercises'] as List<dynamic>? ?? [];
    final mealPlan = recommendations['mealPlan'] as String?;
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescription['patientName'] ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient ID: ${prescription['patientId']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PRESCRIBED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (mealPlan != null) ...[
            Row(
              children: [
                const Icon(Icons.restaurant, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  'Meal Plan: $mealPlan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (meals.isNotEmpty) ...[
                const Icon(Icons.restaurant_menu, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '${meals.length} meal${meals.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
                const SizedBox(width: 16),
              ],
              if (exercises.isNotEmpty) ...[
                const Icon(Icons.fitness_center, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '${exercises.length} exercise${exercises.length == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ],
          ),
          if (prescription['prescribedAt'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Prescribed: ${_formatPrescriptionDate(prescription['prescribedAt'])}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrescriptionDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    
    try {
      DateTime date;
      if (dateString.contains('T')) {
        date = DateTime.parse(dateString);
      } else {
        // Handle Timestamp string format
        date = DateTime.now(); // Fallback
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
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

  Widget _buildAlertsSection() {
    if (_recentAlerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              'No High-Risk Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your patients are currently in stable condition.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentAlerts.take(3).map((alert) => _buildAlertCard(alert)).toList(),
    );
  }

  Widget _buildAlertCard(DoctorAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAlertBorderColor(alert.riskLevel),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getAlertBorderColor(alert.riskLevel).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with patient name and risk level
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAlertBorderColor(alert.riskLevel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.riskLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert.patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
              Text(
                _formatAlertTime(alert.alertDate),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Risk message
          Text(
            alert.riskMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          
          if (alert.bloodPressure.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  size: 16,
                  color: Colors.red.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'BP: ${alert.bloodPressure}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAlertDetails(alert),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _markAlertAsRead(alert),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Mark Read'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAlertBorderColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high risk':
        return Colors.red.shade600;
      case 'moderate risk':
        return Colors.orange.shade600;
      case 'low risk':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatAlertTime(DateTime alertDate) {
    final now = DateTime.now();
    final difference = now.difference(alertDate);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showAlertDetails(DoctorAlert alert) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getAlertBorderColor(alert.riskLevel).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: _getAlertBorderColor(alert.riskLevel),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Patient Alert Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getAlertBorderColor(alert.riskLevel),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Patient', alert.patientName),
                _buildDetailRow('Risk Level', alert.riskLevel),
                _buildDetailRow('Date', _formatFullDate(alert.alertDate)),
                if (alert.bloodPressure.isNotEmpty)
                  _buildDetailRow('Blood Pressure', alert.bloodPressure),
                const SizedBox(height: 16),
                const Text(
                  'Assessment:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  alert.riskMessage,
                  style: const TextStyle(fontSize: 14),
                ),
                if (alert.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Symptoms:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...alert.symptoms.map((symptom) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            symptom,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                if (alert.riskFactors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Risk Factors:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...alert.riskFactors.map((factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            factor,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAlertAsRead(alert);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Read'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _markAlertAsRead(DoctorAlert alert) async {
    try {
      if (alert.id != null) {
        final success = await _backendService.markAlertAsRead(alert.id!);
        if (success) {
          setState(() {
            _recentAlerts.removeWhere((a) => a.id == alert.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert marked as read'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating alert: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

