import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safemothermobapp/l10n/app_localizations.dart';
import 'family_profile_page.dart';
import 'family_home_screen.dart';
import 'family_appointment_page.dart';
import 'family_learn_page.dart';

class FamilyViewLogScreen extends StatefulWidget {
  const FamilyViewLogScreen({super.key});

  @override
  State<FamilyViewLogScreen> createState() => _FamilyViewLogScreenState();
}

class _FamilyViewLogScreenState extends State<FamilyViewLogScreen> {
  List<Map<String, dynamic>> _linkedPatientLogs = [];
  bool _isLoading = true;
  String _linkedPatientName = "Patient";
  String? _linkedPatientId;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadPatientLogs();
  }

  Future<void> _loadPatientLogs() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get family member document to find linked patientId
      final familyMemberDoc = await FirebaseFirestore.instance
          .collection('family_members')
          .doc(currentUser.uid)
          .get();

      if (familyMemberDoc.exists) {
        final familyMemberData = familyMemberDoc.data();
        _linkedPatientId = familyMemberData?['patientUserId'];
        
        if (_linkedPatientId != null && _linkedPatientId!.isNotEmpty) {
          // Get patient name from users collection
          final patientDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_linkedPatientId!)
              .get();
          
          if (patientDoc.exists) {
            final patientData = patientDoc.data();
            _linkedPatientName = patientData?['fullName'] ?? 
                                patientData?['name'] ?? 
                                'Patient';
          }
          
          // Get symptom logs for the linked patient
          final logsQuery = await FirebaseFirestore.instance
              .collection('symptom_logs')
              .where('patientId', isEqualTo: _linkedPatientId)
              .orderBy('logDate', descending: true)
              .get();

          _linkedPatientLogs = logsQuery.docs.map((doc) {
            final data = doc.data();
            final logDate = (data['logDate'] as Timestamp).toDate();
            
            return {
              'logDate': logDate,
              'bloodPressure': data['bloodPressure'] ?? '--/--',
              'weight': data['weight']?.toString() ?? '--',
              'babyKicks': data['babyKicks']?.toString() ?? '--',
              'sleepHours': data['sleepHours']?.toString() ?? '--',
              'mood': data['mood'] ?? 'Not specified',
              'energyLevel': data['energyLevel'] ?? 'Not specified',
              'symptoms': data['symptoms'] ?? '',
              'additionalNotes': data['additionalNotes'] ?? '',
              'hadContractions': data['hadContractions'] ?? false,
              'hadHeadaches': data['hadHeadaches'] ?? false,
              'hadSwelling': data['hadSwelling'] ?? false,
              'tookVitamins': data['tookVitamins'] ?? false,
              'waterIntake': data['waterIntake']?.toString() ?? '--',
              'exerciseMinutes': data['exerciseMinutes']?.toString() ?? '--',
              'appetiteLevel': data['appetiteLevel'] ?? 'Not specified',
              'painLevel': data['painLevel'] ?? 'Not specified',
              'medications': data['medications'] ?? '',
              'nauseaDetails': data['nauseaDetails'] ?? '',
              'riskLevel': data['riskLevel'] ?? '',
              'riskMessage': data['riskMessage'] ?? '',
            };
          }).toList();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patient logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E5F5),
            Color(0xFFFCE4EC),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFE91E63),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(log['logDate']),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C2C2C),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('hh:mm a').format(log['logDate']),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF757575),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Risk Alert Section
            if (log['riskLevel'] != null && (log['riskLevel'] as String).isNotEmpty) ...[
              _buildRiskAlert(context, log),
              const SizedBox(height: 16),
            ],

            // Vital Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    AppLocalizations.of(context)!.bloodPressure,
                    log['bloodPressure'],
                    Icons.favorite,
                    const Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    AppLocalizations.of(context)!.weight,
                    '${log['weight']} kg',
                    Icons.monitor_weight,
                    const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Second Row of Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    AppLocalizations.of(context)!.babyKicks,
                    log['babyKicks'],
                    Icons.child_friendly,
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    AppLocalizations.of(context)!.sleepHours,
                    '${log['sleepHours']} hrs',
                    Icons.bedtime,
                    const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Third Row of Stats
            Row(
              children: [
                if (log['waterIntake'] != null && log['waterIntake'] != '--') ...[
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.waterIntake,
                      '${log['waterIntake']} glasses',
                      Icons.local_drink,
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (log['exerciseMinutes'] != null && log['exerciseMinutes'] != '--') ...[
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.exerciseMinutes,
                      '${log['exerciseMinutes']} mins',
                      Icons.fitness_center,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Additional Health Indicators
            Row(
              children: [
                if (log['appetiteLevel'] != null && log['appetiteLevel'] != 'Not specified') ...[
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.appetiteLevel,
                      log['appetiteLevel'],
                      Icons.restaurant,
                      const Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (log['painLevel'] != null && log['painLevel'] != 'Not specified') ...[
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.painLevel,
                      log['painLevel'],
                      Icons.sick,
                      const Color(0xFFFF5722),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Mood and Energy
            Row(
              children: [
                Expanded(child: _buildMoodIndicator(context, log['mood'])),
                const SizedBox(width: 12),
                Expanded(child: _buildEnergyIndicator(context, log['energyLevel'])),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Information
            if (log['symptoms'] != null && (log['symptoms'] as String).isNotEmpty) ...[
              _buildInfoSection(
                AppLocalizations.of(context)!.symptoms,
                log['symptoms'],
                Icons.healing,
                const Color(0xFFFF5722),
              ),
              const SizedBox(height: 12),
            ],

            if (log['additionalNotes'] != null && (log['additionalNotes'] as String).isNotEmpty) ...[
              _buildInfoSection(
                AppLocalizations.of(context)!.notes,
                log['additionalNotes'],
                Icons.note,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 12),
            ],

            if (log['medications'] != null && (log['medications'] as String).isNotEmpty) ...[
              _buildInfoSection(
                AppLocalizations.of(context)!.medications,
                log['medications'],
                Icons.medication,
                const Color(0xFF2196F3),
              ),
              const SizedBox(height: 12),
            ],

            if (log['nauseaDetails'] != null && (log['nauseaDetails'] as String).isNotEmpty) ...[
              _buildInfoSection(
                AppLocalizations.of(context)!.nauseaDetails,
                log['nauseaDetails'],
                Icons.sick,
                const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 12),
            ],

            // Health Indicators
            _buildHealthIndicators(context, log),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAlert(BuildContext context, Map<String, dynamic> log) {
    Color getRiskColor(String riskLevel) {
      switch (riskLevel.toLowerCase()) {
        case 'high risk':
          return Colors.red;
        case 'moderate risk':
          return Colors.orange;
        case 'low risk':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    IconData getRiskIcon(String riskLevel) {
      switch (riskLevel.toLowerCase()) {
        case 'high risk':
          return Icons.warning;
        case 'moderate risk':
          return Icons.warning_amber;
        case 'low risk':
          return Icons.check_circle;
        default:
          return Icons.info;
      }
    }

    String getLocalizedRiskLevel(String riskLevel) {
      switch (riskLevel.toLowerCase()) {
        case 'high risk':
          return AppLocalizations.of(context)!.highRisk;
        case 'moderate risk':
          return AppLocalizations.of(context)!.moderateRisk;
        case 'low risk':
          return AppLocalizations.of(context)!.lowRisk;
        default:
          return riskLevel;
      }
    }

    final riskLevel = log['riskLevel'] ?? '';
    final riskMessage = log['riskMessage'] ?? '';
    final riskColor = getRiskColor(riskLevel);
    final riskIcon = getRiskIcon(riskLevel);
    final localizedRiskLevel = getLocalizedRiskLevel(riskLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(riskIcon, color: riskColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedRiskLevel,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  riskMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2C2C2C),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator(BuildContext context, String mood) {
    final moodData = {
      'Excellent': {
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.green,
        'localized': AppLocalizations.of(context)!.excellent,
      },
      'Good': {'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen, 'localized': AppLocalizations.of(context)!.good},
      'Okay': {'icon': Icons.sentiment_neutral, 'color': Colors.orange, 'localized': AppLocalizations.of(context)!.okay},
      'Low': {'icon': Icons.sentiment_dissatisfied, 'color': Colors.deepOrange, 'localized': AppLocalizations.of(context)!.low},
      'Anxious': {
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.red,
        'localized': AppLocalizations.of(context)!.anxious,
      },
    };

    final data = moodData[mood] ?? moodData['Good']!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (data['color']! as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'] as IconData,
              color: data['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mood,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                  ),
                ),
                Text(
                  data['localized'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyIndicator(BuildContext context, String energyLevel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.energy_savings_leaf,
              color: Color(0xFFFF9800),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.energy,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                  ),
                ),
                Text(
                  energyLevel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicators(BuildContext context, Map<String, dynamic> log) {
    final indicators = [
      {
        'label': AppLocalizations.of(context)!.contractions,
        'value': log['hadContractions'],
        'icon': Icons.pregnant_woman,
      },
      {'label': AppLocalizations.of(context)!.headaches, 'value': log['hadHeadaches'], 'icon': Icons.sick},
      {
        'label': AppLocalizations.of(context)!.swelling,
        'value': log['hadSwelling'],
        'icon': Icons.water_drop,
      },
      {
        'label': AppLocalizations.of(context)!.vitamins,
        'value': log['tookVitamins'],
        'icon': Icons.medication,
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: indicators.map((indicator) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: indicator['value'] as bool
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : const Color(0xFF757575).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: indicator['value'] as bool
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF757575),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                indicator['icon'] as IconData,
                color: indicator['value'] as bool
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF757575),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                indicator['label'] as String,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: indicator['value'] as bool
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigationBar() {
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
            _buildNavItem(context, Icons.home_filled, AppLocalizations.of(context)!.home, _currentIndex == 0),
            _buildNavItem(context, Icons.assignment_outlined, AppLocalizations.of(context)!.viewLog, _currentIndex == 1),
            _buildNavItem(context, Icons.calendar_today_outlined, AppLocalizations.of(context)!.appointments, _currentIndex == 2),
            _buildNavItem(context, Icons.menu_book_outlined, AppLocalizations.of(context)!.learn, _currentIndex == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    final index = _getIndexForLabel(context, label);
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FamilyHomeScreen()),
          );
        } else if (index == 1) {
          // Already on View Log, do nothing
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FamilyAppointmentsScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FamilyLearnScreen()),
          );
        }
      },
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

  int _getIndexForLabel(BuildContext context, String label) {
    final homeLabel = AppLocalizations.of(context)!.home;
    final viewLogLabel = AppLocalizations.of(context)!.viewLog;
    final appointmentsLabel = AppLocalizations.of(context)!.appointments;
    final learnLabel = AppLocalizations.of(context)!.learn;
    
    switch (label) {
      case 'Home':
        return 0;
      case 'View Log':
        return 1;
      case 'Appointments':
        return 2;
      case 'Contacts':
        return 3;
      case 'Learn':
        return 4;
      default:
        // Try localized versions
        if (label == homeLabel) return 0;
        if (label == viewLogLabel) return 1;
        if (label == appointmentsLabel) return 2;
        if (label == learnLabel) return 4;
        return -1;
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
              Color(0xFFFCE4EC),
              Color(0xFFE3F2FD),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 15,
              ),
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
                        AppLocalizations.of(context)!.safeMother,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FamilyProfileScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.person_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF3E5F5),
                            Color(0xFFFCE4EC),
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              color: Color(0xFFE91E63),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.patientHealthLogs(_linkedPatientName),
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.viewingRecentHealthUpdates,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_isLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ] else if (_linkedPatientLogs.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF3E5F5),
                              Color(0xFFFCE4EC),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              size: 64,
                              color: const Color(0xFFE91E63).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noHealthLogsYet,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.healthLogsWillAppear(_linkedPatientName),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        AppLocalizations.of(context)!.recentLogs,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._linkedPatientLogs.map((log) => _buildLogCard(log)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}