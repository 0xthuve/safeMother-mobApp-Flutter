import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';

class DoctorSelectionPage extends StatefulWidget {
  const DoctorSelectionPage({super.key});

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  final BackendService _backendService = BackendService();
  List<Doctor> _doctors = [];
  List<String> _linkedDoctorIds = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSpecialization = 'All';
  String? _errorMessage;

  final List<String> _specializations = [
    'All',
    'Obstetrician',
    'Gynecologist', 
    'Pediatrician',
    'General Practitioner',
    'Midwife'
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = await SessionManager.getUserId();
      if (userId != null) {
        print('Loading doctors for user: $userId');
        
        // Load all doctors
        final doctors = await _backendService.getAllDoctors();
        print('Loaded ${doctors.length} doctors from backend');
        
        // Load linked doctors for this patient
        final linkedDoctors = await _backendService.getLinkedDoctors(userId);
        print('User has ${linkedDoctors.length} linked doctors');
        
        setState(() {
          _doctors = doctors;
          _linkedDoctorIds = linkedDoctors.map((link) => link.doctorId).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() {
        _errorMessage = 'Unable to load doctors. Please check your internet connection and try again.\n\nError: $e';
        _isLoading = false;
      });
    }
  }

  List<Doctor> get _filteredDoctors {
    return _doctors.where((doctor) {
      final matchesSearch = doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           doctor.specialization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           doctor.hospital.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesSpecialization = _selectedSpecialization == 'All' || 
                                   doctor.specialization == _selectedSpecialization;
      
      return matchesSearch && matchesSpecialization && doctor.isAvailable;
    }).toList();
  }

  Future<void> _linkWithDoctor(Doctor doctor) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        print('DEBUG: User ID is null, cannot proceed with linking');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to continue.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      print('DEBUG: Starting link process for user $userId with doctor ${doctor.name}');

      // Check if user already has a request or link with this specific doctor
      final doctorIdToUse = doctor.firebaseUid ?? doctor.id.toString();
      print('DEBUG: Checking existing links for patient $userId with doctor $doctorIdToUse');
      print('DEBUG: Doctor firebaseUid: ${doctor.firebaseUid}, Doctor id: ${doctor.id}');
      
      final linkedDoctors = await _backendService.getLinkedDoctorsForPatient(userId);
      print('DEBUG: Found ${linkedDoctors.length} existing linked doctors');
      
      // Check both firebaseUid and id to be thorough
      final existingLink = linkedDoctors.where((d) => 
        d['doctorId'] == doctorIdToUse || 
        d['doctorId'] == doctor.firebaseUid || 
        d['doctorId'] == doctor.id.toString()
      ).toList();
      print('DEBUG: Found ${existingLink.length} existing links with this specific doctor');
      
      // Print existing links for debugging
      for (var link in linkedDoctors) {
        print('DEBUG: Existing link - doctorId: ${link['doctorId']}, status: ${link['status']}, doctorName: ${link['doctorName']}');
      }
      
      if (existingLink.isNotEmpty) {
        String statusMessage;
        Color statusColor;
        
        switch (existingLink.first['status']) {
          case 'accepted':
            statusMessage = 'You are already connected with Dr. ${doctor.name}!';
            statusColor = Colors.green;
            break;
          case 'requested':
            statusMessage = 'You already have a pending request with Dr. ${doctor.name}. Please wait for their response.';
            statusColor = Colors.orange;
            break;
          case 'declined':
            statusMessage = 'Dr. ${doctor.name} previously declined your request. You can try again if needed.';
            statusColor = Colors.red;
            break;
          default:
            statusMessage = 'You already have a connection with Dr. ${doctor.name}.';
            statusColor = Colors.blue;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusMessage),
            backgroundColor: statusColor,
            duration: const Duration(seconds: 3),
          ),
        );
        
