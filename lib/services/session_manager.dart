import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserType = 'userType';
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyLoginTime = 'loginTime';

  // User types
  static const String userTypePatient = 'patient';
  static const String userTypeDoctor = 'doctor';

  // Save login session
  static Future<void> saveLoginSession({
    required String userType,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserType, userType);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get user type
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Get login time
  static Future<DateTime?> getLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeString = prefs.getString(_keyLoginTime);
    if (loginTimeString != null) {
      return DateTime.parse(loginTimeString);
    }
    return null;
  }

  // Get user session info
  static Future<Map<String, dynamic>?> getUserSession() async {
    if (await isLoggedIn()) {
      return {
        'userType': await getUserType(),
        'userId': await getUserId(),
        'userName': await getUserName(),
        'userEmail': await getUserEmail(),
        'loginTime': await getLoginTime(),
      };
    }
    return null;
  }

  // Clear login session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyLoginTime);
  }

  // Update user profile information
  static Future<void> updateUserProfile({
    String? userName,
    String? userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (userName != null) {
      await prefs.setString(_keyUserName, userName);
    }
    if (userEmail != null) {
      await prefs.setString(_keyUserEmail, userEmail);
    }
  }

  // Check if session is valid (you can add more validation logic here)
  static Future<bool> isSessionValid() async {
    if (!await isLoggedIn()) {
      return false;
    }

    final loginTime = await getLoginTime();
    if (loginTime == null) {
      return false;
    }

    // Session is valid for 30 days (you can adjust this)
    final sessionDuration = DateTime.now().difference(loginTime);
    return sessionDuration.inDays < 30;
  }

  // Refresh session (extend login time)
  static Future<void> refreshSession() async {
    if (await isLoggedIn()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
    }
  }
}
