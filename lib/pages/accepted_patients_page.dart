import 'package:flutter/material.dart';
import '../models/patient_doctor_link.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../services/firebase_service.dart';

class AcceptedPatientsPage extends StatefulWidget {
  const AcceptedPatientsPage({super.key});

  @override
  State<AcceptedPatientsPage> createState() => _AcceptedPatientsPageState();
}

class _AcceptedPatientsPageState extends State<AcceptedPatientsPage> {
  final BackendService _backendService = BackendService();
  List<PatientDoctorLink> _acceptedPatients = [];
  Map<String, Map<String, dynamic>> _patientDetails = {};
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadAcceptedPatients();
  }

  Future<void> _loadAcceptedPatients() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Use the Firebase UID directly (no hash conversion needed)
      print('AcceptedPatientsPage: userId=$userId');

      // Get accepted patients directly from Firebase
      final acceptedPatients = await _backendService.getAcceptedPatientsForDoctor(userId);

      // Load patient details for each accepted patient
      Map<String, Map<String, dynamic>> patientDetails = {};
      for (final patient in acceptedPatients) {
        try {
          final patientData = await FirebaseService.getUserData(patient.patientId);
          if (patientData != null) {
            patientDetails[patient.patientId] = patientData;
          } else {
            // Fallback data when Firebase data is not available
            patientDetails[patient.patientId] = {
              'fullName': 'Patient ${patient.patientId.substring(0, 8)}',
              'email': 'Permission restricted',
              'contact': 'Contact via app',
              'age': 'N/A'
            };
          }
        } catch (e) {
          print('Could not load patient data for ${patient.patientId}: $e');
          // Fallback data when Firebase access is denied
          patientDetails[patient.patientId] = {
            'fullName': 'Patient ${patient.patientId.substring(0, 8)}',
            'email': 'Permission restricted',
            'contact': 'Contact via app',
            'age': 'N/A'
          };
        }
      }

      setState(() {
        _acceptedPatients = acceptedPatients;
        _patientDetails = patientDetails;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading accepted patients: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patients: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removePatient(PatientDoctorLink patient) async {
    try {
      final success = await _backendService.removePatient(patient.doctorId, patient.patientId, patient.id);
      
      if (success) {
        setState(() {
          _acceptedPatients.removeWhere((p) => p.id == patient.id);
          _patientDetails.remove(patient.patientId);
        });

        _hasChanges = true; // Mark that changes were made
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to remove patient'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error removing patient: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRemoveConfirmation(PatientDoctorLink patient) {
    final patientData = _patientDetails[patient.patientId];
    final patientName = patientData?['fullName'] ?? 'Unknown Patient';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Patient'),
          content: Text('Are you sure you want to remove $patientName from your patient list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removePatient(patient);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          title: const Text(
            'My Patients',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1976D2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(_hasChanges),
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _acceptedPatients.isEmpty
              ? _buildEmptyState()
              : _buildPatientsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Patients Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t accepted any patients yet.\nPatient requests will appear in your dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    return RefreshIndicator(
      onRefresh: _loadAcceptedPatients,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _acceptedPatients.length,
        itemBuilder: (context, index) {
          final patient = _acceptedPatients[index];
          final patientData = _patientDetails[patient.patientId];
          
          return _buildPatientCard(patient, patientData);
        },
      ),
    );
  }

  Widget _buildPatientCard(PatientDoctorLink patient, Map<String, dynamic>? patientData) {
    final patientName = patientData?['fullName'] ?? 'Unknown Patient';
    final patientEmail = patientData?['email'] ?? 'No email';
    final patientAge = patientData?['age']?.toString() ?? 'N/A';
    final patientPhone = patientData?['phone'] ?? patientData?['contact'] ?? 'No phone';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.person,
                    color: const Color(0xFF1976D2),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patientEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age: $patientAge • Phone: $patientPhone',
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Linked: ${_formatDateTime(patient.linkedDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showRemoveConfirmation(patient),
                  icon: const Icon(Icons.remove_circle_outline, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}