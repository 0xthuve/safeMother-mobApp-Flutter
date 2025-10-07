import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/appointment.dart';
import '../../models/patient.dart';
import '../../models/doctor.dart';

class DoctorAppointments extends StatefulWidget {
  const DoctorAppointments({super.key});

  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> {
  final int _currentIndex = 2;
  List<Appointment> _appointments = [];
  List<Patient> _patients = [];
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    // Inject demo data (no database calls for the demo)
    final now = DateTime.now();
    _patients = [
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

    _doctors = [
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
    ];

    _appointments = [
      Appointment(
        id: 101,
        doctorId: 1,
        patientId: 1001,
        appointmentDate: now,
        timeSlot: '09:00 AM - 09:30 AM',
        status: 'scheduled',
        reason: 'Routine prenatal checkup',
        notes: 'Monitor iron levels',
        prescription: '',
        createdAt: now,
        updatedAt: now,
      ),
      Appointment(
        id: 102,
        doctorId: 1,
        patientId: 1002,
        appointmentDate: now.add(const Duration(hours: 1)),
        timeSlot: '10:00 AM - 10:30 AM',
        status: 'rescheduled',
        reason: 'Ultrasound review',
        notes: 'New scan results to discuss',
        prescription: '',
        createdAt: now,
        updatedAt: now,
      ),
      Appointment(
        id: 103,
        doctorId: 1,
        patientId: 1002,
        appointmentDate: now.subtract(const Duration(days: 1)),
        timeSlot: '01:00 PM - 01:30 PM',
        status: 'completed',
        reason: 'Diet consultation',
        notes: 'Provided nutrition plan',
        prescription: 'Prenatal vitamins',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  List<Appointment> get _filteredAppointments {
    if (_selectedFilter == 'all') return _appointments;
    return _appointments.where((apt) => apt.status == _selectedFilter).toList();
  }

  Patient? _getPatientById(int patientId) {
    try {
      return _patients.firstWhere((p) => p.id == patientId);
    } catch (e) {
      return null;
    }
  }

  Doctor? _getDoctorById(int doctorId) {
    try {
      return _doctors.firstWhere((d) => d.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2563EB),
                const Color(0xFF1D4ED8),
                const Color(0xFF1E40AF),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              onPressed: () {
                _showAddAppointmentDialog();
              },
            ),
          ),
        ],
      ),
      body: Column(
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
                      _buildStatCard('Pending', _appointments.where((a) => a.status == 'scheduled').length.toString(), const Color(0xFFF59E0B)),
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
    final doctor = _getDoctorById(appointment.doctorId);
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
                              doctor?.name ?? 'Unknown Doctor',
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
    final doctor = _getDoctorById(appointment.doctorId);
    
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
              _buildDetailRow('Doctor', doctor?.name ?? 'Unknown'),
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
              onTap: () => _updateStatus(appointment, 'scheduled'),
            ),
            ListTile(
              title: const Text('Completed'),
              onTap: () => _updateStatus(appointment, 'completed'),
            ),
            ListTile(
              title: const Text('Cancelled'),
              onTap: () => _updateStatus(appointment, 'cancelled'),
            ),
            ListTile(
              title: const Text('Rescheduled'),
              onTap: () => _updateStatus(appointment, 'rescheduled'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(Appointment appointment, String newStatus) {
    Navigator.pop(context);
    // Demo-only: update local list
    setState(() {
      final idx = _appointments.indexWhere((a) => a.id == appointment.id);
      if (idx != -1) {
        _appointments[idx] = _appointments[idx].copyWith(status: newStatus);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment status updated to $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

