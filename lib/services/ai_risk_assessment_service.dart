import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/symptom_log.dart';
import 'notification_service.dart';

class AIRiskAssessmentService {
  static const String _apiKey = "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";
  static const String _apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  
  final NotificationService _notificationService = NotificationService();

  /// Analyzes symptom log and provides risk assessment
  Future<RiskAssessment> analyzeSymptoms(SymptomLog symptomLog) async {
    try {
      // STEP 1: Always perform clinical assessment first
      print('🩺 Step 1: Performing clinical assessment...');
      final clinicalAssessment = _performClinicalAssessment(symptomLog);
      
      // STEP 2: If clinical assessment shows HIGH risk, return immediately
      if (clinicalAssessment.riskLevel == RiskLevel.high) {
        print('🚨 Clinical assessment shows HIGH RISK - immediate action required!');
        return clinicalAssessment;
      }
      
      // STEP 3: Try AI analysis for additional insights (if clinical assessment is not high risk)
      print('🤖 Step 2: Attempting AI analysis for additional insights...');
      
      // Prepare symptom data for AI analysis
      final symptomPrompt = _buildSymptomPrompt(symptomLog);
      
      // Send to Groq AI for analysis
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'llama-3.1-70b-versatile', // Using more capable model for medical analysis
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': symptomPrompt,
            }
          ],
          'temperature': 0.1, // Low temperature for consistent medical analysis
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String aiResponse = data['choices'][0]['message']['content'];
        
        print('✅ AI analysis successful');
        
        // Parse AI response to extract risk assessment
        final aiAssessment = _parseRiskAssessment(aiResponse, symptomLog);
        
        // Use the higher risk level between clinical and AI assessment
        final finalAssessment = _combineAssessments(clinicalAssessment, aiAssessment);
        
        // Send push notification if high risk
        if (finalAssessment.riskLevel == RiskLevel.high) {
          await _sendHighRiskNotification(finalAssessment, symptomLog.patientId);
        }
        
