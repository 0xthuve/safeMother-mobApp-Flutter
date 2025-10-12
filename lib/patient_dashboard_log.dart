import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import 'models/symptom_log.dart';
import 'models/doctor_alert.dart';
import 'services/backend_service.dart';
import 'services/ai_risk_assessment_service.dart';
import 'bottom_navigation.dart';
import 'navigation_handler.dart';

class PatientDashboardLog extends StatefulWidget {
  @override
  _PatientDashboardLogState createState() => _PatientDashboardLogState();
}

class _PatientDashboardLogState extends State<PatientDashboardLog> {
  final _formKey = GlobalKey<FormState>();
  final BackendService _backendService = BackendService();
  final AIRiskAssessmentService _aiService = AIRiskAssessmentService();
  final int _currentIndex = 1; // This is the Log tab (index 1)

  // Form controllers
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _waterIntakeController = TextEditingController();
  final _exerciseMinutesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _nauseaController = TextEditingController();

  // Form data
  int _babyKicks = 0;
  String _mood = 'Good';
  String _energyLevel = 'Normal';
  String _appetiteLevel = 'Normal';
  String _painLevel = 'None';
  bool _hadContractions = false;
  bool _hadHeadaches = false;
  bool _hadSwelling = false;
  bool _tookVitamins = false;
  bool _isLoading = false;
  List<SymptomLog> _recentLogs = [];

  final List<String> _moodOptions = [
    'Excellent',
    'Good',
    'Okay',
    'Low',
    'Anxious',
  ];

  final List<String> _energyLevelOptions = [
    'Very High',
    'High',
    'Normal',
    'Low',
    'Very Low',
  ];

  final List<String> _appetiteLevelOptions = [
    'Excellent',
    'Good',
    'Normal',
    'Poor',
    'None',
  ];

