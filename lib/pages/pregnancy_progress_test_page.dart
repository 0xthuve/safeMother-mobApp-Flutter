import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../widgets/pregnancy_progress_widget.dart';
import '../utils/demo_data_initializer.dart';

class PregnancyProgressTestPage extends StatefulWidget {
  const PregnancyProgressTestPage({Key? key}) : super(key: key);

  @override
  State<PregnancyProgressTestPage> createState() => _PregnancyProgressTestPageState();
}

class _PregnancyProgressTestPageState extends State<PregnancyProgressTestPage> {
  final BackendService _backendService = BackendService();
  Map<String, dynamic>? _progressData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAndTest();
  }

  Future<void> _initializeAndTest() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize demo data
      await DemoDataInitializer.initializeAllDemoData();
      
      // Get pregnancy progress
      await _loadProgressData();
      
    } catch (e) {
      print('Error initializing: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProgressData() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final progress = await _backendService.calculatePregnancyProgress(userId);
        setState(() {
          _progressData = progress;
        });
      }
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> _updatePregnancyWeek(int newWeek) async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        // Update the pregnancy week for testing
        await _backendService.updatePregnancyTracking(userId, {
          'currentWeek': newWeek,
          'currentDay': 0,
          'trimester': _getTrimester(newWeek),
        });
        
        // Reload progress data
        await _loadProgressData();
      }
    } catch (e) {
      print('Error updating pregnancy week: $e');
    }
  }

  String _getTrimester(int week) {
    if (week <= 12) return 'First';
    if (week <= 28) return 'Second';
    return 'Third';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Progress Test'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Controls',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _updatePregnancyWeek(8),
                          child: const Text('Week 8'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _updatePregnancyWeek(20),
                          child: const Text('Week 20'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _updatePregnancyWeek(32),
                          child: const Text('Week 32'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadProgressData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Data'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Progress Widget
            const PregnancyProgressWidget(showRefreshButton: true),
            
            const SizedBox(height: 24),
            
            // Raw Progress Data
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raw Progress Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_progressData != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _progressData!.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    '${entry.key}:',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Text('No progress data available'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Calculation Explanation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Pregnancy completion % = (current week / 40) × 100',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Remaining days = 280 - (current week × 7 + current day)',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Progress bar shows visual completion percentage',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Circular progress indicator matches linear progress',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}