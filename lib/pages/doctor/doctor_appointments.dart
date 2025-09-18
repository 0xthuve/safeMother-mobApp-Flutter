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
  int _currentIndex = 2;
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
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showAddAppointmentDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Scheduled', 'scheduled'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rescheduled', 'rescheduled'),
                ],
              ),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final patient = _getPatientById(appointment.patientId);
    final doctor = _getDoctorById(appointment.doctorId);
    
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
                  color: _getStatusColor(appointment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: _getStatusColor(appointment.status),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient?.name ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor?.name ?? 'Unknown Doctor',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(appointment.appointmentDate)} at ${appointment.timeSlot}',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewAppointmentDetails(appointment),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE91E63),
                    side: const BorderSide(color: Color(0xFFE91E63)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateAppointmentStatus(appointment),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
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

