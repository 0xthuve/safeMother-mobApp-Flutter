import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../services/firebase_service.dart';
import 'doctor_selection_page.dart';

class LinkedDoctorsPage extends StatefulWidget {
  const LinkedDoctorsPage({super.key});

  @override
  State<LinkedDoctorsPage> createState() => _LinkedDoctorsPageState();
}

class _LinkedDoctorsPageState extends State<LinkedDoctorsPage> {
  final BackendService _backendService = BackendService();
  List<Map<String, dynamic>> _linkedDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedDoctors();
  }

  Future<void> _loadLinkedDoctors() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = await SessionManager.getUserId();
      if (userId != null) {
        print('LinkedDoctorsPage: Loading doctors for patient $userId');
        
        // Get linked doctors with their status from Firebase
        final linkedDoctors = await _backendService.getLinkedDoctorsForPatient(userId);
        
        // Enhance doctor data with patient details
        List<Map<String, dynamic>> enhancedDoctors = [];
        
        for (final doctorData in linkedDoctors) {
          Map<String, dynamic> enhanced = Map.from(doctorData);
          
          // Get patient name to show properly
          try {
            final patientData = await FirebaseService.getUserData(userId);
            if (patientData != null) {
              enhanced['patientName'] = patientData['fullName'] ?? 'Unknown Patient';
              enhanced['patientEmail'] = patientData['email'] ?? '';
              enhanced['patientPhone'] = patientData['phone'] ?? patientData['contact'] ?? '';
            } else {
              enhanced['patientName'] = 'Patient ${userId.substring(0, 8)}';
              enhanced['patientEmail'] = 'Contact via app';
              enhanced['patientPhone'] = 'Contact via app';
            }
          } catch (e) {
            print('Error loading patient data: $e');
            enhanced['patientName'] = 'Patient ${userId.substring(0, 8)}';
            enhanced['patientEmail'] = 'Contact via app';
            enhanced['patientPhone'] = 'Contact via app';
          }
          
          enhancedDoctors.add(enhanced);
        }
        
        setState(() {
          _linkedDoctors = enhancedDoctors;
          _isLoading = false;
        });
      } else {
        setState(() {
          _linkedDoctors = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading linked doctors: $e');
      setState(() {
        _linkedDoctors = [];
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'PENDING';
      case 'accepted':
        return 'ACCEPTED';
      case 'declined':
        return 'DECLINED';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7B1FA2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Doctors',
          style: TextStyle(
            color: Color(0xFF7B1FA2),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF7B1FA2)),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorSelectionPage(),
                ),
              );
              
              // Refresh the list if a doctor was linked
              if (result == true) {
                _loadLinkedDoctors();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
              ),
            )
          : _linkedDoctors.isEmpty
              ? _buildEmptyState()
              : _buildDoctorsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 60,
                color: Color(0xFFE91E63),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'No Doctors Linked Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7B1FA2),
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              'Link with qualified doctors to get personalized care and guidance throughout your pregnancy journey.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5A5A5A),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorSelectionPage(),
                  ),
                );
                
                if (result == true) {
                  _loadLinkedDoctors();
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Find & Link Doctors'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorsList() {
    return Column(
      children: [
        // Stats header
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE91E63).withOpacity(0.1),
                const Color(0xFF7B1FA2).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE91E63).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFFE91E63),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_linkedDoctors.length} Linked Doctor${_linkedDoctors.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your trusted healthcare team',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A5A5A),
                      ),
                    ),
                  ],
                ),
              ),
              
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorSelectionPage(),
                    ),
                  );
                  
                  if (result == true) {
                    _loadLinkedDoctors();
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add More'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        
        // Doctors list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _linkedDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _linkedDoctors[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor(doctor['status']).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple[50]!,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Doctor Avatar with status indicator
                        Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  (doctor['doctorName'] ?? 'Dr')
                                      .split(' ')
                                      .map((n) => n.isNotEmpty ? n[0] : '')
                                      .take(2)
                                      .join()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFE91E63),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(doctor['status']),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  doctor['status'] == 'accepted' ? Icons.check :
                                  doctor['status'] == 'declined' ? Icons.close :
                                  Icons.schedule,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Doctor Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Dr. ${doctor['doctorName'] ?? 'Unknown Doctor'}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF7B1FA2),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(doctor['status']),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(doctor['status']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 4),
                              
                              Text(
                                doctor['specialization'] ?? 'General Practice',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                              
                              const SizedBox(height: 2),
                              
                              Text(
                                doctor['hospital'] ?? 'Unknown Hospital',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5A5A5A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Patient Info Section (shows who is linked to this doctor)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF7B1FA2).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient Information:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7B1FA2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Color(0xFF7B1FA2)),
                              const SizedBox(width: 8),
                              Text(
                                doctor['patientName'] ?? 'Unknown Patient',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Linked ${_formatDate(doctor['createdAt'])}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Doctor Stats
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.star,
                          '4.5/5',
                          Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          Icons.work,
                          '${doctor['yearsExperience'] ?? '0'} years',
                          const Color(0xFF7B1FA2),
                        ),
                        const SizedBox(width: 12),
                        _buildStatChip(
                          Icons.access_time,
                          _getStatusText(doctor['status']),
                          _getStatusColor(doctor['status']),
                        ),
                      ],
                    ),
                    
                    // Contact Info for accepted doctors
                    if (doctor['status'] == 'accepted') ...[
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
                            const Text(
                              'Contact Information:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  doctor['doctorEmail'] ?? 'Not available',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  doctor['doctorPhone'] ?? 'Not available',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      

                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
