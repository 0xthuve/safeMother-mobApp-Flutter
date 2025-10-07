import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../services/backend_service.dart';
import '../../services/session_manager.dart';
import '../../services/firebase_service.dart';
import '../../models/patient_doctor_link.dart';


class DoctorPatientManagement extends StatefulWidget {
  final int? initialTabIndex;
  
  const DoctorPatientManagement({super.key, this.initialTabIndex});

  @override
  State<DoctorPatientManagement> createState() => _DoctorPatientManagementState();
}

class _DoctorPatientManagementState extends State<DoctorPatientManagement> {
  final int _currentIndex = 1;
  final BackendService _backendService = BackendService();
  
  List<Map<String, dynamic>> _patientsWithData = [];
  List<Map<String, dynamic>> _pendingRequestsWithData = [];
  bool _isLoadingPatients = true;
  bool _isLoadingRequests = true;
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0 for accepted patients, 1 for pending requests

  @override
  void initState() {
    super.initState();
    // Set initial tab index if provided
    _selectedTabIndex = widget.initialTabIndex ?? 0;
    _loadPatients();
    _loadPendingRequests();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoadingPatients = true;
      });

      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

  final acceptedPatients = await _backendService.getAcceptedPatientsForDoctor(userId);
      
      List<Map<String, dynamic>> patientsWithData = [];

      for (final patientLink in acceptedPatients) {
        try {
          // ...existing code...
          final patientData = await FirebaseService.getUserData(patientLink.patientId);
          if (patientData != null) {
            // Ensure safe type handling for dynamic data
            final safePatientData = <String, dynamic>{};
            patientData.forEach((key, value) {
              if (value is List) {
                // Convert List<dynamic> to List<String> safely
                safePatientData[key] = List<String>.from(value.map((item) => item.toString()));
              } else {
                safePatientData[key] = value;
              }
            });
            
            patientsWithData.add({
              'link': patientLink,
              'data': safePatientData,
            });
            // ...existing code...
          } else {
            // ...existing code...
          }
        } catch (e) {
          // ...existing code...
        }
      }

      setState(() {
        _patientsWithData = patientsWithData;
        _isLoadingPatients = false;
      });
      
  // ...existing code...
    } catch (e) {
  // ...existing code...
      setState(() {
        _patientsWithData = [];
        _isLoadingPatients = false;
      });
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      setState(() {
        _isLoadingRequests = true;
      });

      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

  final pendingRequests = await _backendService.getPatientRequestsForDoctor(userId);
      
      List<Map<String, dynamic>> requestsWithData = [];

      for (final request in pendingRequests) {
        try {
          // ...existing code...
          final patientData = await FirebaseService.getUserData(request.patientId);
          if (patientData != null) {
            // Ensure safe type handling for dynamic data
            final safePatientData = <String, dynamic>{};
            patientData.forEach((key, value) {
              if (value is List) {
                // Convert List<dynamic> to List<String> safely
                safePatientData[key] = List<String>.from(value.map((item) => item.toString()));
              } else {
                safePatientData[key] = value;
              }
            });
            
            requestsWithData.add({
              'link': request,
              'data': safePatientData,
            });
            // ...existing code...
          } else {
            // ...existing code...
          }
        } catch (e) {
          // ...existing code...
        }
      }

      setState(() {
        _pendingRequestsWithData = requestsWithData;
        _isLoadingRequests = false;
      });
      
  // ...existing code...
    } catch (e) {
  // ...existing code...
      setState(() {
        _pendingRequestsWithData = [];
        _isLoadingRequests = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patientsWithData;
    return _patientsWithData.where((patientWithData) {
      final patientData = patientWithData['data'] as Map<String, dynamic>;
      final name = patientData['fullName'] ?? '';
      final email = patientData['email'] ?? '';
      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0 ? const Color(0xFF1976D2) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            color: _selectedTabIndex == 0 ? const Color(0xFF1976D2) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'My Patients',
                            style: TextStyle(
                              color: _selectedTabIndex == 0 ? const Color(0xFF1976D2) : Colors.grey,
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1 ? const Color(0xFF1976D2) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications,
                            color: _selectedTabIndex == 1 ? const Color(0xFF1976D2) : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Requests',
                            style: TextStyle(
                              color: _selectedTabIndex == 1 ? const Color(0xFF1976D2) : Colors.grey,
                              fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (_pendingRequestsWithData.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_pendingRequestsWithData.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          if (_selectedTabIndex == 0)
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
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          
          // Content based on selected tab
          Expanded(
            child: _selectedTabIndex == 0 
                ? _buildPatientsTab()
                : _buildRequestsTab(),
          ),
        ],
      ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPatientsTab() {
    return _isLoadingPatients
        ? const Center(child: CircularProgressIndicator())
        : _filteredPatients.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPatients.length,
                itemBuilder: (context, index) {
                  final patientWithData = _filteredPatients[index];
                  return _buildPatientCard(patientWithData);
                },
              );
  }

  Widget _buildRequestsTab() {
    return _isLoadingRequests
        ? const Center(child: CircularProgressIndicator())
        : _pendingRequestsWithData.isEmpty
            ? _buildEmptyRequestsState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingRequestsWithData.length,
                itemBuilder: (context, index) {
                  final requestWithData = _pendingRequestsWithData[index];
                  return _buildRequestCard(requestWithData);
                },
              );
  }

  Widget _buildEmptyRequestsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No pending requests',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patient connection requests will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No patients yet' : 'No patients found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'Accepted patient connections will appear here' 
                : 'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patientWithData) {
    final patientLink = patientWithData['link'] as PatientDoctorLink;
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    
    final name = patientData['fullName']?.toString() ?? 'Unknown Patient';
    final email = patientData['email']?.toString() ?? 'No email';
    final phone = patientData['phone']?.toString() ?? patientData['contact']?.toString() ?? '';
    final bloodType = patientData['bloodType']?.toString() ?? '';
    
    // Handle allergies field safely - it might be a List or String
    String allergies = '';
    final allergiesData = patientData['allergies'];
    if (allergiesData != null) {
      if (allergiesData is List) {
        allergies = allergiesData.map((item) => item.toString()).join(', ');
      } else {
        allergies = allergiesData.toString();
      }
    }
    
    final lastVisit = patientLink.linkedDate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7B7B7B),
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7B7B7B),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Patient Info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (bloodType.isNotEmpty && bloodType != 'Not specified')
                  _buildInfoChip('Blood Type: $bloodType', const Color(0xFF1976D2)),
                _buildInfoChip('Linked: ${_formatDate(lastVisit)}', const Color(0xFF2196F3)),
              ],
            ),
            
            // Allergies Warning (if any)
            if (allergies.isNotEmpty && allergies != 'None') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 16, color: Color(0xFFFF9800)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Allergies: $allergies',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPatientDetails(patientWithData),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _assignMealPlan(patientWithData),
                    icon: const Icon(Icons.restaurant, size: 16),
                    label: const Text('Meal'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _assignExercise(patientWithData),
                    icon: const Icon(Icons.fitness_center, size: 16),
                    label: const Text('Exercise'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
                      side: const BorderSide(color: Color(0xFF2196F3)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPatientSymptomLogs(patientWithData),
                    icon: const Icon(Icons.health_and_safety, size: 18),
                    label: const Text('Symptoms'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF9800),
                      side: const BorderSide(color: Color(0xFFFF9800)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _chatWithPatient(patientWithData),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Emergency Contact and Unlink Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callEmergencyContact(patientWithData),
                    icon: const Icon(Icons.emergency, size: 18),
                    label: const Text('Emergency'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE91E63),
                      side: const BorderSide(color: Color(0xFFE91E63)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUnlinkPatientDialog(patientWithData),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Unlink'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewPatientDetails(Map<String, dynamic> patientWithData) {
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    final name = patientData['fullName'] ?? 'Unknown Patient';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name - Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', patientData['email']?.toString() ?? 'No email'),
              _buildDetailRow('Phone', patientData['phone']?.toString() ?? patientData['contact']?.toString() ?? 'No phone'),
              if (patientData['bloodType'] != null && patientData['bloodType'].toString().isNotEmpty)
                _buildDetailRow('Blood Type', patientData['bloodType'].toString()),
              if (patientData['allergies'] != null) ...[
                if (patientData['allergies'] is List)
                  _buildDetailRow('Allergies', (patientData['allergies'] as List).map((item) => item.toString()).join(', '))
                else if (patientData['allergies'].toString().isNotEmpty && patientData['allergies'].toString() != 'None')
                  _buildDetailRow('Allergies', patientData['allergies'].toString()),
              ],
              if (patientData['medicalHistory'] != null && patientData['medicalHistory'].toString().isNotEmpty)
                _buildDetailRow('Medical History', patientData['medicalHistory'].toString()),
              if (patientData['currentMedications'] != null) ...[
                if (patientData['currentMedications'] is List)
                  _buildDetailRow('Current Medications', (patientData['currentMedications'] as List).map((item) => item.toString()).join(', '))
                else if (patientData['currentMedications'].toString().isNotEmpty)
                  _buildDetailRow('Current Medications', patientData['currentMedications'].toString()),
              ],
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
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _chatWithPatient(Map<String, dynamic> patientWithData) {
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    final name = patientData['fullName'] ?? 'Unknown Patient';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with $name'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _viewPatientSymptomLogs(Map<String, dynamic> patientWithData) async {
    final patientLink = patientWithData['link'] as PatientDoctorLink;
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    final name = patientData['fullName'] ?? 'Unknown Patient';
    
    try {
      // Get all symptom logs for this specific patient
      final logs = await _backendService.getSymptomLogs(patientLink.patientId);
      
      if (!mounted) return;
      
      // Show symptom logs in a dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9800),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$name\'s Symptom Logs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: logs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No symptom logs found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Patient hasn\'t logged any symptoms yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF666)),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${log.logDate.day}/${log.logDate.month}/${log.logDate.year}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Vital Signs Section
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.health_and_safety, size: 16, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Vital Signs', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (log.bloodPressure.isNotEmpty)
                                            Row(
                                              children: [
                                                const Icon(Icons.favorite, size: 14, color: Colors.red),
                                                const SizedBox(width: 8),
                                                Text('Blood Pressure: ${log.bloodPressure}'),
                                              ],
                                            ),
                                          if (log.weight.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.monitor_weight, size: 14, color: Colors.blue),
                                                const SizedBox(width: 8),
                                                Text('Weight: ${log.weight}kg'),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Pregnancy Tracking
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.child_care, size: 16, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('Pregnancy Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.child_friendly, size: 14, color: Colors.green),
                                              const SizedBox(width: 8),
                                              Text('Baby Kicks: ${log.babyKicks}'),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.mood, size: 14, color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Text('Mood: ${log.mood}'),
                                            ],
                                          ),
                                          if (log.energyLevel.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.battery_charging_full, size: 14, color: Colors.amber),
                                                const SizedBox(width: 8),
                                                Text('Energy: ${log.energyLevel}'),
                                              ],
                                            ),
                                          ],
                                          if (log.appetiteLevel.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.restaurant, size: 14, color: Colors.brown),
                                                const SizedBox(width: 8),
                                                Text('Appetite: ${log.appetiteLevel}'),
                                              ],
                                            ),
                                          ],
                                          if (log.painLevel != 'None') ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.healing, size: 14, color: Colors.red),
                                                const SizedBox(width: 8),
                                                Text('Pain Level: ${log.painLevel}', 
                                                  style: TextStyle(
                                                    color: log.painLevel == 'Severe' ? Colors.red : Colors.black87,
                                                    fontWeight: log.painLevel == 'Severe' ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Daily Activities
                                    if (log.sleepHours?.isNotEmpty == true || 
                                        log.waterIntake?.isNotEmpty == true || 
                                        log.exerciseMinutes?.isNotEmpty == true) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.schedule, size: 16, color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('Daily Activities', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            if (log.sleepHours?.isNotEmpty == true)
                                              Row(
                                                children: [
                                                  const Icon(Icons.bedtime, size: 14, color: Colors.indigo),
                                                  const SizedBox(width: 8),
                                                  Text('Sleep: ${log.sleepHours} hours'),
                                                ],
                                              ),
                                            if (log.waterIntake?.isNotEmpty == true) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.local_drink, size: 14, color: Colors.blue),
                                                  const SizedBox(width: 8),
                                                  Text('Water: ${log.waterIntake} glasses'),
                                                ],
                                              ),
                                            ],
                                            if (log.exerciseMinutes?.isNotEmpty == true) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.fitness_center, size: 14, color: Colors.green),
                                                  const SizedBox(width: 8),
                                                  Text('Exercise: ${log.exerciseMinutes} minutes'),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // Health Alerts
                                    if (log.hadContractions || log.hadHeadaches || log.hadSwelling) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red[200]!),
                                        ),
                                        child: Column(
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.warning, size: 16, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Health Alerts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            if (log.hadContractions)
                                              const Row(
                                                children: [
                                                  Icon(Icons.warning, size: 14, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Had contractions today', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            if (log.hadHeadaches) ...[
                                              const SizedBox(height: 4),
                                              const Row(
                                                children: [
                                                  Icon(Icons.psychology, size: 14, color: Colors.orange),
                                                  SizedBox(width: 8),
                                                  Text('Experienced headaches'),
                                                ],
                                              ),
                                            ],
                                            if (log.hadSwelling) ...[
                                              const SizedBox(height: 4),
                                              const Row(
                                                children: [
                                                  Icon(Icons.accessibility, size: 14, color: Colors.blue),
                                                  SizedBox(width: 8),
                                                  Text('Noticed swelling'),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // Positive Health Actions
                                    if (log.tookVitamins) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text('✓ Took prenatal vitamins', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    // Medications
                                    if (log.medications?.isNotEmpty == true) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.purple[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.medication, size: 16, color: Colors.purple),
                                                SizedBox(width: 8),
                                                Text('Medications Taken', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(log.medications!),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // Nausea Details
                                    if (log.nauseaDetails?.isNotEmpty == true) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.pink[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.sick, size: 16, color: Colors.pink),
                                                SizedBox(width: 8),
                                                Text('Nausea/Vomiting', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(log.nauseaDetails!),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // Other Symptoms
                                    if (log.symptoms.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.healing, size: 16, color: Colors.orange),
                                                SizedBox(width: 8),
                                                Text('Other Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(log.symptoms),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // Additional Notes
                                    if (log.additionalNotes?.isNotEmpty == true) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(Icons.note_add, size: 16, color: Colors.grey),
                                                SizedBox(width: 8),
                                                Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(log.additionalNotes!),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                    
                                    // Timestamp
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Logged: ${log.createdAt.day}/${log.createdAt.month}/${log.createdAt.year} at ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading symptom logs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRequestCard(Map<String, dynamic> requestWithData) {
    final patientLink = requestWithData['link'] as PatientDoctorLink;
    final patientData = requestWithData['data'] as Map<String, dynamic>;
    
    final name = patientData['fullName']?.toString() ?? 'Unknown Patient';
    final email = patientData['email']?.toString() ?? 'No email';
    final phone = patientData['phone']?.toString() ?? patientData['contact']?.toString() ?? '';
    final bloodType = patientData['bloodType']?.toString() ?? '';
    
    // Handle allergies field safely - it might be a List or String
    String allergies = '';
    final allergiesData = patientData['allergies'];
    if (allergiesData != null) {
      if (allergiesData is List) {
        allergies = allergiesData.map((item) => item.toString()).join(', ');
      } else {
        allergies = allergiesData.toString();
      }
    }
    
    final requestDate = patientLink.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9800), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Request Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Patient Request',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Requested: ${_formatDate(requestDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Patient Information
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7B7B7B),
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7B7B7B),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Patient Info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (bloodType.isNotEmpty && bloodType != 'Not specified')
                  _buildInfoChip('Blood Type: $bloodType', const Color(0xFF1976D2)),
              ],
            ),
            
            // Allergies Warning (if any)
            if (allergies.isNotEmpty && allergies != 'None') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 16, color: Color(0xFFFF9800)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Allergies: $allergies',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Accept/Decline Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAcceptDeclineDialog(requestWithData, false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptDeclineDialog(requestWithData, true),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDeclineDialog(Map<String, dynamic> requestWithData, bool isAccept) {
    final patientData = requestWithData['data'] as Map<String, dynamic>;
    final patientLink = requestWithData['link'] as PatientDoctorLink;
    final name = patientData['fullName']?.toString() ?? 'Unknown Patient';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isAccept ? Icons.check_circle : Icons.cancel,
              color: isAccept ? const Color(0xFF4CAF50) : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${isAccept ? 'Accept' : 'Decline'} Patient Request',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to ${isAccept ? 'accept' : 'decline'} the patient request from:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          patientData['email']?.toString() ?? 'No email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAccept 
                  ? 'This patient will be added to your patient list and you can start providing care.'
                  : 'This request will be permanently declined and the patient will be notified.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handlePatientRequest(patientLink, isAccept);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? const Color(0xFF4CAF50) : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isAccept ? 'Accept' : 'Decline'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePatientRequest(PatientDoctorLink patientLink, bool isAccept) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      bool success;
      if (isAccept) {
        success = await _backendService.acceptPatientRequest(
          userId, 
          patientLink.patientId, 
          patientLink.id
        );
      } else {
        success = await _backendService.declinePatientRequest(
          userId, 
          patientLink.patientId, 
          patientLink.id
        );
      }

      if (success) {
        // Refresh both lists
        await _loadPendingRequests();
        if (isAccept) {
          await _loadPatients();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isAccept 
                    ? 'Patient request accepted successfully!' 
                    : 'Patient request declined successfully!',
              ),
              backgroundColor: isAccept ? const Color(0xFF4CAF50) : Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to ${isAccept ? 'accept' : 'decline'} patient request. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _assignMealPlan(Map<String, dynamic> patientWithData) {
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => _MealPlanDialog(patientData: patientData),
    );
  }

  void _assignExercise(Map<String, dynamic> patientWithData) {
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(patientData: patientData),
    );
  }

  void _callEmergencyContact(Map<String, dynamic> patientWithData) async {
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    final name = patientData['fullName']?.toString() ?? 'Unknown Patient';
    
    // Get emergency contact information from patient data
    final emergencyContactName = patientData['emergencyContactName']?.toString() ?? 
                                  patientData['emergencyContact']?.toString() ?? '';
    final emergencyContactPhone = patientData['emergencyContactPhone']?.toString() ?? 
                                  patientData['emergencyPhone']?.toString() ?? '';
    
    if (emergencyContactPhone.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: emergencyContactPhone);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.emergency, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Emergency Contact'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Emergency Contact: ${emergencyContactName.isNotEmpty ? emergencyContactName : 'Not provided'}'),
              const SizedBox(height: 4),
              Text('Phone: $emergencyContactPhone'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not make phone call')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.phone),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 214, 114, 114)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No emergency contact available for $name')),
      );
    }
  }

  void _showUnlinkPatientDialog(Map<String, dynamic> patientWithData) {
    final patientData = patientWithData['data'] as Map<String, dynamic>;
    final patientLink = patientWithData['link'] as PatientDoctorLink;
    final name = patientData['fullName']?.toString() ?? 'Unknown Patient';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.link_off, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Unlink Patient',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to unlink this patient from your care?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          patientData['email']?.toString() ?? 'No email',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The patient will be removed from your patient list and the connection will be permanently deleted.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _unlinkPatient(patientLink, name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unlink Patient'),
          ),
        ],
      ),
    );
  }

  Future<void> _unlinkPatient(PatientDoctorLink patientLink, String patientName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final userId = await SessionManager.getUserId();
      if (userId == null) {
        Navigator.pop(context); // Close loading dialog
        throw Exception('User not logged in');
      }

      // Call backend service to unlink the patient
      bool success = await _backendService.removePatient(
        userId, 
        patientLink.patientId, 
        patientLink.id
      );

      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Refresh the patients list
        await _loadPatients();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$patientName has been successfully unlinked from your care'),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to unlink patient. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while unlinking the patient. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Meal Plan Dialog
class _MealPlanDialog extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const _MealPlanDialog({required this.patientData});

  @override
  State<_MealPlanDialog> createState() => _MealPlanDialogState();
}