        if (existingLink.first['status'] != 'declined') {
          return; // Don't allow linking if already connected or pending
        }
      }

      // Prepare dialog for linking with new doctor
      String dialogTitle = 'Add Healthcare Professional';
      String dialogContent = 'Do you want to add Dr. ${doctor.name} to your healthcare team?\n\n'
                             'Doctor Details:\n'
                             'Specialization: ${doctor.specialization}\n'
                             'Hospital: ${doctor.hospital}\n\n'
                             'You can have multiple healthcare professionals for comprehensive care during your pregnancy journey.';

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
              child: const Text(
                'Add Doctor',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
          ),
        );
        
        try {
          print('DEBUG: Attempting to link patient $userId with doctor ${doctor.firebaseUid ?? doctor.id.toString()}');
          print('DEBUG: Doctor name: ${doctor.name}');
          
          final success = await _backendService.linkPatientWithDoctor(userId, doctor.firebaseUid ?? doctor.id.toString());
          
          // Close loading dialog
          Navigator.pop(context);
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Request sent to Dr. ${doctor.name}! Check your "My Doctors" section for status updates.'
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
            
            // Refresh the list
            _loadDoctors();
          } else {
            print('DEBUG: linkPatientWithDoctor returned false');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to send request to Dr. ${doctor.name}. This might be because you already have a request with this doctor. Please check your "My Doctors" section.'
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          // Close loading dialog
          Navigator.pop(context);
          print('DEBUG: Exception during linking: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: $e. Please try again or contact support.'
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('Error linking with doctor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
          'Select Your Doctor',
          style: TextStyle(
            color: Color(0xFF7B1FA2),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
              ),
            )
          : Column(
              children: [
                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search doctors, specializations, hospitals...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF7B1FA2)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Specialization filter
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSpecialization,
                            hint: const Text('Select Specialization'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSpecialization = value!;
                              });
                            },
                            items: _specializations.map((specialization) {
                              return DropdownMenuItem(
                                value: specialization,
                                child: Text(specialization),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Current Doctor Section
                if (_linkedDoctorIds.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Healthcare Professional',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dr. ${_doctors.firstWhere((d) => d.id.toString() == _linkedDoctorIds.first, orElse: () => Doctor(name: 'Unknown', email: '', phone: '', specialization: '', licenseNumber: '', hospital: '', experience: '', bio: '', createdAt: DateTime.now(), updatedAt: DateTime.now())).name}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7B1FA2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Available Doctors Section Header
                if (_doctors.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      _linkedDoctorIds.isEmpty 
                          ? 'Available Healthcare Professionals'
                          : 'Change Healthcare Professional',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                  ),
                
                // Doctors List
                Expanded(
                  child: _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Error Loading Doctors',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadDoctors,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filteredDoctors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _doctors.isEmpty 
                                        ? Icons.local_hospital_outlined
                                        : Icons.medical_services_outlined,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _doctors.isEmpty 
                                        ? 'No Healthcare Professionals Available'
                                        : 'No doctors found',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7B1FA2),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _doctors.isEmpty 
                                    ? 'Healthcare professionals will appear here when they register on the platform through Firebase.'
                                    : 'Try adjusting your search or filters',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_doctors.isEmpty) ...[
                                const SizedBox(height: 24),
                                const Icon(
                                  Icons.cloud_sync,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Connected to Firebase Database',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = _filteredDoctors[index];
                            final isLinked = _linkedDoctorIds.contains(doctor.id.toString());
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isLinked 
                                    ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                                    : null,
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
                                      // Doctor Avatar
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE91E63).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Color(0xFFE91E63),
                                          size: 30,
                                        ),
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
                                                    'Dr. ${doctor.name}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF7B1FA2),
                                                    ),
                                                  ),
                                                ),
                                                if (isLinked)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF4CAF50),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      'Linked',
                                                      style: TextStyle(
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
                                              doctor.specialization,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFE91E63),
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 2),
                                            
                                            Text(
                                              doctor.hospital,
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
                                  
                                  // Doctor Stats
                                  Row(
                                    children: [
                                      _buildStatChip(
                                        Icons.star,
                                        '${doctor.rating}/5',
                                        Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatChip(
                                        Icons.work,
                                        doctor.experience,
                                        const Color(0xFF7B1FA2),
                                      ),
                                      const SizedBox(width: 12),
                                      _buildStatChip(
                                        Icons.people,
                                        '${doctor.totalPatients} patients',
                                        const Color(0xFFE91E63),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Bio
                                  if (doctor.bio.isNotEmpty)
                                    Text(
                                      doctor.bio,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF5A5A5A),
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _linkWithDoctor(doctor),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isLinked 
                                            ? const Color(0xFF4CAF50)
                                            : (_linkedDoctorIds.isNotEmpty 
                                                ? const Color(0xFFFF9800) // Orange for change
                                                : const Color(0xFFE91E63)), // Pink for link
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        isLinked 
                                            ? 'Current Doctor' 
                                            : (_linkedDoctorIds.isNotEmpty 
                                                ? 'Change to This Doctor'
                                                : 'Select This Doctor'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
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