import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/symptom_log.dart';

class OfflineStorage {
  static final OfflineStorage _instance = OfflineStorage._internal();
  factory OfflineStorage() => _instance;
  OfflineStorage._internal();

  static const String _pendingLogsKey = 'pending_symptom_logs';
  final _prefs = SharedPreferences.getInstance();

  /// Save symptom log locally
  Future<void> saveSymptomLog(SymptomLog log) async {
    try {
      final prefs = await _prefs;
      List<String> pendingLogs = prefs.getStringList(_pendingLogsKey) ?? [];

      // Add new log
      pendingLogs.add(jsonEncode(log.toMap()));

      // Save updated list
      await prefs.setStringList(_pendingLogsKey, pendingLogs);
      print('✅ Symptom log saved locally');
    } catch (e) {
      print('Error saving symptom log locally: $e');
      rethrow;
    }
  }

  /// Get all pending logs that need to be synced
  Future<List<SymptomLog>> getPendingLogs() async {
    try {
      final prefs = await _prefs;
      List<String> pendingLogs = prefs.getStringList(_pendingLogsKey) ?? [];

      return pendingLogs.map((logJson) {
        Map<String, dynamic> map = jsonDecode(logJson);
        return SymptomLog.fromMap(map);
      }).toList();
    } catch (e) {
      print('Error getting pending logs: $e');
      return [];
    }
  }

  /// Remove a log after successful sync
  Future<void> removePendingLog(String logId) async {
    try {
      final prefs = await _prefs;
      List<String> pendingLogs = prefs.getStringList(_pendingLogsKey) ?? [];

      pendingLogs.removeWhere((logJson) {
        Map<String, dynamic> map = jsonDecode(logJson);
        return map['id'] == logId;
      });

      await prefs.setStringList(_pendingLogsKey, pendingLogs);
    } catch (e) {
      print('Error removing pending log: $e');
    }
  }

  /// Get number of pending logs
  Future<int> getPendingLogsCount() async {
    try {
      final prefs = await _prefs;
      List<String> pendingLogs = prefs.getStringList(_pendingLogsKey) ?? [];
      return pendingLogs.length;
    } catch (e) {
      print('Error getting pending logs count: $e');
      return 0;
    }
  }
}
