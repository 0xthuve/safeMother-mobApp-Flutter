import 'package:flutter/material.dart';
import '../models/symptom_log.dart';
import '../utils/connectivity_checker.dart';
import '../utils/offline_storage.dart';
import '../utils/toast_service.dart';
import 'notification_service.dart';
import 'risk_predictor.dart';

class AIRiskAssessmentService {
  final NotificationService _notificationService = NotificationService();
  final RiskPredictor _riskPredictor = RiskPredictor();

  /// Analyzes symptom log and provides risk assessment
  Future<RiskAssessment> analyzeSymptoms(SymptomLog symptomLog) async {
    try {
      // STEP 1: Always perform clinical assessment first (offline capable)
      print('🩺 Step 1: Performing clinical assessment...');
      final clinicalAssessment = _performClinicalAssessment(symptomLog);

      // STEP 2: If clinical assessment shows HIGH risk, show alert immediately
      if (clinicalAssessment.riskLevel == RiskLevel.high) {
        print(
            '🚨 Clinical assessment shows HIGH RISK - immediate action required!');

        // First priority: Show the alert immediately
        bool notificationShown = await _notificationService.sendHighRiskAlert(
          patientId: symptomLog.patientId,
          riskLevel: clinicalAssessment.riskLevel,
          message: clinicalAssessment.message,
        );

        if (!notificationShown) {
          // If notification failed, try one more time after a short delay
          await Future.delayed(Duration(milliseconds: 500));
          notificationShown = await _notificationService.sendHighRiskAlert(
            patientId: symptomLog.patientId,
            riskLevel: clinicalAssessment.riskLevel,
            message: clinicalAssessment.message,
          );
        }

        // Save assessment data in background
        _sendHighRiskNotification(clinicalAssessment, symptomLog.patientId)
            .catchError((e) {
          print('Error saving assessment data: $e');
          // Error is caught but we still return assessment
        });

        return clinicalAssessment;
      }

      // STEP 3: Try local TensorFlow Lite prediction
      print('🤖 Step 2: Running local TensorFlow Lite prediction...');

      // Load model if not already loaded
      if (!_riskPredictor.isModelLoaded) {
        try {
          print('🔄 Loading TensorFlow Lite model...');
          await _riskPredictor.loadModel();
          print('✅ Model loaded successfully');
        } catch (e) {
          print('❌ Error loading model: $e');
          await ToastService.showError(
            'Unable to load risk assessment model. Using clinical assessment only.',
          );
          // Return clinical assessment as fallback
          return clinicalAssessment;
        }
      }

      // Prepare input data for model
      print('📊 Preparing symptom data for model...');
      final List<double> modelInput = _prepareModelInput(symptomLog);

      // Get prediction from TensorFlow Lite model
      final double riskScore = await _riskPredictor.predictRisk(modelInput);
      final String riskLabel = _riskPredictor.getRiskLabel(riskScore);

      print(
          '✅ TFLite prediction successful: score=$riskScore, label=$riskLabel');

      // Convert prediction to risk assessment
      final modelAssessment =
          _convertPredictionToAssessment(riskScore, symptomLog);

      // Use the higher risk level between clinical and model assessment
      final finalAssessment =
          _combineAssessments(clinicalAssessment, modelAssessment);

      // If high risk, send notification locally first
      if (finalAssessment.riskLevel == RiskLevel.high) {
        await _sendHighRiskNotification(finalAssessment, symptomLog.patientId);
      }

      return finalAssessment;
    } catch (e) {
      print('Error in risk assessment: $e');
      // CRITICAL: Perform clinical assessment as backup
      print('🩺 Performing clinical assessment as backup...');
      print('🔍 DEBUG: About to call _performClinicalAssessment');
      final backupAssessment = _performClinicalAssessment(symptomLog);
      print(
          '🔍 DEBUG: Clinical assessment returned: ${backupAssessment.riskLevel.displayName}');

      // If high risk during backup assessment, ensure local notification
      if (backupAssessment.riskLevel == RiskLevel.high) {
        await _sendHighRiskNotification(backupAssessment, symptomLog.patientId);
      }

      return backupAssessment;
    }
  }

