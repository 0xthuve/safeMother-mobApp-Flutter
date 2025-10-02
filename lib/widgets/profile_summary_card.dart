import 'package:flutter/material.dart';
import '../services/user_management_service.dart';
import '../services/session_manager.dart';

class ProfileSummaryCard extends StatefulWidget {
  const ProfileSummaryCard({super.key});

  @override
  State<ProfileSummaryCard> createState() => _ProfileSummaryCardState();
}

class _ProfileSummaryCardState extends State<ProfileSummaryCard> {
  Map<String, dynamic>? _userData;
  String _userName = 'User';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final userData = await UserManagementService.getCurrentUserData();

      setState(() {
        _userName = userName ?? 'User';
        _userEmail = userEmail ?? '';
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFF4EF),
                    border: Border.all(
                      color: const Color(0xFFE91E63).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xFF638763),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF638763),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData?['role'] ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9575CD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Profile Information
            if (_userData != null) ...[
              _buildInfoItem(
                'Age',
                _userData!['age']?.toString() ?? 'Not set',
                Icons.cake_outlined,
              ),
              _buildInfoItem(
                'Phone',
                _userData!['phone'] ?? _userData!['contact'] ?? 'Not set',
                Icons.phone_outlined,
              ),
              _buildInfoItem(
                'Blood Type',
                _userData!['bloodType'] ?? 'Not set',
                Icons.bloodtype,
              ),
              if (_userData!['emergencyContact'] != null && _userData!['emergencyContact'].toString().isNotEmpty)
                _buildInfoItem(
                  'Emergency Contact',
                  _userData!['emergencyContact'],
                  Icons.contact_emergency_outlined,
                ),
            ],
            
            // Quick stats or additional info
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Profile', '${_getProfileCompleteness()}%', Icons.person_outline),
                  _buildStatItem('Active', _isProfileActive() ? 'Yes' : 'No', Icons.check_circle_outline),
                  _buildStatItem('Verified', _isEmailVerified() ? 'Yes' : 'No', Icons.verified_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF9575CD),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111611),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF638763),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFE91E63),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111611),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF638763),
          ),
        ),
      ],
    );
  }

  int _getProfileCompleteness() {
    if (_userData == null) return 20;
    
    int completeness = 20; // Base for having an account
    
    if (_userData!['fullName'] != null && _userData!['fullName'].toString().isNotEmpty) completeness += 20;
    if (_userData!['phone'] != null && _userData!['phone'].toString().isNotEmpty) completeness += 20;
    if (_userData!['age'] != null && _userData!['age'] != 0) completeness += 20;
    if (_userData!['emergencyContact'] != null && _userData!['emergencyContact'].toString().isNotEmpty) completeness += 20;
    
    return completeness;
  }

  bool _isProfileActive() {
    // Check if user has logged in recently or has some activity
    return _userData != null;
  }

  bool _isEmailVerified() {
    // Check if email is verified (this would depend on your Firebase auth setup)
    return _userData?['emailVerified'] ?? false;
  }
}