class _MealPlanDialogState extends State<_MealPlanDialog> {
  String selectedMealPlan = 'Balanced Nutrition';
  List<String> mealPlanOptions = [
    'Balanced Nutrition',
    'High Protein',
    'Low Sodium',
    'Diabetic Friendly',
    'High Fiber',
    'Iron Rich',
    'Calcium Rich',
    'Custom Plan'
  ];

  @override
  Widget build(BuildContext context) {
    final name = widget.patientData['fullName'] ?? 'Unknown Patient';
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Color(0xFF4CAF50), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assign Meal Plan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Patient: $name',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Meal Plan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: mealPlanOptions.length,
                itemBuilder: (context, index) {
                  final option = mealPlanOptions[index];
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedMealPlan,
                    onChanged: (value) {
                      setState(() {
                        selectedMealPlan = value!;
                      });
                    },
                    activeColor: const Color(0xFF4CAF50),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$selectedMealPlan assigned to $name'),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Assign'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Exercise Dialog
class _ExerciseDialog extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const _ExerciseDialog({required this.patientData});

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  List<String> selectedExercises = ['Light Walking'];
  List<String> exerciseOptions = [
    'Light Walking',
    'Prenatal Yoga',
    'Swimming',
    'Stationary Cycling',
    'Stretching Exercises',
    'Breathing Exercises',
    'Pelvic Floor Exercises',
    'Custom Routine'
  ];

  @override
  Widget build(BuildContext context) {
    final name = widget.patientData['fullName'] ?? 'Unknown Patient';
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Color(0xFF2196F3), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommend Exercise',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Patient: $name',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Exercise Types (Multiple Selection):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: ${selectedExercises.length} exercise${selectedExercises.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF2196F3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedExercises = List.from(exerciseOptions);
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Select All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedExercises.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: exerciseOptions.length,
                itemBuilder: (context, index) {
                  final option = exerciseOptions[index];
                  final isSelected = selectedExercises.contains(option);
                  return CheckboxListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedExercises.add(option);
                        } else {
                          selectedExercises.remove(option);
                        }
                      });
                    },
                    activeColor: const Color(0xFF2196F3),
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedExercises.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select at least one exercise'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exercise plan assigned to $name',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (selectedExercises.length > 1) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Selected: ${selectedExercises.join(', ')}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ] else
                                Text(selectedExercises.first),
                            ],
                          ),
                          backgroundColor: const Color(0xFF2196F3),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Assign'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