  /// Prepares symptom data for model input
  List<double> _prepareModelInput(SymptomLog log) {
    return [
      _parseBloodPressure(log.bloodPressure),
      _parseDouble(log.weight),
      _parseDouble(log.painLevel),
      _parseDouble(log.babyKicks),
      _parseDouble(log.energyLevel),
      _parseDouble(log.appetiteLevel),
      log.hadContractions ? 1.0 : 0.0,
      log.hadHeadaches ? 1.0 : 0.0,
      log.hadSwelling ? 1.0 : 0.0,
      _parseDouble(log.sleepHours),
      _parseDouble(log.waterIntake),
      _parseDouble(log.exerciseMinutes),
      log.tookVitamins ? 1.0 : 0.0,
    ];
  }

  /// Safely converts a dynamic value to double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse blood pressure string to numeric value
  double _parseBloodPressure(String bp) {
    if (bp.contains('/')) {
      final parts = bp.split('/');
      if (parts.length == 2) {
        final systolic = double.tryParse(parts[0].trim()) ?? 0.0;
        final diastolic = double.tryParse(parts[1].trim()) ?? 0.0;
        // Use mean arterial pressure as a single value
        return (systolic + 2 * diastolic) / 3;
      }
    }
    return 0.0;
  }

  /// Converts model prediction to risk assessment
  RiskAssessment _convertPredictionToAssessment(double score, SymptomLog log) {
    final RiskLevel riskLevel = score <= 0.5
        ? RiskLevel.low
        : (score <= 0.75 ? RiskLevel.moderate : RiskLevel.high);

    final String message = _generateRiskMessage(riskLevel, log);
    final List<String> recommendations = _getDefaultRecommendations(riskLevel);

    return RiskAssessment(
      riskLevel: riskLevel,
      message: message,
      recommendations: recommendations,
      confidence:
          score > 0.5 ? score : 1 - score, // Convert score to confidence
      analysisDate: DateTime.now(),
    );
  }

  /// Performs clinical assessment based on medical guidelines
  RiskAssessment _performClinicalAssessment(SymptomLog log) {
    print('🔍 DEBUG: _performClinicalAssessment STARTED');
    RiskLevel riskLevel = RiskLevel.low;
    double confidence = 0.7;
    List<String> riskFactors = [];

    // Critical blood pressure assessment
    final bp = log.bloodPressure.trim();
    print('🩺 Clinical BP Analysis: "$bp"');

    if (bp.contains('/')) {
      final parts = bp.split('/');
      if (parts.length == 2) {
        final systolic = int.tryParse(parts[0].trim()) ?? 0;
        final diastolic = int.tryParse(parts[1].trim()) ?? 0;

        print('📊 BP Values: Systolic=$systolic, Diastolic=$diastolic');

        if (systolic >= 180 || diastolic >= 120) {
          riskLevel = RiskLevel.high;
          confidence = 0.98;
          riskFactors.add('Hypertensive Crisis (BP: $bp)');
          print('🚨 HYPERTENSIVE CRISIS: BP $bp is life-threatening!');
        } else if (systolic >= 160 || diastolic >= 110) {
          riskLevel = RiskLevel.high;
          confidence = 0.95;
          riskFactors.add('Stage 2 Hypertension (BP: $bp)');
          print('🚨 HIGH RISK: Stage 2 Hypertension detected');
        } else if (systolic >= 140 || diastolic >= 90) {
          riskLevel = RiskLevel.moderate;
          confidence = 0.85;
          riskFactors.add('Stage 1 Hypertension (BP: $bp)');
          print('⚠️ MODERATE RISK: Stage 1 Hypertension');
        } else {
          print('✅ Blood pressure within normal range');
        }
      }
    }

    // Critical symptom combinations (Preeclampsia indicators)
    if (log.hadHeadaches && log.hadSwelling) {
      if (riskLevel == RiskLevel.low) {
        riskLevel = RiskLevel.moderate;
        confidence = 0.8;
      }
      riskFactors.add('Headaches with swelling (possible preeclampsia)');
      print('⚠️ Preeclampsia symptoms detected');
    }

    // Contractions assessment
    if (log.hadContractions) {
      if (riskLevel == RiskLevel.low) {
        riskLevel = RiskLevel.moderate;
        confidence = 0.8;
      }
      riskFactors.add('Uterine contractions');
      print('⚠️ Contractions reported');
    }

    // Generate clinical message
    String message = _generateClinicalMessage(riskLevel, riskFactors, log);
    List<String> recommendations = _getDefaultRecommendations(riskLevel);

    print(
        '🎯 Clinical Assessment: ${riskLevel.displayName} (${(confidence * 100).toStringAsFixed(1)}%)');

    final assessment = RiskAssessment(
      riskLevel: riskLevel,
      message: message,
      recommendations: recommendations,
      confidence: confidence,
      analysisDate: DateTime.now(),
    );

    // Send notification for high risk
    if (riskLevel == RiskLevel.high) {
      print('🚨 HIGH RISK - Sending emergency notification!');
      _notificationService.sendHighRiskAlert(
        patientId: log.patientId,
        riskLevel: riskLevel,
        message: message,
      );
    }

    return assessment;
  }

