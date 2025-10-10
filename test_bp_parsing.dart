void main() {
  print('Testing Blood Pressure Parsing Logic...\n');
  
  // Test cases
  final testCases = [
    '200/180',  // High risk
    '160/110',  // High risk
    '150/95',   // Moderate risk
    '140/90',   // Moderate risk
    '130/85',   // Normal-high
    '120/80',   // Normal  
    '110/70',   // Normal
  ];
  
  for (String bp in testCases) {
    print('Testing BP: $bp');
    
    if (bp.contains('/')) {
      final parts = bp.split('/');
      if (parts.length == 2) {
        final systolic = int.tryParse(parts[0].trim()) ?? 0;
        final diastolic = int.tryParse(parts[1].trim()) ?? 0;
        
        String riskLevel = 'LOW';
        double confidence = 0.7;
        
        // High blood pressure detection
        if (systolic >= 160 || diastolic >= 110) {
          riskLevel = 'HIGH';
          confidence = 0.95;
        } else if (systolic >= 140 || diastolic >= 90) {
          riskLevel = 'MODERATE';
          confidence = 0.85;
        }
        
        print('  Systolic: $systolic, Diastolic: $diastolic');
        print('  Risk Level: $riskLevel (${(confidence * 100).toStringAsFixed(1)}% confidence)');
        
        if (riskLevel == 'HIGH') {
          print('  🚨 HIGH RISK DETECTED - Notification would be sent!');
        }
      }
    }
    print('');
  }
  
  print('Blood pressure parsing test completed!');
}