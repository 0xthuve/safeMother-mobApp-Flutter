import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';

class PregnancyProgressWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final bool showRefreshButton;
  
  const PregnancyProgressWidget({
    super.key,
    this.onTap,
    this.showRefreshButton = false,
  });

  @override
  State<PregnancyProgressWidget> createState() => _PregnancyProgressWidgetState();
}

class _PregnancyProgressWidgetState extends State<PregnancyProgressWidget> {
  final BackendService _backendService = BackendService();
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPregnancyProgress();
  }

  Future<void> _loadPregnancyProgress() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final progress = await _backendService.calculatePregnancyProgress(userId);
        setState(() {
          _progressData = progress;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading pregnancy progress: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF3E5F5).withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[50]!,
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
          ),
        ),
      );
    }

    if (_progressData == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF3E5F5).withOpacity(0.8),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.favorite,
              color: Color(0xFFE91E63),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Start Your Pregnancy Journey',
              style: TextStyle(
                color: Color(0xFF7B1FA2),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your pregnancy details to start tracking',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to pregnancy setup
                // This would typically navigate to a pregnancy setup form
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Setup Pregnancy Tracking',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final weeks = _progressData!['weeks'] as int;
    final days = _progressData!['days'] as int;
    final percentage = _progressData!['percentage'] as double;
    final trimester = _progressData!['trimester'] as String;
    final weeksRemaining = _progressData!['weeksRemaining'] as int;
    final daysRemaining = _progressData!['daysRemaining'] as int? ?? 0;
    final totalDays = _progressData!['totalDays'] as int? ?? 0;
    final babyName = _progressData!['babyName'] as String;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF3E5F5).withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[50]!,
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your Pregnancy Journey',
                style: TextStyle(
                  color: Color(0xFF7B1FA2),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (widget.showRefreshButton)
                IconButton(
                  onPressed: _loadPregnancyProgress,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFF7B1FA2),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$trimester Trimester',
                  style: const TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress circle
              Container(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFFF3E5F5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$weeks',
                          style: const TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'weeks',
                          style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Progress details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$babyName is growing!',
                      style: const TextStyle(
                        color: Color(0xFF111611),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$weeks weeks and $days days',
                      style: const TextStyle(
                        color: Color(0xFF638763),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$weeksRemaining weeks to go',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$daysRemaining days remaining',
                      style: const TextStyle(
                        color: Color(0xFFE91E63),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Progress bar
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}% complete',
                          style: const TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Day $totalDays of 280',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Baby development info (mock data based on week)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.child_care,
                      color: Color(0xFFE91E63),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'This Week',
                      style: TextStyle(
                        color: Color(0xFF7B1FA2),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getBabyDevelopmentText(weeks),
                  style: const TextStyle(
                    color: Color(0xFF5A5A5A),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _getBabyDevelopmentText(int weeks) {
    if (weeks < 4) {
      return 'Your baby is just beginning to develop. The fertilized egg is implanting in your uterus.';
    } else if (weeks < 8) {
      return 'Your baby\'s heart is starting to beat and major organs are beginning to form.';
    } else if (weeks < 12) {
      return 'Your baby is now about the size of a lime and all major organs are formed.';
    } else if (weeks < 16) {
      return 'Your baby can now make facial expressions and may even be sucking their thumb.';
    } else if (weeks < 20) {
      return 'Your baby is about the size of a banana and you might start feeling movement soon.';
    } else if (weeks < 24) {
      return 'Your baby\'s hearing is developing and they can hear your voice and heartbeat.';
    } else if (weeks < 28) {
      return 'Your baby\'s eyes can now open and close, and they may have hiccups.';
    } else if (weeks < 32) {
      return 'Your baby is gaining weight rapidly and their bones are hardening.';
    } else if (weeks < 36) {
      return 'Your baby\'s lungs are maturing and they\'re getting ready for life outside the womb.';
    } else {
      return 'Your baby is full-term and ready to meet you! They could arrive any day now.';
    }
  }
}