  String _generateClinicalMessage(
      RiskLevel riskLevel, List<String> riskFactors, SymptomLog log) {
    switch (riskLevel) {
      case RiskLevel.high:
        String message = 'URGENT: HIGH RISK CONDITION DETECTED. ';
        if (riskFactors.isNotEmpty) {
          message += 'Critical factors identified: ${riskFactors.join(", ")}. ';
        }
        message +=
            'IMMEDIATE medical attention required. Contact your healthcare provider or go to the emergency room now.';
        return message;

      case RiskLevel.moderate:
        String message = 'MODERATE RISK: Your condition requires attention. ';
        if (riskFactors.isNotEmpty) {
          message += 'Concerning factors: ${riskFactors.join(", ")}. ';
        }
        message +=
            'Please schedule an appointment with your healthcare provider promptly.';
        return message;

      case RiskLevel.low:
        return 'Your symptoms appear to be within normal range for pregnancy. Continue monitoring and maintain regular prenatal care.';
    }
  }

  /// Combines clinical and AI assessments, using the higher risk level
  RiskAssessment _combineAssessments(
      RiskAssessment clinical, RiskAssessment ai) {
    // Use the higher risk level
    final RiskLevel finalRisk =
        _getHigherRiskLevel(clinical.riskLevel, ai.riskLevel);

    // Use higher confidence
    final double finalConfidence = clinical.confidence > ai.confidence
        ? clinical.confidence
        : ai.confidence;

    // Combine messages
    String finalMessage = '';
    if (finalRisk == clinical.riskLevel) {
      finalMessage = clinical.message;
      if (ai.message.isNotEmpty && ai.message != clinical.message) {
        finalMessage += ' AI Analysis: ${ai.message}';
      }
    } else {
      finalMessage = ai.message;
      if (clinical.message.isNotEmpty) {
        finalMessage += ' Clinical Assessment: ${clinical.message}';
      }
    }

    // Combine recommendations (remove duplicates)
    final Set<String> allRecommendations = {};
    allRecommendations.addAll(clinical.recommendations);
    allRecommendations.addAll(ai.recommendations);

    print(
        '🔗 Combined Assessment: ${finalRisk.displayName} (${(finalConfidence * 100).toStringAsFixed(1)}%)');

    return RiskAssessment(
      riskLevel: finalRisk,
      message: finalMessage,
      recommendations: allRecommendations.toList(),
      confidence: finalConfidence,
      analysisDate: DateTime.now(),
    );
  }

  RiskLevel _getHigherRiskLevel(RiskLevel level1, RiskLevel level2) {
    final riskOrder = [RiskLevel.low, RiskLevel.moderate, RiskLevel.high];
    final index1 = riskOrder.indexOf(level1);
    final index2 = riskOrder.indexOf(level2);
    return index1 > index2 ? level1 : level2;
  }

  String _generateRiskMessage(RiskLevel riskLevel, SymptomLog log) {
    switch (riskLevel) {
      case RiskLevel.high:
        String message =
            'HIGH RISK DETECTED: Your symptoms require immediate medical attention. ';
        if (log.bloodPressure.contains('/')) {
          final parts = log.bloodPressure.split('/');
          final systolic = int.tryParse(parts[0].trim()) ?? 0;
          if (systolic >= 160) {
            message +=
                'Your blood pressure (${log.bloodPressure}) is dangerously high. ';
          }
        }
        if (log.hadContractions)
          message += 'Contractions may indicate preterm labor. ';
        if (log.hadHeadaches && log.hadSwelling)
          message += 'Headaches with swelling may indicate preeclampsia. ';
        message +=
            'Please contact your healthcare provider or go to the emergency room immediately.';
        return message;

      case RiskLevel.moderate:
        String message = 'MODERATE RISK: Your symptoms need attention. ';
        if (log.bloodPressure.contains('/')) {
          final parts = log.bloodPressure.split('/');
          final systolic = int.tryParse(parts[0].trim()) ?? 0;
          if (systolic >= 140) {
            message +=
                'Your blood pressure (${log.bloodPressure}) is elevated. ';
          }
        }
        if (log.hadHeadaches)
          message += 'Frequent headaches should be monitored. ';
        if (log.hadSwelling)
          message += 'Swelling may indicate fluid retention. ';
        message +=
            'Please schedule an appointment with your healthcare provider soon.';
        return message;

      case RiskLevel.low:
        return 'Your symptoms appear to be within normal range for pregnancy. Continue your regular prenatal care and monitor any changes.';
    }
  }

