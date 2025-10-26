import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/symptom_log.dart';
import '../services/backend_service.dart';
import 'toast_service.dart';

class OfflineStorage {
  static final OfflineStorage _instance = OfflineStorage._internal();
  factory OfflineStorage() => _instance;
  OfflineStorage._internal();

  static const String _pendingLogsKey = 'pending_symptom_logs';
  final _prefs = SharedPreferences.getInstance();
  final Connectivity _connectivity = Connectivity();
  
  bool _autoSyncStarted = false;
  bool _syncInProgress = false;

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
      // Start auto-sync listener so saved logs get uploaded when connectivity
      // returns.
      startAutoSync();
    } catch (e) {
      print('Error saving symptom log locally: $e');
      rethrow;
    }
  }

  /// Begin listening for connectivity changes and attempt to sync pending
  /// logs when internet becomes available. Safe to call multiple times.
  void startAutoSync() {
    if (_autoSyncStarted) return;
    _autoSyncStarted = true;
    _connectivity.onConnectivityChanged.listen((result) async {
      try {
        if (result != ConnectivityResult.none) {
          await _syncOnce();
        }
      } catch (e) {
        print('Error during auto-sync connectivity handler: $e');
      }
    }, onError: (e) {
      print('Connectivity stream error in startAutoSync: $e');
    });
  }

  Future<void> _syncOnce() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      await syncPendingLogs();
    } catch (e) {
      print('Error syncing pending logs: $e');
    } finally {
      _syncInProgress = false;
    }
  }

  /// Try to upload all pending logs to backend. Removes local entries on
  /// successful remote save.
  Future<void> syncPendingLogs() async {
    final pending = await getPendingLogs();
    if (pending.isEmpty) return;

    int successCount = 0;
    final backend = BackendService();

    for (final log in pending) {
      try {
        final remoteId = await backend.saveSymptomLog(log);
        if (remoteId != null) {
          // Remove local copy only if remote save returned an id
          await removePendingLog(log.id ?? '');
          successCount++;
        }
      } catch (e) {
        print('Error uploading pending log ${log.id}: $e');
      }
    }

    if (successCount > 0) {
      await ToastService.showSuccess('Uploaded $successCount pending log(s).');
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