        return finalAssessment;
      } else {
        print('❌ AI API Error: ${response.statusCode} - ${response.body}');
        // Return clinical assessment if AI fails
        return clinicalAssessment;
      }
    } catch (e) {
      print('Error in AI risk assessment: $e');
      // CRITICAL: Perform clinical assessment even when AI fails
      print('🩺 Performing clinical assessment as backup...');
      print('🔍 DEBUG: About to call _performClinicalAssessment');
      final backupAssessment = _performClinicalAssessment(symptomLog);
      print('🔍 DEBUG: Clinical assessment returned: ${backupAssessment.riskLevel.displayName}');
      return backupAssessment;
    }
  }

  String _getSystemPrompt() {
    return '''
You are a specialized AI medical assistant focused on pregnancy health risk assessment. 

Your task is to analyze pregnancy symptoms and provide a risk assessment with the following format:

RISK_LEVEL: [LOW/MODERATE/HIGH]
CONFIDENCE: [0.0-1.0]
MESSAGE: [Brief explanation of the risk assessment]
RECOMMENDATIONS: [List of specific recommendations]

CRITICAL RULES:
1. Always err on the side of caution - if uncertain, classify as MODERATE or HIGH risk
2. HIGH risk indicators include: severe bleeding, severe headaches with vision changes, severe abdominal pain, signs of preeclampsia (high BP + headaches + swelling), severe contractions before 37 weeks, no fetal movement for extended periods
3. MODERATE risk indicators include: persistent headaches, unusual swelling, moderate pain, irregular contractions, high blood pressure readings
4. LOW risk indicates normal pregnancy symptoms with no concerning patterns
5. Always recommend consulting healthcare provider for HIGH and MODERATE risks
6. Be specific and actionable in recommendations
7. Consider the combination of symptoms, not just individual symptoms
8. Pay attention to symptom severity and frequency

Analyze the following pregnancy symptoms and provide your assessment:
''';
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
    
    print('🎯 Clinical Assessment: ${riskLevel.displayName} (${(confidence * 100).toStringAsFixed(1)}%)');
    
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

  String _generateClinicalMessage(RiskLevel riskLevel, List<String> riskFactors, SymptomLog log) {
    switch (riskLevel) {
      case RiskLevel.high:
        String message = 'URGENT: HIGH RISK CONDITION DETECTED. ';
        if (riskFactors.isNotEmpty) {
          message += 'Critical factors identified: ${riskFactors.join(", ")}. ';
        }
        message += 'IMMEDIATE medical attention required. Contact your healthcare provider or go to the emergency room now.';
        return message;
        
      case RiskLevel.moderate:
        String message = 'MODERATE RISK: Your condition requires attention. ';
        if (riskFactors.isNotEmpty) {
          message += 'Concerning factors: ${riskFactors.join(", ")}. ';
        }
        message += 'Please schedule an appointment with your healthcare provider promptly.';
        return message;
        
      case RiskLevel.low:
        return 'Your symptoms appear to be within normal range for pregnancy. Continue monitoring and maintain regular prenatal care.';
    }
  }

  /// Combines clinical and AI assessments, using the higher risk level
  RiskAssessment _combineAssessments(RiskAssessment clinical, RiskAssessment ai) {
    // Use the higher risk level
    final RiskLevel finalRisk = _getHigherRiskLevel(clinical.riskLevel, ai.riskLevel);
    
    // Use higher confidence
    final double finalConfidence = clinical.confidence > ai.confidence ? clinical.confidence : ai.confidence;
    
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
    
    print('🔗 Combined Assessment: ${finalRisk.displayName} (${(finalConfidence * 100).toStringAsFixed(1)}%)');
    
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

  String _buildSymptomPrompt(SymptomLog log) {
    return '''
PATIENT SYMPTOM LOG ANALYSIS:

Basic Vitals:
- Blood Pressure: ${log.bloodPressure}
- Weight: ${log.weight}
- Baby Kicks: ${log.babyKicks}

Symptom Details:
- Primary Symptoms: ${log.symptoms}
- Pain Level: ${log.painLevel}
- Energy Level: ${log.energyLevel}
- Appetite Level: ${log.appetiteLevel}
- Mood: ${log.mood}

Critical Symptoms:
- Contractions: ${log.hadContractions ? 'YES' : 'NO'}
- Headaches: ${log.hadHeadaches ? 'YES' : 'NO'}
- Swelling: ${log.hadSwelling ? 'YES' : 'NO'}

Additional Information:
- Nausea Details: ${log.nauseaDetails ?? 'None reported'}
- Current Medications: ${log.medications ?? 'None reported'}
- Sleep Hours: ${log.sleepHours ?? 'Not specified'}
- Water Intake: ${log.waterIntake ?? 'Not specified'}
- Exercise Minutes: ${log.exerciseMinutes ?? 'Not specified'}
- Taking Vitamins: ${log.tookVitamins ? 'YES' : 'NO'}
- Additional Notes: ${log.additionalNotes ?? 'None'}

Please analyze these symptoms and provide a comprehensive risk assessment.
''';
  }

  RiskAssessment _parseRiskAssessment(String aiResponse, SymptomLog log) {
    try {
      print('🤖 AI Response: $aiResponse'); // Debug log
      
      RiskLevel riskLevel = RiskLevel.low;
      double confidence = 0.5;
      String message = '';
      List<String> recommendations = [];

      // First, check for manual high-risk indicators in blood pressure
      final bp = log.bloodPressure.trim();
      print('🩺 Analyzing blood pressure: "$bp"');
      
      if (bp.contains('/')) {
        final parts = bp.split('/');
        if (parts.length == 2) {
          final systolic = int.tryParse(parts[0].trim()) ?? 0;
          final diastolic = int.tryParse(parts[1].trim()) ?? 0;
          
          print('📊 Parsed BP values - Systolic: $systolic, Diastolic: $diastolic');
          
          // High blood pressure detection - CRITICAL OVERRIDE
          if (systolic >= 160 || diastolic >= 110) {
            riskLevel = RiskLevel.high;
            confidence = 0.95;
            print('🚨 CRITICAL: HIGH RISK - Blood pressure $bp is dangerously high!');
            print('🚨 Systolic ≥ 160 OR Diastolic ≥ 110 detected!');
          } else if (systolic >= 140 || diastolic >= 90) {
            riskLevel = RiskLevel.moderate;
            confidence = 0.85;
            print('⚠️ WARNING: MODERATE RISK - Elevated blood pressure $bp detected!');
            print('⚠️ Systolic ≥ 140 OR Diastolic ≥ 90 detected!');
          } else {
            print('✅ Blood pressure $bp is within acceptable range');
          }
        } else {
          print('❌ Invalid blood pressure format: $bp');
        }
      } else {
        print('❌ Blood pressure does not contain "/" separator: $bp');
      }

      // Check for critical symptoms
      if (log.hadContractions || log.hadHeadaches || log.hadSwelling) {
        if (riskLevel == RiskLevel.low) {
          riskLevel = RiskLevel.moderate;
          confidence = 0.8;
        }
      }

      // Parse AI response for additional insights
      final lines = aiResponse.split('\n');
      
      for (String line in lines) {
        line = line.trim();
        
        // Look for risk indicators in the response
        final lowerLine = line.toLowerCase();
        if (lowerLine.contains('high risk') || lowerLine.contains('urgent') || 
            lowerLine.contains('immediate') || lowerLine.contains('emergency')) {
          riskLevel = RiskLevel.high;
          confidence = 0.9;
        } else if (lowerLine.contains('moderate') || lowerLine.contains('elevated') || 
                   lowerLine.contains('concerning')) {
          if (riskLevel == RiskLevel.low) {
            riskLevel = RiskLevel.moderate;
            confidence = 0.75;
          }
        }
        
        if (line.startsWith('RISK_LEVEL:')) {
          final level = line.split(':')[1].trim().toUpperCase();
          switch (level) {
            case 'HIGH':
              riskLevel = RiskLevel.high;
              confidence = 0.9;
              break;
            case 'MODERATE':
              riskLevel = RiskLevel.moderate;
              confidence = 0.8;
              break;
            default:
              // Keep existing risk level if already elevated
              if (riskLevel == RiskLevel.low) {
                riskLevel = RiskLevel.low;
                confidence = 0.7;
              }
          }
        } else if (line.startsWith('CONFIDENCE:')) {
          final parsedConfidence = double.tryParse(line.split(':')[1].trim());
          if (parsedConfidence != null) {
            confidence = parsedConfidence;
          }
        } else if (line.startsWith('MESSAGE:')) {
          message = line.split(':').skip(1).join(':').trim();
        } else if (line.startsWith('RECOMMENDATIONS:')) {
          final recommendationText = line.split(':').skip(1).join(':').trim();
          if (recommendationText.isNotEmpty) {
            recommendations.add(recommendationText);
          }
        } else if (line.startsWith('-') && recommendations.isNotEmpty) {
          recommendations.add(line.substring(1).trim());
        }
      }

      // Generate message based on risk level and symptoms
      if (message.isEmpty) {
        message = _generateRiskMessage(riskLevel, log);
      }

      if (recommendations.isEmpty) {
        recommendations = _getDefaultRecommendations(riskLevel);
      }

      print('🎯 Final Risk Assessment: ${riskLevel.toString().split('.').last.toUpperCase()} (${(confidence * 100).toStringAsFixed(1)}%)');

      final assessment = RiskAssessment(
        riskLevel: riskLevel,
        message: message,
        recommendations: recommendations,
        confidence: confidence,
        analysisDate: DateTime.now(),
      );

      // Send notification for high risk
      if (riskLevel == RiskLevel.high) {
        print('🚨 HIGH RISK DETECTED - Sending notification!');
        _notificationService.sendHighRiskAlert(
          patientId: log.patientId,
          riskLevel: riskLevel,
          message: message,
        );
      }

      return assessment;
    } catch (e) {
      print('Error parsing AI response: $e');
      return RiskAssessment(
        riskLevel: RiskLevel.moderate,
        message: 'Analysis completed. Please review your symptoms with a healthcare provider.',
        recommendations: _getDefaultRecommendations(RiskLevel.moderate),
        confidence: 0.3,
        analysisDate: DateTime.now(),
      );
    }
  }

  String _generateRiskMessage(RiskLevel riskLevel, SymptomLog log) {
    switch (riskLevel) {
      case RiskLevel.high:
        String message = 'HIGH RISK DETECTED: Your symptoms require immediate medical attention. ';
        if (log.bloodPressure.contains('/')) {
          final parts = log.bloodPressure.split('/');
          final systolic = int.tryParse(parts[0].trim()) ?? 0;
          if (systolic >= 160) {
            message += 'Your blood pressure (${log.bloodPressure}) is dangerously high. ';
          }
        }
        if (log.hadContractions) message += 'Contractions may indicate preterm labor. ';
        if (log.hadHeadaches && log.hadSwelling) message += 'Headaches with swelling may indicate preeclampsia. ';
        message += 'Please contact your healthcare provider or go to the emergency room immediately.';
        return message;
        
      case RiskLevel.moderate:
        String message = 'MODERATE RISK: Your symptoms need attention. ';
        if (log.bloodPressure.contains('/')) {
          final parts = log.bloodPressure.split('/');
          final systolic = int.tryParse(parts[0].trim()) ?? 0;
          if (systolic >= 140) {
            message += 'Your blood pressure (${log.bloodPressure}) is elevated. ';
          }
        }
        if (log.hadHeadaches) message += 'Frequent headaches should be monitored. ';
        if (log.hadSwelling) message += 'Swelling may indicate fluid retention. ';
        message += 'Please schedule an appointment with your healthcare provider soon.';
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

  Future<void> _sendHighRiskNotification(RiskAssessment assessment, String patientId) async {
    try {
      await _notificationService.sendHighRiskAlert(
        patientId: patientId,
        riskLevel: assessment.riskLevel,
        message: assessment.message,
      );
      print('High risk notification sent for patient: $patientId');
    } catch (e) {
      print('Error sending high risk notification: $e');
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