  List<String> _getDefaultRecommendations(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.high:
        return [
          'Contact your healthcare provider immediately',
          'Monitor symptoms closely',
          'Seek emergency care if symptoms worsen',
          'Do not delay medical attention'
        ];
      case RiskLevel.moderate:
        return [
          'Schedule an appointment with your healthcare provider',
          'Monitor symptoms and keep a detailed log',
          'Rest and stay hydrated',
          'Contact provider if symptoms worsen'
        ];
      case RiskLevel.low:
        return [
          'Continue regular prenatal care',
          'Maintain healthy lifestyle habits',
          'Monitor symptoms as usual',
          'Discuss at next routine appointment'
        ];
    }
  }

  Future<void> _sendHighRiskNotification(
      RiskAssessment assessment, String patientId) async {
    try {
      // First, always try to save locally regardless of connectivity
      try {
        await OfflineStorage().saveSymptomLog(
          SymptomLog(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            patientId: patientId,
            bloodPressure: "120/80", // Default value
            weight: "0",
            babyKicks: "0",
            mood: "Unknown",
            symptoms: "High Risk Alert",
            energyLevel: "Normal",
            appetiteLevel: "Normal",
            painLevel: "None",
            hadContractions: false,
            hadHeadaches: false,
            hadSwelling: false,
            tookVitamins: false,
            logDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            // Risk assessment data
            riskLevel: assessment.riskLevel.toString(),
            riskMessage: assessment.message,
            riskRecommendations: assessment.recommendations,
            riskConfidence: assessment.confidence,
            riskAnalysisDate: assessment.analysisDate,
          ),
        );
        print('✅ Assessment saved locally');
      } catch (e) {
        print('Error saving assessment locally: $e');
        await ToastService.showError(
          'Unable to save assessment data. Please try again.',
        );
        // Continue execution to at least show the notification
      }

      // Show local notification for immediate alert
      try {
        await _notificationService.sendHighRiskAlert(
          patientId: patientId,
          riskLevel: assessment.riskLevel,
          message: assessment.message,
        );
        print('🔔 Local high risk notification shown for patient: $patientId');
      } catch (e) {
        print('Error showing local notification: $e');
        await ToastService.showError(
          'Unable to show notification. Please check your notification settings.',
        );
      }

      // Check internet connectivity for cloud sync
      bool hasInternet = await ConnectivityChecker().hasInternetConnection();
      if (!hasInternet) {
        print('📴 No internet connection detected');
        await ToastService.showInfo(
          'No internet connection. Assessment saved locally and will sync when online.',
        );
        return;
      }

      // If we have internet, additional cloud operations can be performed here
      print(
          '✅ High risk notification processing completed for patient: $patientId');
    } catch (e) {
      print('❌ Critical error in notification processing: $e');
      await ToastService.showError(
        'A problem occurred. Please ensure your device has notification permissions enabled.',
      );
    }
  }
}

/// Risk assessment result from AI analysis
class RiskAssessment {
  final RiskLevel riskLevel;
  final String message;
  final List<String> recommendations;
  final double confidence;
  final DateTime analysisDate;

  RiskAssessment({
    required this.riskLevel,
    required this.message,
    required this.recommendations,
    required this.confidence,
    required this.analysisDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'riskLevel': riskLevel.toString(),
      'message': message,
      'recommendations': recommendations,
      'confidence': confidence,
      'analysisDate': analysisDate.toIso8601String(),
    };
  }

  factory RiskAssessment.fromMap(Map<String, dynamic> map) {
    return RiskAssessment(
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.toString() == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      message: map['message'] ?? '',
      recommendations: List<String>.from(map['recommendations'] ?? []),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      analysisDate: DateTime.parse(map['analysisDate']),
    );
  }
}

/// Risk levels for pregnancy symptoms
enum RiskLevel {
  low,
  moderate,
  high,
}

extension RiskLevelExtension on RiskLevel {
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return const Color(0xFF4CAF50); // Green
      case RiskLevel.moderate:
        return const Color(0xFFFF9800); // Orange
      case RiskLevel.high:
        return const Color(0xFFF44336); // Red
    }
  }
}
