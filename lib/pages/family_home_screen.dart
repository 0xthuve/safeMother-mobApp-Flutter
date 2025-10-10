import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/family_navigation_handler.dart';
import '../models/family_member_model.dart';
import '../services/family_member_service.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  FamilyMember? _currentUser;
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get current user's family member data
      final familyMember = await FamilyMemberService.getCurrentUserFamilyMember();
      
      if (familyMember != null) {
        setState(() {
          _currentUser = familyMember;
        });

        // Load patient data if patientUserId exists
        if (familyMember.patientUserId.isNotEmpty && 
            familyMember.patientUserId != 'temp_${familyMember.patientId}') {
          await _loadPatientData(familyMember.patientUserId);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPatientData(String patientUserId) async {
    try {
      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientUserId)
          .get();
      
      if (patientDoc.exists) {
        setState(() {
          _patientData = patientDoc.data();
        });
      }
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  String _getPatientName() {
    if (_patientData != null) {
      return _patientData!['fullName'] ?? 'Sarah';
    }
    return 'Sarah'; // Default fallback
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE4EC), // Light pink
              Color(0xFFE3F2FD), // Light blue
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar
            _buildCustomAppBar(context),
            Expanded(
              child: _isLoading 
                  ? _buildLoadingIndicator()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          _buildWelcomeSection(),
                          const SizedBox(height: 28),
                          
                          // Role Badge
                          _buildRoleBadge(),
                          const SizedBox(height: 28),
                          
                          // Pregnancy Progress Section
                          _buildPregnancyProgressSection(context),
                          const SizedBox(height: 28),
                          
                          // Health Overview Cards
                          _buildHealthOverviewSection(),
                          const SizedBox(height: 28),
                          
                          // Support Actions
                          _buildSupportActionsSection(),
                          const SizedBox(height: 28),
                          
                          // Recent Updates
                          _buildRecentUpdatesSection(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withOpacity(0.9),
            const Color(0xFF2196F3).withOpacity(0.9),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
    ),
    child: Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Center(
            child: Text(
              'Safe Mother',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => FamilyNavigationHandler.navigateToProfile(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    ),
  );
  }

Widget _buildWelcomeSection() {
  // Clean the username by removing any extra text and taking only the first part
  String rawName = _currentUser?.fullName ?? 'Family Member';

  // Split by spaces and take only the first word (first name)
  String userName = rawName.split(' ').first.trim();

  // Additional cleanup to remove any special characters or unwanted text
  userName = userName.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();

  // Fallback if name is empty
  if (userName.isEmpty) {
    userName = 'Family Member';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${_getGreeting()},', // ✅ Corrected here
        style: GoogleFonts.inter(
          fontSize: 18,
          color: const Color(0xFF5D5D5D),
          fontWeight: FontWeight.w400,
        ),
      ),
      const SizedBox(height: 6),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$userName ',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2C2C2C),
                letterSpacing: 0.5,
              ),
            ),
            const TextSpan(
              text: '👋',
              style: TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Supporting your loved one through this beautiful journey',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF757575),
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    ],
  );
}


  Widget _buildRoleBadge() {
    final relationship = _currentUser?.relationship ?? 'Family Member';
    final patientName = _getPatientName();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.family_restroom, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$relationship of $patientName',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Caregiver',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyProgressSection(BuildContext context) {
    final patientName = _getPatientName();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0F7), Color(0xFFF0F8FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.1),
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
              Icon(Icons.pregnant_woman, color: Color(0xFFE91E63), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$patientName's Pregnancy Journey",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2C2C),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'First Trimester',
                  style: GoogleFonts.inter(
                    color: Color(0xFFE91E63),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildProgressStat('8', 'Weeks', Icons.cake_outlined),
              ),
              Expanded(
                child: _buildProgressStat('224', 'Days to go', Icons.access_time_outlined),
              ),
              Expanded(
                child: _buildProgressStat('20%', 'Completed', Icons.flag_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress Bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: May 15, 2026',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D5D5D),
                ),
              ),
              Text(
                '20% complete',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C2C2C),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHealthOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Overview',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF3E5F5), // Light purple
                Color(0xFFFCE4EC), // Light pink
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthCard(
                        'Heart Rate',
                        '72 bpm',
                        Icons.favorite_border,
                        const Color(0xFFE91E63),
                        'Normal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildHealthCard(
                        'Blood Pressure',
                        '120/80',
                        Icons.monitor_heart_outlined,
                        const Color(0xFF2196F3),
                        'Stable',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthCard(
                        'Weight',
                        '65.2 kg',
                        Icons.line_weight_outlined,
                        const Color(0xFF4CAF50),
                        '+1.2 kg',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildHealthCard(
                        'Baby Kicks',
                        '12 today',
                        Icons.child_care_outlined,
                        const Color(0xFF9C27B0),
                        'Active',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon, Color color, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                status,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support Actions',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF3E5F5), // Light purple
                Color(0xFFFCE4EC), // Light pink
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildSupportAction(
                  'Send\nEncouragement',
                  Icons.favorite_outline,
                  const Color(0xFFE91E63),
                ),
                _buildSupportAction(
                  'Schedule\nAppointment',
                  Icons.calendar_today_outlined,
                  const Color(0xFF2196F3),
                ),
                _buildSupportAction(
                  'Meal\nPlanning',
                  Icons.restaurant_outlined,
                  const Color(0xFF4CAF50),
                ),
                _buildSupportAction(
                  'Emergency\nContacts',
                  Icons.contact_phone_outlined,
                  const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportAction(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2C2C),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Updates',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2C2C),
              ),
            ),
            Spacer(),
            Text(
              'View All',
              style: GoogleFonts.inter(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF3E5F5), // Light purple
                Color(0xFFFCE4EC), // Light pink
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUpdateItem(
                  'Health Check Completed',
                  '${_getPatientName()} completed daily health log with stable vitals',
                  Icons.health_and_safety_outlined,
                  Colors.green,
                  '2 hours ago',
                ),
                const SizedBox(height: 12),
                _buildUpdateItem(
                  'Next Appointment',
                  'Prenatal checkup scheduled for tomorrow at 2:00 PM',
                  Icons.calendar_today_outlined,
                  Colors.blue,
                  '5 hours ago',
                ),
                const SizedBox(height: 12),
                _buildUpdateItem(
                  'Nutrition Log',
                  'Healthy meal choices recorded throughout the day',
                  Icons.restaurant_outlined,
                  Colors.orange,
                  '8 hours ago',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateItem(String title, String subtitle, IconData icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home_filled, 'Home', 0),
            _buildNavItem(context, Icons.assignment_outlined, 'View Log', 1),
            _buildNavItem(context, Icons.calendar_today_outlined, 'Appointments', 2),
            _buildNavItem(context, Icons.contact_phone_outlined, 'Contacts', 3),
            _buildNavItem(context, Icons.menu_book_outlined, 'Learn', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = index == 0; // Home is always active on home screen
    return GestureDetector(
      onTap: () => FamilyNavigationHandler.navigateToScreen(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFF8BBD0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFFE91E63).withOpacity(0.6),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFFE91E63).withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}