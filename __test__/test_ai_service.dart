import 'dart:convert';
import '../lib/services/ai_risk_assessment_service.dart';
import '../lib/models/symptom_log.dart';

void main() async {
  print('🧪 Testing AI Risk Assessment Service...');
  
  final aiService = AIRiskAssessmentService();
  
  // Test Case 1: High risk - High blood pressure
  print('\n🔴 TEST CASE 1: HIGH RISK (Blood Pressure 200/180)');
  final highRiskSymptom = SymptomLog(
    patientId: 'test_user_001',
    bloodPressure: '200/180',
    weight: '75',
    babyKicks: 'Normal',
    mood: 'Anxious',
    symptoms: 'Severe headache, blurred vision, nausea',
    additionalNotes: 'Sudden onset of symptoms, feeling very unwell',
    sleepHours: '4',
    waterIntake: '1.5',
    exerciseMinutes: '0',
    energyLevel: 'Very Low',
    appetiteLevel: 'Poor',
    painLevel: 'Severe',
    hadContractions: false,
    hadHeadaches: true,
    hadSwelling: true,
    tookVitamins: true,
    nauseaDetails: 'Severe nausea with vomiting',
    medications: 'None',
    logDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  // Test Case 2: Moderate risk
  print('\n🟡 TEST CASE 2: MODERATE RISK (Blood Pressure 150/95)');
  final moderateRiskSymptom = SymptomLog(
    patientId: 'test_user_002',
    bloodPressure: '150/95',
    weight: '70',
    babyKicks: 'Reduced',
    mood: 'Worried',
    symptoms: 'Mild headache, some swelling',
    additionalNotes: 'Noticed symptoms getting worse over past few days',
    sleepHours: '6',
    waterIntake: '2',
    exerciseMinutes: '15',
    energyLevel: 'Low',
    appetiteLevel: 'Fair',
    painLevel: 'Mild',
    hadContractions: false,
    hadHeadaches: true,
    hadSwelling: true,
    tookVitamins: true,
    nauseaDetails: 'Mild nausea',
    medications: 'Prenatal vitamins',
    logDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  // Test Case 3: Low risk
  print('\n🟢 TEST CASE 3: LOW RISK (Normal Blood Pressure 120/80)');
  final lowRiskSymptom = SymptomLog(
    patientId: 'test_user_003',
    bloodPressure: '120/80',
    weight: '68',
    babyKicks: 'Normal',
    mood: 'Good',
    symptoms: 'No major symptoms, feeling well',
    additionalNotes: 'Regular checkup, everything seems normal',
    sleepHours: '8',
    waterIntake: '2.5',
    exerciseMinutes: '30',
    energyLevel: 'Good',
    appetiteLevel: 'Good',
    painLevel: 'None',
    hadContractions: false,
    hadHeadaches: false,
    hadSwelling: false,
    tookVitamins: true,
    nauseaDetails: null,
    medications: 'Prenatal vitamins',
    logDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  // Run all tests
  final testCases = [
    {'name': 'HIGH RISK', 'symptom': highRiskSymptom, 'icon': '🔴'},
    {'name': 'MODERATE RISK', 'symptom': moderateRiskSymptom, 'icon': '🟡'},
    {'name': 'LOW RISK', 'symptom': lowRiskSymptom, 'icon': '🟢'},
  ];
  
  for (var testCase in testCases) {
    final symptom = testCase['symptom'] as SymptomLog;
    final name = testCase['name'] as String;
    final icon = testCase['icon'] as String;
    
    try {
      print('\n$icon Testing $name...');
      print('Blood Pressure: ${symptom.bloodPressure}');
      print('Symptoms: ${symptom.symptoms}');
      print('Analyzing...');
      
      final assessment = await aiService.analyzeSymptoms(symptom);
      
      print('\n=== ASSESSMENT RESULTS ===');
      print('Risk Level: ${assessment.riskLevel.displayName}');
      print('Confidence: ${(assessment.confidence * 100).toStringAsFixed(1)}%');
      print('Message: ${assessment.message}');
      print('Recommendations:');
      for (var rec in assessment.recommendations) {
        print('  • $rec');
      }
      
      if (assessment.riskLevel == RiskLevel.high) {
        print('\n🚨 HIGH RISK DETECTED - Notification will be sent!');
      }
      
      print('\n' + '─' * 50);
      
    } catch (e) {
      print('❌ Error during analysis: $e');
    }
  }
  
  print('\n✅ AI Risk Assessment Testing Complete!');
}