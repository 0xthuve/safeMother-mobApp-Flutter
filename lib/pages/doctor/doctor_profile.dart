import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/doctor.dart';
import '../../services/session_manager.dart';
import '../../services/user_management_service.dart';
import '../../services/backend_service.dart';
import '../../signin.dart';
import 'doctor_edit_profile.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final int _currentIndex = 3; // Profile is still index 3 (0-based: Dashboard, Patients, Appointments, Profile)
  final BackendService _backendService = BackendService();
  Doctor? _doctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get actual logged-in user data
      final userData = await UserManagementService.getCurrentUserData();
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final userId = await SessionManager.getUserId();
      
      // Get actual patient count from Firebase
      int actualPatientCount = 0;
      if (userId != null) {
        try {
          final acceptedPatients = await _backendService.getAcceptedPatientsForDoctor(userId);
          actualPatientCount = acceptedPatients.length;

        } catch (e) {
          // Error getting patient count, using default value
        }
      }
      
      final now = DateTime.now();
      
      if (userData != null) {
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
          totalPatients: actualPatientCount, // Use actual count from Firebase
          isAvailable: userData['isAvailable'] ?? true,
          createdAt: now,
          updatedAt: now,
        );

        setState(() {
          _doctor = doctorData;
          _isLoading = false;
        });
      } else {
        // Fallback to demo data
        final fallbackDoctor = Doctor(
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
          totalPatients: actualPatientCount, // Use actual count from Firebase
          isAvailable: true,
          createdAt: now,
          updatedAt: now,
        );

        setState(() {
          _doctor = fallbackDoctor;
          _isLoading = false;
        });
      }
    } catch (e) {

      // Fallback data - still try to get patient count
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final userId = await SessionManager.getUserId();
      
      int fallbackPatientCount = 0;
      if (userId != null) {
        try {
          final acceptedPatients = await _backendService.getAcceptedPatientsForDoctor(userId);
          fallbackPatientCount = acceptedPatients.length;
        } catch (e2) {
          // Fallback also failed, using default count
        }
      }
      
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
        totalPatients: fallbackPatientCount, // Use actual count even in error case
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      );

      setState(() {
        _doctor = fallbackDoctor;
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB), // Modern blue
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (!_isLoading && _doctor != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                onPressed: _navigateToEditProfile,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            )
          : _doctor == null
              ? const Center(
                  child: Text(
                    'Failed to load profile data',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                child: Text(
                                  _doctor!.name.isNotEmpty ? _doctor!.name[0].toUpperCase() : 'D',
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontSize: 40, 
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _doctor!.name,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 26, 
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _doctor!.specialization,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.people_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_doctor!.totalPatients} patients',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      _infoTile(Icons.badge, 'License Number', _doctor!.licenseNumber),
                      _infoTile(Icons.local_hospital, 'Hospital', _doctor!.hospital),
                      _infoTile(Icons.work, 'Experience', _doctor!.experience),
                      _infoTile(Icons.email, 'Email', _doctor!.email),
                      _infoTile(Icons.phone, 'Phone', _doctor!.phone.isEmpty ? 'Not specified' : _doctor!.phone),
                      _infoTile(Icons.info, 'Bio', _doctor!.bio),
                      _infoTile(Icons.verified, 'Available', _doctor!.isAvailable ? 'Yes' : 'No'),
            
                      // Edit Profile Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        child: ElevatedButton.icon(
                          onPressed: _navigateToEditProfile,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      
                      // Sign Out Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton.icon(
                          onPressed: _showSignOutDialog,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorEditProfile(),
      ),
    );

    // If profile was updated, reload the data
    if (result == true) {
      _loadDoctorData();
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to sign out of your doctor account?',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF1976D2)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _performSignOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Future<void> _performSignOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
          ),
        ),
      );

      // Clear session data
      await SessionManager.clearSession();

      // Small delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        // Navigate to sign in screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed out'),
            backgroundColor: const Color(0xFF1976D2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon, 
              color: const Color(0xFF2563EB), 
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value, 
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


