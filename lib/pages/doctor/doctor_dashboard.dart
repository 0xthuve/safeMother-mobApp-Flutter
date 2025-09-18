import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
// NOTE: Demo data only. No database calls are used on this screen for the demo.
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _currentIndex = 0;
  Doctor? _currentDoctor;
  List<Appointment> _todayAppointments = [];
  List<Patient> _recentPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Inject demo values
    final now = DateTime.now();
    final demoDoctor = Doctor(
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
    );

    final demoAppointments = <Appointment>[
      Appointment(
        id: 101,
        doctorId: 1,
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
        doctorId: 1,
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

    final demoPatients = <Patient>[
      Patient(
        id: 1001,
        name: 'Emily Clark',
        email: 'emily.clark@example.com',
        phone: '+1-555-2001',
        dateOfBirth: DateTime(1995, 6, 12),
        bloodType: 'O+',
        emergencyContact: 'John Clark',
        emergencyPhone: '+1-555-3001',
        medicalHistory: 'Anemia',
        allergies: 'Penicillin',
        currentMedications: 'Prenatal vitamins',
        lastVisit: now.subtract(const Duration(days: 14)),
        assignedDoctorId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Patient(
        id: 1002,
        name: 'Sophia Martinez',
        email: 'sophia.martinez@example.com',
        phone: '+1-555-2002',
        dateOfBirth: DateTime(1992, 3, 24),
        bloodType: 'A-',
        emergencyContact: 'Carlos Martinez',
        emergencyPhone: '+1-555-3002',
        medicalHistory: 'Hypothyroidism',
        allergies: '',
        currentMedications: 'Levothyroxine',
        lastVisit: now.subtract(const Duration(days: 7)),
        assignedDoctorId: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setState(() {
      _currentDoctor = demoDoctor;
      _todayAppointments = demoAppointments;
      _recentPatients = demoPatients;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
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
                        colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
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
                          const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Patients',
                          _currentDoctor?.totalPatients.toString() ?? '0',
                          Icons.people,
                          const Color(0xFF2196F3),
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
                          const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Available',
                          _currentDoctor?.isAvailable == true ? 'Yes' : 'No',
                          Icons.check_circle,
                          const Color(0xFF9C27B0),
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

                  // Recent Patients
                  const Text(
                    'Recent Patients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_recentPatients.isEmpty)
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
                          'No patients yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentPatients.map((patient) => _buildPatientCard(patient)),
                ],
              ),
            ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
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
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFFE91E63),
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

  Widget _buildPatientCard(Patient patient) {
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
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
            child: Text(
              patient.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Blood Type: ${patient.bloodType}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // Navigate to patient details
            },
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

