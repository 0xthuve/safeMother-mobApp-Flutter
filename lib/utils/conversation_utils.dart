import 'package:firebase_auth/firebase_auth.dart';

class ConversationUtils {
  /// Creates a standardized conversation ID using doctor Firebase UID and patient ID
  /// Format: doctorFirebaseUid_patientId
  static String createConversationId(String patientId, String doctorUid) {
    return '${doctorUid}_$patientId';
  }

  /// Gets the current user's Firebase UID
  static Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// Sanitizes email for use in conversation IDs (legacy support)
  static String sanitizeEmail(String email) {
    return email
        .replaceAll('.', '_DOT_')
        .replaceAll('@', '_AT_')
        .replaceAll('#', '_HASH_')
        .replaceAll('\$', '_DOLLAR_')
        .replaceAll('[', '_LBRACKET_')
        .replaceAll(']', '_RBRACKET_');
  }
}