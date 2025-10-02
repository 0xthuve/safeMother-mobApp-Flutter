import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/doctor.dart';
import '../../services/session_manager.dart';
import '../../services/user_management_service.dart';
import '../../signin.dart';
import 'doctor_edit_profile.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final int _currentIndex = 3; // Profile is still index 3 (0-based: Dashboard, Patients, Appointments, Profile)
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
      
      final now = DateTime.now();
      
      if (userData != null) {
        final doctorData = Doctor(
          id: (userData['id'] as int?) ?? 1,
          name: userName ?? userData['fullName'] ?? 'Dr. User',
          email: userEmail ?? userData['email'] ?? '',
          phone: userData['phone'] ?? userData['contact'] ?? '',
          specialization: userData['specialization'] ?? 'General Medicine',
          licenseNumber: userData['licenseNumber'] ?? 'Not specified',
          hospital: userData['hospital'] ?? 'Not specified',
          experience: userData['experience']?.toString() ?? '0 years',
          bio: userData['bio'] ?? 'Healthcare professional dedicated to patient care.',
          rating: (userData['rating'] as num?)?.toDouble() ?? 4.5,
          totalPatients: (userData['totalPatients'] as int?) ?? (userData['reviewCount'] as int?) ?? 0,
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
          id: 1,
          name: userName ?? 'Dr. User',
          email: userEmail ?? 'doctor@safemother.com',
          phone: '',
          specialization: 'General Medicine',
          licenseNumber: 'Demo Mode',
          hospital: 'Demo Hospital',
          experience: 'Demo Mode',
          bio: 'Demo healthcare professional.',
          rating: 4.5,
          totalPatients: 0,
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
      print('Error loading doctor data: $e');
      // Fallback data
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final now = DateTime.now();
      
      final fallbackDoctor = Doctor(
        id: 1,
        name: userName ?? 'Dr. User',
        email: userEmail ?? 'doctor@safemother.com',
        phone: '',
        specialization: 'General Medicine',
        licenseNumber: 'Not available',
        hospital: 'Not available',
        experience: 'Not available',
        bio: 'Healthcare professional.',
        rating: 4.5,
        totalPatients: 0,
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
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1976D2), // Blue theme
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          if (!_isLoading && _doctor != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _navigateToEditProfile,
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF1E88E5)], // Blue gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                _doctor!.name.isNotEmpty ? _doctor!.name[0] : 'D',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _doctor!.name,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _doctor!.specialization,
                              style: TextStyle(color: Colors.white.withOpacity(0.9)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow, size: 18),
                                const SizedBox(width: 4),
                                Text('${_doctor!.rating}', style: const TextStyle(color: Colors.white)),
                                const SizedBox(width: 16),
                                const Icon(Icons.people, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text('${_doctor!.totalPatients} patients', style: const TextStyle(color: Colors.white)),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1976D2)), // Blue theme
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


