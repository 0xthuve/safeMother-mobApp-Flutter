import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navigation/family_navigation_handler.dart';
import '../models/family_member_model.dart';
import '../models/patient.dart';
import '../services/family_member_service.dart';
import '../services/familyMember_patient_service.dart';
import '../services/family_notification_service.dart';
import '../widgets/notification_permission_dialog.dart';

class FamilyHomeScreen extends StatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  State<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends State<FamilyHomeScreen> {
  FamilyMember? _currentUser;
  Patient? _patient;
  bool _isLoading = true;
  Map<String, dynamic> _pregnancyProgress = {};
  Map<String, dynamic> _healthMetrics = {};
  Map<String, dynamic> _latestLog = {};
  bool _notificationAsked = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAndRequestNotificationPermission();
    _startNotificationMonitoring();
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('notification_permission_asked') ?? false;
    
    if (!asked) {
      // Wait for build to complete
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final granted = await NotificationPermissionDialog.show(context);
        await prefs.setBool('notification_permission_asked', true);
        
        if (granted) {
          // Initialize notification service with context
          await FamilyNotificationService().initialize(context);
          await FamilyNotificationService().startMonitoring();
        }
      });
    } else {
      // Already asked, just initialize notifications
      await FamilyNotificationService().initialize(context);
      await FamilyNotificationService().startMonitoring();
    }
  }

  Future<void> _startNotificationMonitoring() async {
    try {
      await FamilyNotificationService().startMonitoring();
    } catch (e) {
      print('Error starting notification monitoring: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Get current user's family member data
      final familyMember =
          await FamilyMemberService.getCurrentUserFamilyMember();

      if (familyMember != null) {
        setState(() {
          _currentUser = familyMember;
        });

        // Load patient data
        await _loadPatientData();
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPatientData() async {
    try {
      // Load patient data
      _patient = await FamilyMemberPatientService.getLinkedPatient();

      if (_patient != null) {
        // Get patient ID from family member
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final familyMemberDoc = await FirebaseFirestore.instance
              .collection('family_members')
              .doc(currentUser.uid)
              .get();

          if (familyMemberDoc.exists) {
            final familyMemberData = familyMemberDoc.data()!;
            final patientId = familyMemberData['patientId'] ?? '';

            if (patientId.isNotEmpty) {
              // Load pregnancy data directly from patients collection
              await _loadPregnancyData(patientId);

              // Load health metrics
              _healthMetrics =
                  await FamilyMemberPatientService.getLatestHealthMetrics(
                patientId,
              );

              // Load latest symptom log for additional data
              await _loadLatestSymptomLog(patientId);
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  Future<void> _loadPregnancyData(String patientId) async {
    try {
      final patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();

      if (patientDoc.exists) {
        final patientData = patientDoc.data()!;
        
        // Extract pregnancy data from patient document
        final expectedDeliveryDate = patientData['expectedDeliveryDate'];
        final pregnancyConfirmedDate = patientData['pregnancyConfirmedDate'];
        final pregnancyWeek = patientData['pregnancyWeek'] ?? 0;
        final hasPregnancyLoss = patientData['hasPregnancyLoss'] ?? false;
        final isFirstChild = patientData['isFirstChild'] ?? false;

        // Calculate pregnancy progress
        if (expectedDeliveryDate != null && pregnancyConfirmedDate != null) {
          final dueDate = DateTime.parse(expectedDeliveryDate);
          final confirmedDate = DateTime.parse(pregnancyConfirmedDate);
          final now = DateTime.now();
          
          // Calculate weeks pregnant
          final weeksPregnant = _calculateWeeksPregnant(confirmedDate, now);
          
          // Calculate days to go
          final daysToGo = dueDate.difference(now).inDays;
          
          // Calculate progress percentage (typical pregnancy is 40 weeks)
          final totalDays = 280; // 40 weeks * 7 days
          final daysPassed = totalDays - daysToGo;
          final progressPercentage = ((daysPassed / totalDays) * 100).clamp(0, 100).toInt();
          
          // Determine trimester
          final trimester = _getTrimester(weeksPregnant);

          setState(() {
            _pregnancyProgress = {
              'weeks': weeksPregnant,
              'daysToGo': daysToGo > 0 ? daysToGo : 0,
              'progressPercentage': progressPercentage,
              'trimester': trimester,
              'dueDate': DateFormat('MMM dd, yyyy').format(dueDate),
              'confirmedDate': DateFormat('MMM dd, yyyy').format(confirmedDate),
              'hasPregnancyLoss': hasPregnancyLoss,
              'isFirstChild': isFirstChild,
            };
          });
        } else {
          // No pregnancy data available
          setState(() {
            _pregnancyProgress = {
              'weeks': 0,
              'daysToGo': 280,
              'progressPercentage': 0,
              'trimester': 'Not started',
              'dueDate': 'Not set',
              'confirmedDate': 'Not set',
              'hasPregnancyLoss': false,
              'isFirstChild': false,
            };
          });
        }
      }
    } catch (e) {
      print('Error loading pregnancy data: $e');
      // Set default values on error
      setState(() {
        _pregnancyProgress = {
          'weeks': 0,
          'daysToGo': 280,
          'progressPercentage': 0,
          'trimester': 'Not started',
          'dueDate': 'Not set',
          'confirmedDate': 'Not set',
          'hasPregnancyLoss': false,
          'isFirstChild': false,
        };
      });
    }
  }

  int _calculateWeeksPregnant(DateTime confirmedDate, DateTime currentDate) {
    final difference = currentDate.difference(confirmedDate).inDays;
    final weeks = (difference / 7).floor();
    return weeks.clamp(0, 40); // Typical pregnancy is 40 weeks
  }

  String _getTrimester(int weeks) {
    if (weeks <= 0) return 'Not started';
    if (weeks <= 13) return '1st Trimester';
    if (weeks <= 26) return '2nd Trimester';
    return '3rd Trimester';
  }

  Future<void> _loadLatestSymptomLog(String patientId) async {
    try {
      final logsQuery = await FirebaseFirestore.instance
          .collection('symptom_logs')
          .where('patientId', isEqualTo: patientId)
          .orderBy('logDate', descending: true)
          .limit(1)
          .get();

      if (logsQuery.docs.isNotEmpty) {
        final logData = logsQuery.docs.first.data();
        setState(() {
          _latestLog = logData;
        });
        
        // Update health metrics with latest log data
        _healthMetrics = {
          'heartRate': _extractHeartRate(logData['bloodPressure'] ?? ''),
          'bloodPressure': logData['bloodPressure'] ?? 'Not recorded',
          'weight': logData['weight'] != null ? '${logData['weight']} kg' : 'Not recorded',
          'babyKicks': logData['babyKicks'] ?? 'Not recorded',
          'mood': logData['mood'] ?? 'Not recorded',
          'lastUpdated': (logData['logDate'] as Timestamp).toDate(),
        };
      }
    } catch (e) {
      print('Error loading latest symptom log: $e');
    }
  }

  String _extractHeartRate(String bloodPressure) {
    if (bloodPressure.isEmpty || bloodPressure == 'Not recorded') return '--';
    try {
      final parts = bloodPressure.split('/');
      if (parts.isNotEmpty) {
        final systolic = int.tryParse(parts[0]);
        return systolic != null ? systolic.toString() : '--';
      }
    } catch (e) {
      return '--';
    }
    return '--';
  }

  String _getPatientName() {
    if (_patient != null) {
      String rawName = _patient!.name;

      // Clean the name by taking only the first name
      String patientName = rawName.split(' ').first.trim();
      patientName = patientName.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
      return patientName.isNotEmpty ? patientName : 'Your Loved One';
    }
    return 'Your Loved One';
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

  String _getHealthStatus(String metric, String value) {
    if (value == 'Not recorded' || value == '--') return 'Not recorded';

    switch (metric) {
      case 'heartRate':
        final hr = int.tryParse(value);
        if (hr == null) return 'Normal';
        return (hr >= 60 && hr <= 100) ? 'Normal' : 'Check';
      case 'bloodPressure':
        if (value == 'Not recorded' || value == '--') return 'Not recorded';
        try {
          final parts = value.split('/');
          if (parts.length == 2) {
            final systolic = int.tryParse(parts[0]);
            final diastolic = int.tryParse(parts[1]);
            if (systolic != null && diastolic != null) {
              if (systolic <= 120 && diastolic <= 80) return 'Normal';
              if (systolic <= 139 && diastolic <= 89) return 'Monitor';
              return 'Check';
            }
          }
        } catch (e) {
          return 'Normal';
        }
        return 'Normal';
      case 'weight':
        return value == 'Not recorded' ? 'Not recorded' : 'Healthy';
      case 'babyKicks':
        final kicks = int.tryParse(value);
        if (kicks == null) return 'Active';
        return kicks >= 10 ? 'Active' : 'Monitor';
      case 'mood':
        if (value == 'Not recorded') return 'Not recorded';
        return value == 'Excellent' || value == 'Good' ? 'Good' : 'Monitor';
      default:
        return 'Normal';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'stable':
      case 'healthy':
      case 'active':
      case 'good':
        return Colors.green;
      case 'check':
      case 'monitor':
        return Colors.orange;
      case 'not recorded':
        return Colors.grey;
      default:
        return Colors.grey;
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
            colors: [Color(0xFFFCE4EC), Color(0xFFE3F2FD), Colors.white],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(),
                          const SizedBox(height: 28),
                          _buildRoleBadge(),
                          const SizedBox(height: 28),
                          _buildPregnancyProgressSection(context),
                          const SizedBox(height: 28),
                          _buildHealthOverviewSection(),
                          const SizedBox(height: 28),
                          _buildRecentActivitySection(),
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
          // App Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
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
    String rawName = _currentUser?.fullName ?? 'Family Member';
    String userName = rawName.split(' ').first.trim();
    userName = userName.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
    if (userName.isEmpty) userName = 'Family Member';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()},',
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
              const TextSpan(text: '👋', style: TextStyle(fontSize: 28)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _pregnancyProgress['trimester'] ?? 'Not started',
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildProgressStat(
                  (_pregnancyProgress['weeks'] ?? 0).toString(),
                  'Weeks',
                  Icons.cake_outlined,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  (_pregnancyProgress['daysToGo'] ?? 280).toString(),
                  'Days to go',
                  Icons.access_time_outlined,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  '${_pregnancyProgress['progressPercentage'] ?? 0}%',
                  'Completed',
                  Icons.flag_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  width:
                      MediaQuery.of(context).size.width *
                      ((_pregnancyProgress['progressPercentage'] ?? 0) / 100),
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
                'Due: ${_pregnancyProgress['dueDate'] ?? 'Not set'}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D5D5D),
                ),
              ),
              Text(
                '${_pregnancyProgress['progressPercentage'] ?? 0}% complete',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health Overview',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2C2C),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  FamilyNavigationHandler.navigateToScreen(context, 1);
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Modern health metrics cards with unique design
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // First row - 2 metrics
                Row(
                  children: [
                    Expanded(
                      child: _buildModernHealthCard(
                        title: 'Heart Rate',
                        value: _healthMetrics['heartRate'] ?? '--',
                        unit: 'bpm',
                        icon: Icons.favorite_outline,
                        color: Colors.white,
                        status: _getHealthStatus('heartRate', _healthMetrics['heartRate'] ?? '--'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernHealthCard(
                        title: 'Blood Pressure',
                        value: _healthMetrics['bloodPressure']?.split('/').first ?? '--',
                        unit: 'mmHg',
                        icon: Icons.monitor_heart_outlined,
                        color: Colors.white,
                        status: _getHealthStatus('bloodPressure', _healthMetrics['bloodPressure'] ?? '--'),
                        isBloodPressure: true,
                        fullBPValue: _healthMetrics['bloodPressure'] ?? '--/--',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Second row - 2 metrics
                Row(
                  children: [
                    Expanded(
                      child: _buildModernHealthCard(
                        title: 'Baby Kicks',
                        value: _healthMetrics['babyKicks'] ?? '--',
                        unit: 'today',
                        icon: Icons.child_care_outlined,
                        color: Colors.white,
                        status: _getHealthStatus('babyKicks', _healthMetrics['babyKicks'] ?? '--'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernHealthCard(
                        title: 'Mood',
                        value: _healthMetrics['mood']?.split(' ').first ?? '--',
                        unit: _healthMetrics['mood'] != null && _healthMetrics['mood'] != 'Not recorded' 
                            ? _healthMetrics['mood']!.replaceFirst(RegExp(r'\w+\s?'), '').trim()
                            : '',
                        icon: Icons.sentiment_satisfied_alt_outlined,
                        color: Colors.white,
                        status: _getHealthStatus('mood', _healthMetrics['mood'] ?? '--'),
                      ),
                    ),
                  ],
                ),
                
                // See More Button
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      FamilyNavigationHandler.navigateToScreen(context, 1);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View All Health Data',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernHealthCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String status,
    bool isBloodPressure = false,
    String fullBPValue = '',
  }) {
    final statusColor = _getStatusColor(status);
    
    // Get mood emoji
    String getMoodEmoji(String mood) {
      switch (mood.toLowerCase()) {
        case 'excellent':
          return '😊';
        case 'good':
          return '🙂';
        case 'okay':
          return '😐';
        case 'low':
          return '😔';
        case 'anxious':
          return '😰';
        default:
          return '😊';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Value with emoji for mood
          if (title == 'Mood' && value != '--' && value != 'Not recorded')
            Row(
              children: [
                Text(
                  getMoodEmoji(value),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                ),
              ],
            )
          else if (isBloodPressure && fullBPValue != '--/--')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullBPValue,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 0.9,
              ),
            ),
          
          // Title and unit
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          if (unit.isNotEmpty)
            Text(
              unit,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    final hasRecentActivity = _latestLog.isNotEmpty;
    final lastUpdate = _healthMetrics['lastUpdated'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
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
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.update,
                    color: Color(0xFFE91E63),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last Health Update',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const Spacer(),
                  if (lastUpdate != null)
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(lastUpdate),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasRecentActivity)
                _buildActivityItem('Health Log', 'Symptom tracking completed', Icons.assignment_outlined)
              else
                _buildActivityItem('No recent activity', 'Health data will appear here', Icons.info_outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFFE91E63), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
            _buildNavItem(
              context,
              Icons.calendar_today_outlined,
              'Appointments',
              2,
            ),
            _buildNavItem(context, Icons.menu_book_outlined, 'Learn', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isActive = index == 0;
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
              color: isActive
                  ? Colors.white
                  : const Color(0xFFE91E63).withOpacity(0.6),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isActive
                  ? const Color(0xFFE91E63)
                  : const Color(0xFFE91E63).withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}