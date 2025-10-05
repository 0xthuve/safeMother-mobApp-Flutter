import 'package:flutter/material.dart';
import '../models/patient_doctor_link.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../services/firebase_service.dart';

class PatientRequestsPage extends StatefulWidget {
  const PatientRequestsPage({super.key});

  @override
  State<PatientRequestsPage> createState() => _PatientRequestsPageState();
}

class _PatientRequestsPageState extends State<PatientRequestsPage> {
  final BackendService _backendService = BackendService();
  List<PatientDoctorLink> _requests = [];
  Map<String, Map<String, dynamic>> _patientDetails = {};
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPatientRequests();
  }

  Future<void> _loadPatientRequests() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = await SessionManager.getUserId();
      if (userId != null) {
        // Use the Firebase UID directly (no hash conversion needed)
        print('PatientRequestsPage: userId=$userId');
        
        final requests = await _backendService.getPatientRequestsForDoctor(userId);
        
        // Load patient details for each request
        Map<String, Map<String, dynamic>> patientDetails = {};
        for (final request in requests) {
          try {
            final patientData = await FirebaseService.getUserData(request.patientId);
            if (patientData != null) {
              patientDetails[request.patientId] = patientData;
            } else {
              // Fallback data when Firebase data is not available
              patientDetails[request.patientId] = {
                'fullName': 'Patient ${request.patientId.substring(0, 8)}',
                'email': 'Permission restricted',
                'contact': 'Not available',
                'age': 'N/A'
              };
            }
          } catch (e) {
            print('Could not load patient data for ${request.patientId}: $e');
            // Fallback data when Firebase access is denied
            patientDetails[request.patientId] = {
              'fullName': 'Patient ${request.patientId.substring(0, 8)}',
              'email': 'Permission restricted',
              'contact': 'Contact via app',
              'age': 'N/A'
            };
          }
        }
        
        setState(() {
          _requests = requests;
          _patientDetails = patientDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading patient requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(PatientDoctorLink request) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      // Use the Firebase UID directly (no hash conversion needed)
      final success = await _backendService.acceptPatientRequest(
        userId, 
        request.patientId, 
        request.id
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted patient: ${_patientDetails[request.patientId]?['fullName'] ?? 'Unknown Patient'}'),
            backgroundColor: Colors.green,
          ),
        );
        _hasChanges = true; // Mark that changes were made
        _loadPatientRequests(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept patient request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _declineRequest(PatientDoctorLink request) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      // Use the Firebase UID directly (no hash conversion needed)
      final success = await _backendService.declinePatientRequest(
        userId, 
        request.patientId, 
        request.id
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Declined patient: ${_patientDetails[request.patientId]?['fullName'] ?? 'Unknown Patient'}'),
            backgroundColor: Colors.orange,
          ),
        );
        _hasChanges = true; // Mark that changes were made
        _loadPatientRequests(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to decline patient request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF7B1FA2)),
            onPressed: () => Navigator.of(context).pop(_hasChanges),
          ),
        title: const Text(
          'Patient Requests',
          style: TextStyle(
            color: Color(0xFF7B1FA2),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF7B1FA2)),
            onPressed: _loadPatientRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
              ),
            )
          : _requests.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        color: Colors.grey,
                        size: 80,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Patient Requests',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'New patient requests will appear here',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPatientRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final patientData = _patientDetails[request.patientId];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF7B1FA2),
                                    radius: 25,
                                    child: Text(
                                      (patientData?['fullName'] ?? 'P')
                                          .split(' ')
                                          .map((n) => n[0])
                                          .take(2)
                                          .join()
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patientData?['fullName'] ?? 'Unknown Patient',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF7B1FA2),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          patientData?['email'] ?? 'No email',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (patientData?['phone'] != null)
                                          Text(
                                            patientData!['phone'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'PENDING',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F6F8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          color: Color(0xFF7B1FA2),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Requested: ${_formatDate(request.linkedDate)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF7B1FA2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (patientData?['pregnancyWeeks'] != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.pregnant_woman,
                                            color: Color(0xFFE91E63),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Pregnancy: ${patientData!['pregnancyWeeks']} weeks',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFFE91E63),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _declineRequest(request),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Decline'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
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
                                      onPressed: () => _acceptRequest(request),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
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
                    },
                  ),
                ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}