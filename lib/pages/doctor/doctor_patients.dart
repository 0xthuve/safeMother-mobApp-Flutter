import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/patient.dart';

class DoctorPatients extends StatefulWidget {
  const DoctorPatients({super.key});

  @override
  State<DoctorPatients> createState() => _DoctorPatientsState();
}

class _DoctorPatientsState extends State<DoctorPatients> {
  int _currentIndex = 1;
  List<Patient> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    // Inject demo patients (no database calls for the demo)
    final now = DateTime.now();
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
      Patient(
        id: 1003,
        name: 'Ava Thompson',
        email: 'ava.thompson@example.com',
        phone: '+1-555-2003',
        dateOfBirth: DateTime(1990, 11, 2),
        bloodType: 'B+',
        emergencyContact: 'Liam Thompson',
        emergencyPhone: '+1-555-3003',
        medicalHistory: 'None',
        allergies: 'None',
        currentMedications: 'Prenatal vitamins',
        lastVisit: now.subtract(const Duration(days: 3)),
        assignedDoctorId: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setState(() {
      _patients = demoPatients;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients.where((patient) {
      return patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             patient.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        title: const Text(
          'My Patients',
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
              _showAddPatientDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFE91E63)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Patients List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? const Center(
                        child: Text(
                          'No patients found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _buildPatientCard(patient);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
                child: Text(
                  patient.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
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
                        fontSize: 18,
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
                      patient.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _viewPatientDetails(patient);
                      break;
                    case 'edit':
                      _editPatient(patient);
                      break;
                    case 'delete':
                      _deletePatient(patient);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: Color(0xFFE91E63)),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Color(0xFF2196F3)),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('Blood Type', patient.bloodType, const Color(0xFFE91E63)),
              const SizedBox(width: 8),
              _buildInfoChip('Age', _calculateAge(patient.dateOfBirth).toString(), const Color(0xFF2196F3)),
            ],
          ),
          if (patient.allergies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Allergies: ${patient.allergies}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Patient'),
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

  void _viewPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', patient.email),
              _buildDetailRow('Phone', patient.phone),
              _buildDetailRow('Blood Type', patient.bloodType),
              _buildDetailRow('Age', _calculateAge(patient.dateOfBirth).toString()),
              _buildDetailRow('Emergency Contact', patient.emergencyContact),
              _buildDetailRow('Emergency Phone', patient.emergencyPhone),
              if (patient.allergies.isNotEmpty)
                _buildDetailRow('Allergies', patient.allergies),
              if (patient.medicalHistory.isNotEmpty)
                _buildDetailRow('Medical History', patient.medicalHistory),
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
            width: 120,
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

  void _editPatient(Patient patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit patient feature will be implemented in the next phase'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deletePatient(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Demo-only: remove from local list
              setState(() {
                _patients.removeWhere((p) => p.id == patient.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patient deleted (demo)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