  final List<String> _painLevelOptions = [
    'None',
    'Mild',
    'Moderate',
    'Severe',
    'Extreme',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecentLogs();
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _bloodPressureController.dispose();
    _weightController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _sleepHoursController.dispose();
    _waterIntakeController.dispose();
    _exerciseMinutesController.dispose();
    _medicationsController.dispose();
    _nauseaController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  Future<void> _loadRecentLogs() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final logs = await _backendService.getRecentSymptomLogs(user.uid);
      setState(() {
        _recentLogs = logs;
      });
    } catch (e) {
      print('Error loading recent logs: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      var symptomLog = SymptomLog(
        patientId: user.uid,
        bloodPressure: _bloodPressureController.text,
        weight: _weightController.text,
        babyKicks: _babyKicks.toString(),
        mood: _mood,
        symptoms: _symptomsController.text,
        additionalNotes: _notesController.text,
        sleepHours: _sleepHoursController.text,
        waterIntake: _waterIntakeController.text,
        exerciseMinutes: _exerciseMinutesController.text,
        energyLevel: _energyLevel,
        appetiteLevel: _appetiteLevel,
        painLevel: _painLevel,
        hadContractions: _hadContractions,
        hadHeadaches: _hadHeadaches,
        hadSwelling: _hadSwelling,
        tookVitamins: _tookVitamins,
        nauseaDetails: _nauseaController.text,
        medications: _medicationsController.text,
        logDate: now,
        createdAt: now,
        updatedAt: now,
      );

      // Save to database first
      final logId = await _backendService.saveSymptomLog(symptomLog);
      if (logId != null) {
        symptomLog = symptomLog.copyWith(id: logId);
      }

      // Perform AI risk assessment
      print('🤖 Starting AI risk assessment...');
      print('📊 Blood Pressure: ${symptomLog.bloodPressure}');
      print('💡 Symptoms: ${symptomLog.symptoms}');
      print('🚨 Critical flags: Contractions=${symptomLog.hadContractions}, Headaches=${symptomLog.hadHeadaches}, Swelling=${symptomLog.hadSwelling}');
      
      final riskAssessment = await _aiService.analyzeSymptoms(symptomLog);
      
      print('🎯 AI Assessment Result: ${riskAssessment.riskLevel.displayName}');
      print('📈 Confidence: ${(riskAssessment.confidence * 100).toStringAsFixed(1)}%');
      print('💬 Message: ${riskAssessment.message}');
      
      // Update symptom log with risk assessment
      if (symptomLog.id != null) {
        await _backendService.updateSymptomLogWithRiskAssessment(
          symptomLog.id!,
          {
            'riskLevel': riskAssessment.riskLevel.displayName,
            'riskMessage': riskAssessment.message,
            'riskRecommendations': riskAssessment.recommendations,
            'riskConfidence': riskAssessment.confidence,
            'riskAnalysisDate': DateTime.now().toIso8601String(),
          }
        );
      }
      
      // Create doctor alerts for high-risk cases
      await _handleHighRiskAlert(symptomLog, riskAssessment);
      
      // Show result to user
      _showRiskAssessmentDialog(riskAssessment);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString(context, 'healthInformationSaved')),
          backgroundColor: const Color(0xFF7B1FA2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _resetForm();
      _loadRecentLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getLocalizedString(context, 'errorSavingHealthInfo')}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _bloodPressureController.clear();
    _weightController.clear();
    _symptomsController.clear();
    _notesController.clear();
    _sleepHoursController.clear();
    _waterIntakeController.clear();
    _exerciseMinutesController.clear();
    _medicationsController.clear();
    _nauseaController.clear();
    setState(() {
      _babyKicks = 0;
      _mood = 'Good';
      _energyLevel = 'Normal';
      _appetiteLevel = 'Normal';
      _painLevel = 'None';
      _hadContractions = false;
      _hadHeadaches = false;
      _hadSwelling = false;
      _tookVitamins = false;
    });
  }

  void _showRiskAssessmentDialog(RiskAssessment assessment) {
    showDialog(
      context: context,
      barrierDismissible: false, // Important health information
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: assessment.riskLevel.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRiskIcon(assessment.riskLevel),
                  color: assessment.riskLevel.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getLocalizedString(context, 'healthAssessment'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: assessment.riskLevel.color,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Risk Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: assessment.riskLevel.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assessment.riskLevel.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // AI Message
                Text(
                  _getLocalizedString(context, 'assessmentResults'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assessment.message,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                
                const SizedBox(height: 16),
                
                // Recommendations
                if (assessment.recommendations.isNotEmpty) ...[
                  Text(
                    _getLocalizedString(context, 'recommendations'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...assessment.recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(fontSize: 14, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                const SizedBox(height: 16),
                
                // Confidence and timestamp
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Analysis confidence: ${(assessment.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (assessment.riskLevel == RiskLevel.high) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getLocalizedString(context, 'highRiskDetected'),
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (assessment.riskLevel == RiskLevel.high)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showContactDoctorDialog();
                },
                icon: const Icon(Icons.phone, color: Colors.red),
                label: Text(
                  _getLocalizedString(context, 'contactDoctor'),
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getLocalizedString(context, 'close')),
            ),
          ],
        );
      },
    );
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.moderate:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  /// Handle high-risk alerts by creating doctor notifications
  Future<void> _handleHighRiskAlert(SymptomLog symptomLog, RiskAssessment riskAssessment) async {
    if (riskAssessment.riskLevel != RiskLevel.high) return;

    try {
      print('🚨 Creating doctor alerts for high-risk case...');
      
      // Get patient name
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final patientName = user.displayName ?? 'Unknown Patient';
      
      // Get linked doctors
      final linkedDoctors = await _backendService.getLinkedDoctorsWithContact(symptomLog.patientId);
      print('🔍 Found ${linkedDoctors.length} linked doctors');
      
      for (final doctor in linkedDoctors) {
        // Use firebaseUid if available, otherwise fall back to id
        final doctorId = doctor['firebaseUid'] ?? doctor['id'];
        print('🔍 Creating alert for doctor: ${doctor['name']} (ID: $doctorId, firebaseUid: ${doctor['firebaseUid']})');
        
        final alert = DoctorAlert(
          patientId: symptomLog.patientId,
          patientName: patientName,
          doctorId: doctorId,
          riskLevel: riskAssessment.riskLevel.displayName,
          riskMessage: riskAssessment.message,
          riskFactors: riskAssessment.recommendations,
          bloodPressure: symptomLog.bloodPressure,
          symptoms: [symptomLog.symptoms],
          alertDate: DateTime.now(),
          symptomLogId: symptomLog.id,
        );
        
        await _backendService.saveDoctorAlert(alert);
        print('✅ Created alert for doctor: ${doctor['name']} with doctorId: $doctorId');
      }
      
      // TEMPORARY: Also create test alert for current doctor (Firebase UID: 0AludVmmD2OXGCn1i3M5UElBMSG2)
      // This ensures at least one alert appears in the dashboard for testing
      final testAlert = DoctorAlert(
        patientId: symptomLog.patientId,
        patientName: patientName,
        doctorId: '0AludVmmD2OXGCn1i3M5UElBMSG2', // Use actual Firebase UID
        riskLevel: riskAssessment.riskLevel.displayName,
        riskMessage: riskAssessment.message,
        riskFactors: riskAssessment.recommendations,
        bloodPressure: symptomLog.bloodPressure,
        symptoms: [symptomLog.symptoms],
        alertDate: DateTime.now(),
        symptomLogId: symptomLog.id,
      );
      
      await _backendService.saveDoctorAlert(testAlert);
      print('✅ Created TEST alert for current doctor with Firebase UID: 0AludVmmD2OXGCn1i3M5UElBMSG2');
      
      print('🏥 Created ${linkedDoctors.length} doctor alerts');
    } catch (e) {
      print('❌ Error creating doctor alerts: $e');
    }
  }

  /// Show contact doctor dialog with linked doctors
  void _showContactDoctorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                _getLocalizedString(context, 'contactYourDoctors'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 300),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getLinkedDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      _getLocalizedString(context, 'errorLoadingDoctors'),
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  );
                }
                
                final doctors = snapshot.data ?? [];
                
                if (doctors.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getLocalizedString(context, 'noDoctorsLinked'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getLocalizedString(context, 'linkDoctorFirst'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: doctors.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.local_hospital,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      title: Text(
                        doctor['name'] ?? 'Unknown Doctor',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor['specialization'] ?? 'General Practice'),
                          Text(
                            doctor['hospital'] ?? 'Hospital',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () => _makePhoneCall(doctor['phoneNumber']),
                        icon: Icon(
                          Icons.phone,
                          color: Colors.green.shade600,
                        ),
                        tooltip: 'Call ${doctor['name']}',
                      ),
                      onTap: () => _makePhoneCall(doctor['phoneNumber']),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_getLocalizedString(context, 'close')),
            ),
          ],
        );
      },
    );
  }

  /// Get linked doctors for the current patient
  Future<List<Map<String, dynamic>>> _getLinkedDoctors() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      
      return await _backendService.getLinkedDoctorsWithContact(user.uid);
    } catch (e) {
      print('Error getting linked doctors: $e');
      return [];
    }
  }

  /// Make a phone call to the doctor
  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString(context, 'phoneNumberNotAvailable')),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      
      // For web, we'll show the number so user can call manually
      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_getLocalizedString(context, 'callDoctor')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_getLocalizedString(context, 'pleaseCallNumber')),
                const SizedBox(height: 8),
                SelectableText(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_getLocalizedString(context, 'close')),
              ),
            ],
          ),
        );
      } else {
        // For mobile, launch the phone app
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          throw 'Could not launch phone app';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLocalizedString(context, 'unableToMakeCall')),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _showHistoryPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B1FA2).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B1FA2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Color(0xFF7B1FA2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getLocalizedString(context, 'recentHealthLogs'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1B69),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Content
                Expanded(
                  child: _recentLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B1FA2).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.history_outlined,
                                  size: 50,
                                  color: Color(0xFF7B1FA2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _getLocalizedString(context, 'noHealthLogsYet'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D1B69),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getLocalizedString(context, 'startLoggingHealthData'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _recentLogs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final log = _recentLogs[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF5E8FF).withOpacity(0.3),
                                    const Color(0xFFF9F7F9).withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7B1FA2).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          color: Color(0xFF7B1FA2),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${log.logDate.day}/${log.logDate.month}/${log.logDate.year}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D1B69),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          log.mood,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Health metrics
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPopupLogInfoItem(
                                          Icons.favorite,
                                          _getLocalizedString(context, 'bpLabel'),
                                          log.bloodPressure,
                                          const Color(0xFF7B1FA2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildPopupLogInfoItem(
                                          Icons.monitor_weight,
                                          _getLocalizedString(context, 'weightLabel'),
                                          '${log.weight}kg',
                                          const Color(0xFF9C27B0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildPopupLogInfoItem(
                                          Icons.child_friendly,
                                          _getLocalizedString(context, 'kicksLabel'),
                                          log.babyKicks,
                                          const Color(0xFFFF9800),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildPopupLogInfoItem(
                                          Icons.bedtime,
                                          _getLocalizedString(context, 'sleepLabel'),
                                          '${log.sleepHours}h',
                                          const Color(0xFF3F51B5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (log.symptoms.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5722).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.healing,
                                            color: Color(0xFFFF5722),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${_getLocalizedString(context, 'symptomsLabel')}: ${log.symptoms}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF2D1B69),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  
                                  if (log.additionalNotes?.isNotEmpty == true) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.note_add,
                                            color: Color(0xFF4CAF50),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${_getLocalizedString(context, 'notesLabel')}: ${log.additionalNotes ?? ''}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF2D1B69),
                                              ),
                                            ),
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
                
                // Close button
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7B1FA2),
                        Color(0xFF9C27B0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _getLocalizedString(context, 'close'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(fontSize: 16, color: Color(0xFF2D1B69)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF666666), fontSize: 14),
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          filled: true,
          fillColor: Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF7B1FA2), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildKickCounter() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7B1FA2).withOpacity(0.1),
            Color(0xFF9C27B0).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF7B1FA2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.child_friendly, color: Color(0xFF7B1FA2)),
              ),
              SizedBox(width: 12),
              Text(
                _getLocalizedString(context, 'babyKicksCounter'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_babyKicks > 0) _babyKicks--;
                    });
                  },
                  icon: Icon(Icons.remove, color: Colors.red, size: 24),
                ),
              ),
              SizedBox(width: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7B1FA2).withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_babyKicks',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _babyKicks++;
                    });
                  },
                  icon: Icon(Icons.add, color: Colors.green, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moodIcons = {
      'Excellent': Icons.sentiment_very_satisfied,
      'Good': Icons.sentiment_satisfied,
      'Okay': Icons.sentiment_neutral,
      'Low': Icons.sentiment_dissatisfied,
      'Anxious': Icons.sentiment_very_dissatisfied,
    };

    final moodColors = {
      'Excellent': Colors.green,
      'Good': Colors.lightGreen,
      'Okay': Colors.orange,
      'Low': Colors.deepOrange,
      'Anxious': Colors.red,
    };

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moodColors[_mood]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(moodIcons[_mood], color: moodColors[_mood]),
              ),
              SizedBox(width: 12),
              Text(
                _getLocalizedString(context, 'howAreYouFeeling'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _moodOptions.map((mood) {
              final isSelected = _mood == mood;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _mood = mood;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (moodColors[mood] ?? Colors.grey)
                        : Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (moodColors[mood] ?? Colors.grey)
                          : Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        moodIcons[mood],
                        color: isSelected
                            ? Colors.white
                            : (moodColors[mood] ?? Colors.grey),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        mood,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF2D1B69),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF7B1FA2), width: 2),
              ),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  // Safe method to get localized strings
  String _getLocalizedString(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context);
    // Fallback English strings if localization is not available
    final fallbackStrings = {
      'healthLog': 'Health Log',
      'todaysHealthCheck': "Today's Health Check",
      'bloodPressureExample': 'Blood Pressure (e.g., 120/80)',
      'enterBloodPressure': 'Please enter your blood pressure',
      'weightKg': 'Weight (kg)',
      'enterWeight': 'Please enter your weight',
      'babyKicksCounter': 'Baby Kicks Counter',
      'howAreYouFeeling': 'How are you feeling?',
      'symptomsIfAny': 'Symptoms (if any)',
      'sleepHoursExample': 'Sleep Hours (e.g., 7.5)',
      'enterSleepHours': 'Please enter your sleep hours',
      'waterIntakeGlasses': 'Water Intake (glasses)',
      'enterWaterIntake': 'Please enter your water intake',
      'exerciseMinutesDaily': 'Exercise Minutes (daily)',
      'enterExerciseMinutes': 'Please enter your exercise minutes',
      'energyLevel': 'Energy Level',
      'appetiteLevel': 'Appetite Level',
      'painLevel': 'Pain Level',
      'healthIndicators': 'Health Indicators',
      'hadContractions': 'Had contractions',
      'hadHeadaches': 'Had headaches',
      'hadSwelling': 'Had swelling',
      'tookVitamins': 'Took prenatal vitamins',
      'nauseaDetailsIfAny': 'Nausea details (if any)',
      'currentMedications': 'Current medications',
      'additionalNotes': 'Additional notes',
      'saveHealthLog': 'Save Health Log',
      'recentHealthLogs': 'Recent Health Logs',
      'noHealthLogsYet': 'No health logs yet',
      'startLoggingHealthData': 'Start logging your health data to see your history here.',
      'close': 'Close',
      'bpLabel': 'BP',
      'weightLabel': 'Weight',
      'kicksLabel': 'Kicks',
      'sleepLabel': 'Sleep',
      'symptomsLabel': 'Symptoms',
      'notesLabel': 'Notes',
      'healthAssessment': 'Health Assessment',
      'assessmentResults': 'Assessment Results',
      'recommendations': 'Recommendations',
      'highRiskDetected': 'High risk detected - Please contact your doctor',
      'contactDoctor': 'Contact Doctor',
      'healthInformationSaved': 'Health information saved and analyzed successfully!',
      'errorSavingHealthInfo': 'Error saving health information',
      'contactYourDoctors': 'Contact Your Doctors',
      'errorLoadingDoctors': 'Error loading doctors',
      'noDoctorsLinked': 'No doctors linked',
      'linkDoctorFirst': 'Please link with a doctor first.',
      'phoneNumberNotAvailable': 'Phone number not available',
      'callDoctor': 'Call Doctor',
      'pleaseCallNumber': 'Please call this number:',
      'unableToMakeCall': 'Unable to make call',
    };
    if (localizations == null) {
      return fallbackStrings[key] ?? key;
    }

    // Use the actual localization methods
    switch (key) {
      case 'healthLog': return localizations.healthLog;
      case 'todaysHealthCheck': return localizations.todaysHealthCheck;
      case 'bloodPressureExample': return localizations.bloodPressureExample;
      case 'enterBloodPressure': return localizations.enterBloodPressure;
      case 'weightKg': return localizations.weightKg;
      case 'enterWeight': return localizations.enterWeight;
      case 'babyKicksCounter': return localizations.babyKicksCounter;
      case 'howAreYouFeeling': return localizations.howAreYouFeeling;
      case 'symptomsIfAny': return localizations.symptomsIfAny;
      case 'sleepHoursExample': return localizations.sleepHoursExample;
      case 'enterSleepHours': return localizations.enterSleepHours;
      case 'waterIntakeGlasses': return localizations.waterIntakeGlasses;
      case 'enterWaterIntake': return localizations.enterWaterIntake;
      case 'exerciseMinutesDaily': return localizations.exerciseMinutesDaily;
      case 'enterExerciseMinutes': return localizations.enterExerciseMinutes;
      case 'energyLevel': return localizations.energyLevel;
      case 'appetiteLevel': return localizations.appetiteLevel;
      case 'painLevel': return localizations.painLevel;
      case 'healthIndicators': return localizations.healthIndicators;
      case 'hadContractions': return localizations.hadContractions;
      case 'hadHeadaches': return localizations.hadHeadaches;
      case 'hadSwelling': return localizations.hadSwelling;
      case 'tookVitamins': return localizations.tookVitamins;
      case 'nauseaDetailsIfAny': return localizations.nauseaDetailsIfAny;
      case 'currentMedications': return localizations.currentMedications;
      case 'additionalNotes': return localizations.additionalNotes;
      case 'saveHealthLog': return localizations.saveHealthLog;
      case 'recentHealthLogs': return localizations.recentHealthLogs;
      case 'noHealthLogsYet': return localizations.noHealthLogsYet;
      case 'startLoggingHealthData': return localizations.startLoggingHealthData;
      case 'close': return localizations.close;
      case 'bpLabel': return localizations.bpLabel;
      case 'weightLabel': return localizations.weightLabel;
      case 'kicksLabel': return localizations.kicksLabel;
      case 'sleepLabel': return localizations.sleepLabel;
      case 'symptomsLabel': return fallbackStrings['symptomsLabel']!;
      case 'notesLabel': return fallbackStrings['notesLabel']!;
      case 'healthAssessment': return localizations.healthAssessment;
      case 'assessmentResults': return localizations.assessmentResults;
      case 'recommendations': return localizations.recommendations;
      case 'highRiskDetected': return localizations.highRiskDetected;
      case 'contactDoctor': return localizations.contactDoctor;
      case 'healthInformationSaved': return 'Health information saved and analyzed successfully!';
      case 'errorSavingHealthInfo': return 'Error saving health information';
      case 'contactYourDoctors': return localizations.contactYourDoctors;
      case 'errorLoadingDoctors': return 'Error loading doctors';
      case 'noDoctorsLinked': return localizations.noDoctorsLinked;
      case 'linkDoctorFirst': return localizations.linkDoctorFirst;
      case 'phoneNumberNotAvailable': return localizations.phoneNumberNotAvailable;
      case 'callDoctor': return localizations.callDoctor;
      case 'pleaseCallNumber': return localizations.pleaseCallNumber;
      case 'unableToMakeCall': return 'Unable to make call';
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF5E8FF),
                  Color(0xFFF9F7F9),
                ], // Soft lavender to off-white
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative shapes
          Positioned(
            top: -50,
            left: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(
                    0xFFD1C4E9,
                  ).withOpacity(0.4), // Soft lavender
                ),
              ),
            ),
          ),

          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1BEE7).withOpacity(0.3), // Light purple
              ),
            ),
          ),

          Positioned(
            right: -60,
            bottom: -90,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(
                    0xFFC5CAE9,
                  ).withOpacity(0.3), // Soft blue-purple
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button and history icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigate back to dashboard (index 0)
                          NavigationHandler.navigateToScreen(context, 0);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                      Text(
                        _getLocalizedString(context, 'healthLog'),
                        style: TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: _showHistoryPopup,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B1FA2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: Color(0xFF7B1FA2),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Health Log Form Content
                  Container(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Health Log Form
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7B1FA2).withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF7B1FA2,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.health_and_safety,
                                        color: Color(0xFF7B1FA2),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      _getLocalizedString(context, 'todaysHealthCheck'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D1B69),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Blood Pressure
                                _buildCustomTextField(
                                  controller: _bloodPressureController,
                                  label: _getLocalizedString(context, 'bloodPressureExample'),
                                  icon: Icons.favorite,
                                  iconColor: Color(0xFF7B1FA2),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _getLocalizedString(context, 'enterBloodPressure');
                                    }
                                    return null;
                                  },
                                ),

                                // Weight
                                _buildCustomTextField(
                                  controller: _weightController,
                                  label: _getLocalizedString(context, 'weightKg'),
                                  icon: Icons.monitor_weight,
                                  iconColor: Color(0xFF9C27B0),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _getLocalizedString(context, 'enterWeight');
                                    }
                                    return null;
                                  },
                                ),

                                // Baby Kicks Counter
                                _buildKickCounter(),

                                // Mood Selection
                                _buildMoodSelector(),

                                // Symptoms
                                _buildCustomTextField(
                                  controller: _symptomsController,
                                  label: _getLocalizedString(context, 'symptomsIfAny'),
                                  icon: Icons.healing,
                                  iconColor: Color(0xFFFF9800),
                                  maxLines: 2,
                                ),

                                // Sleep Hours
                                _buildCustomTextField(
                                  controller: _sleepHoursController,
                                  label: _getLocalizedString(context, 'sleepHoursExample'),
                                  icon: Icons.bedtime,
                                  iconColor: Color(0xFF3F51B5),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _getLocalizedString(context, 'enterSleepHours');
                                    }
                                    return null;
                                  },
                                ),

                                // Water Intake
                                _buildCustomTextField(
                                  controller: _waterIntakeController,
                                  label: _getLocalizedString(context, 'waterIntakeGlasses'),
                                  icon: Icons.local_drink,
                                  iconColor: Color(0xFF2196F3),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _getLocalizedString(context, 'enterWaterIntake');
                                    }
                                    return null;
                                  },
                                ),

                                // Exercise Minutes
                                _buildCustomTextField(
                                  controller: _exerciseMinutesController,
                                  label: _getLocalizedString(context, 'exerciseMinutesDaily'),
                                  icon: Icons.fitness_center,
                                  iconColor: Color(0xFF4CAF50),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _getLocalizedString(context, 'enterExerciseMinutes');
                                    }
                                    return null;
                                  },
                                ),

                                // Energy Level Selector
                                _buildDropdownSelector(
                                  title: _getLocalizedString(context, 'energyLevel'),
                                  options: _energyLevelOptions,
                                  selectedValue: _energyLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      _energyLevel = value;
                                    });
                                  },
                                  icon: Icons.battery_full,
                                  iconColor: Color(0xFFFF9800),
                                ),

                                // Appetite Level Selector
                                _buildDropdownSelector(
                                  title: _getLocalizedString(context, 'appetiteLevel'),
                                  options: _appetiteLevelOptions,
                                  selectedValue: _appetiteLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      _appetiteLevel = value;
                                    });
                                  },
                                  icon: Icons.restaurant,
                                  iconColor: Color(0xFFFF5722),
                                ),

                                // Pain Level Selector
                                _buildDropdownSelector(
                                  title: _getLocalizedString(context, 'painLevel'),
                                  options: _painLevelOptions,
                                  selectedValue: _painLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      _painLevel = value;
                                    });
                                  },
                                  icon: Icons.healing,
                                  iconColor: Color(0xFFE91E63),
                                ),

                                // Health Checkboxes Section
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5E8FF).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.checklist,
                                            color: Color(0xFF7B1FA2),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            _getLocalizedString(context, 'healthIndicators'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2D1B69),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      CheckboxListTile(
                                        title: Text(_getLocalizedString(context, 'hadContractions')),
                                        value: _hadContractions,
                                        onChanged: (value) {
                                          setState(() {
                                            _hadContractions = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),

                                      CheckboxListTile(
                                        title: Text(_getLocalizedString(context, 'hadHeadaches')),
                                        value: _hadHeadaches,
                                        onChanged: (value) {
                                          setState(() {
                                            _hadHeadaches = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),

                                      CheckboxListTile(
                                        title: Text(_getLocalizedString(context, 'hadSwelling')),
                                        value: _hadSwelling,
                                        onChanged: (value) {
                                          setState(() {
                                            _hadSwelling = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),

                                      CheckboxListTile(
                                        title: Text(_getLocalizedString(context, 'tookVitamins')),
                                        value: _tookVitamins,
                                        onChanged: (value) {
                                          setState(() {
                                            _tookVitamins = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                    ],
                                  ),
                                ),

                                // Nausea Details
                                _buildCustomTextField(
                                  controller: _nauseaController,
                                  label: _getLocalizedString(context, 'nauseaDetailsIfAny'),
                                  icon: Icons.sick,
                                  iconColor: Color(0xFF9C27B0),
                                  maxLines: 2,
                                ),

                                // Medications
                                _buildCustomTextField(
                                  controller: _medicationsController,
                                  label: _getLocalizedString(context, 'currentMedications'),
                                  icon: Icons.medication,
                                  iconColor: Color(0xFF607D8B),
                                  maxLines: 2,
                                ),

                                // Additional Notes
                                _buildCustomTextField(
                                  controller: _notesController,
                                  label: _getLocalizedString(context, 'additionalNotes'),
                                  icon: Icons.note_add,
                                  iconColor: Color(0xFF4CAF50),
                                  maxLines: 3,
                                ),

                                // Submit Button
                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF7B1FA2),
                                        Color(0xFF9C27B0),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF7B1FA2,
                                        ).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.save,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                _getLocalizedString(context, 'saveHealthLog'),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPopupLogInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D1B69),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}