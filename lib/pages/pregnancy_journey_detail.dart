import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../l10n/app_localizations.dart';

class PregnancyJourneyDetailPage extends StatefulWidget {
  const PregnancyJourneyDetailPage({super.key});

  @override
  State<PregnancyJourneyDetailPage> createState() => _PregnancyJourneyDetailPageState();
}

class _PregnancyJourneyDetailPageState extends State<PregnancyJourneyDetailPage> {
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

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7B1FA2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.pregnancyJourney ?? 'Pregnancy Journey',
          style: const TextStyle(
            color: Color(0xFF7B1FA2),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF7B1FA2)),
            onPressed: _loadPregnancyProgress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
              ),
            )
          : _progressData == null
              ? _buildSetupView()
              : _buildJourneyView(),
    );
  }

  Widget _buildSetupView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              color: Color(0xFFE91E63),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.setupYourPregnancyJourney ?? 'Setup Your Pregnancy Journey',
              style: const TextStyle(
                color: Color(0xFF7B1FA2),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.completePregnancyDetails ?? 'Complete your pregnancy details in your profile to start tracking your journey.',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyView() {
    final weeks = _progressData!['weeks'] as int;
    final days = _progressData!['days'] as int;
    final percentage = _progressData!['percentage'] as double;
    final trimester = _progressData!['trimester'] as String;

    final daysRemaining = _progressData!['daysRemaining'] as int;
    final totalDays = _progressData!['totalDays'] as int;
    final babyName = _progressData!['babyName'] as String;
    final isOverdue = _progressData!['isOverdue'] as bool;
    final expectedDeliveryDateStr = _progressData!['expectedDeliveryDate'] as String?;

    DateTime? expectedDeliveryDate;
    if (expectedDeliveryDateStr != null) {
      try {
        expectedDeliveryDate = DateTime.parse(expectedDeliveryDateStr);
      } catch (e) {
        // Invalid date format, will use null
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main progress card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE91E63).withOpacity(0.1),
                  const Color(0xFF7B1FA2).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE91E63).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Large progress circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 12,
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
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'WEEKS',
                            style: TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$days days',
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Progress stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Progress', '${percentage.toStringAsFixed(1)}%'),
                    _buildStatColumn('Total Days', '$totalDays'),
                    _buildStatColumn('Remaining', '$daysRemaining days'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Due date card
          if (expectedDeliveryDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple[50]!,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFE91E63),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOverdue ? 'Due Date (Overdue)' : 'Expected Due Date',
                          style: TextStyle(
                            color: isOverdue ? Colors.orange : const Color(0xFF7B1FA2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(expectedDeliveryDate),
                          style: TextStyle(
                            color: isOverdue ? Colors.orange : const Color(0xFF7B1FA2),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isOverdue)
                          const Text(
                            'Baby can arrive any time now!',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Trimester progress
          _buildTrimesterProgress(trimester, weeks),
          
          const SizedBox(height: 24),
          
          // Complete milestone timeline
          _buildCompleteTimeline(weeks),
          
          const SizedBox(height: 24),
          
          // Baby development details
          _buildBabyDevelopment(weeks, babyName),
          
          const SizedBox(height: 24),
          
          // Weekly tips
          _buildWeeklyTips(weeks),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF7B1FA2),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9575CD),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTrimesterProgress(String trimester, int weeks) {
    double progress = 0.0;
    String progressText = '';
    
    if (trimester == 'First') {
      progress = (weeks / 12.0).clamp(0.0, 1.0);
      progressText = 'Week $weeks of 12';
    } else if (trimester == 'Second') {
      progress = ((weeks - 12) / 16.0).clamp(0.0, 1.0);
      progressText = 'Week ${weeks - 12} of 16';
    } else {
      progress = ((weeks - 28) / 12.0).clamp(0.0, 1.0);
      progressText = 'Week ${weeks - 28} of 12';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[50]!,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$trimester Trimester Progress',
            style: const TextStyle(
              color: Color(0xFF7B1FA2),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressText,
            style: const TextStyle(
              color: Color(0xFF9575CD),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteTimeline(int weeks) {
    List<Map<String, dynamic>> milestones = [
      {'week': 4, 'title': 'Heart Begins Beating', 'description': 'Your baby\'s heart starts to beat', 'icon': Icons.favorite},
      {'week': 8, 'title': 'All Major Organs', 'description': 'All major organs are now formed', 'icon': Icons.psychology},
      {'week': 12, 'title': 'End of First Trimester', 'description': 'Risk of miscarriage decreases significantly', 'icon': Icons.celebration},
      {'week': 16, 'title': 'Gender Determination', 'description': 'Baby\'s gender can be determined', 'icon': Icons.child_care},
      {'week': 20, 'title': 'Halfway Point', 'description': 'You\'re halfway through your pregnancy!', 'icon': Icons.star},
      {'week': 24, 'title': 'Viability Milestone', 'description': 'Baby has a good chance of survival if born', 'icon': Icons.security},
      {'week': 28, 'title': 'Eyes Can Open', 'description': 'Baby\'s eyes can open and close', 'icon': Icons.visibility},
      {'week': 32, 'title': 'Rapid Weight Gain', 'description': 'Baby is gaining weight rapidly', 'icon': Icons.trending_up},
      {'week': 36, 'title': 'Considered Full-Term', 'description': 'Baby is now considered full-term', 'icon': Icons.baby_changing_station},
      {'week': 40, 'title': 'Due Date', 'description': 'Your estimated due date arrives!', 'icon': Icons.cake},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[50]!,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pregnancy Milestones',
            style: TextStyle(
              color: Color(0xFF7B1FA2),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ...milestones.map((milestone) {
            final isCompleted = weeks >= milestone['week'];
            final isCurrent = weeks >= milestone['week'] - 1 && weeks <= milestone['week'] + 1;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? const Color(0xFFE91E63)
                          : isCurrent
                              ? const Color(0xFFE91E63).withOpacity(0.3)
                              : const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(20),
                      border: isCurrent && !isCompleted
                          ? Border.all(color: const Color(0xFFE91E63), width: 2)
                          : null,
                    ),
                    child: Icon(
                      milestone['icon'] as IconData,
                      color: isCompleted 
                          ? Colors.white
                          : isCurrent
                              ? const Color(0xFFE91E63)
                              : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Week ${milestone['week']}',
                              style: TextStyle(
                                color: isCompleted || isCurrent 
                                    ? const Color(0xFFE91E63)
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (isCurrent && !isCompleted)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          milestone['title'] as String,
                          style: TextStyle(
                            color: isCompleted || isCurrent 
                                ? const Color(0xFF7B1FA2)
                                : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          milestone['description'] as String,
                          style: TextStyle(
                            color: isCompleted || isCurrent 
                                ? const Color(0xFF5A5A5A)
                                : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBabyDevelopment(int weeks, String babyName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[50]!,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.child_care,
                  color: Color(0xFFE91E63),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$babyName\'s Development',
                style: const TextStyle(
                  color: Color(0xFF7B1FA2),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getDetailedBabyDevelopmentText(weeks),
            style: const TextStyle(
              color: Color(0xFF5A5A5A),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF7B1FA2),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getBabySizeComparison(weeks),
                    style: const TextStyle(
                      color: Color(0xFF7B1FA2),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTips(int weeks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[50]!,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Color(0xFFE91E63),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'This Week\'s Tips',
                style: TextStyle(
                  color: Color(0xFF7B1FA2),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getWeeklyTips(weeks),
            style: const TextStyle(
              color: Color(0xFF5A5A5A),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _getDetailedBabyDevelopmentText(int weeks) {
    if (weeks < 4) {
      return 'Your baby is just beginning to develop. The fertilized egg has implanted in your uterus and cell division is happening rapidly. The foundation for all major organs is being laid.';
    } else if (weeks < 8) {
      return 'Your baby\'s heart is starting to beat! Major organs like the brain, spinal cord, and digestive system are beginning to form. Tiny limb buds that will become arms and legs are appearing.';
    } else if (weeks < 12) {
      return 'Your baby is now about the size of a lime. All major organs are formed and functioning. Fingernails and toenails are developing, and your baby can make small movements.';
    } else if (weeks < 16) {
      return 'Your baby can now make facial expressions and may even be sucking their thumb. The skeletal system is developing, and you might be able to find out the gender soon.';
    } else if (weeks < 20) {
      return 'Your baby is about the size of a banana. You might start feeling movement soon! The baby\'s senses are developing, and they can hear sounds from outside the womb.';
    } else if (weeks < 24) {
      return 'Your baby\'s hearing is developing rapidly, and they can hear your voice and heartbeat. The lungs are forming, and brain development is accelerating.';
    } else if (weeks < 28) {
      return 'Your baby\'s eyes can now open and close, and they may have hiccups that you can feel. The brain is developing rapidly, and fat is being deposited under the skin.';
    } else if (weeks < 32) {
      return 'Your baby is gaining weight rapidly and their bones are hardening. The lungs are maturing, and the baby is practicing breathing movements.';
    } else if (weeks < 36) {
      return 'Your baby\'s lungs are maturing quickly and they\'re getting ready for life outside the womb. Most of the major development is complete, and now it\'s mainly about gaining weight.';
    } else {
      return 'Your baby is full-term and ready to meet you! They could arrive any day now. The lungs are fully mature and ready for breathing air.';
    }
  }

  String _getBabySizeComparison(int weeks) {
    if (weeks < 4) return 'Your baby is about the size of a poppy seed.';
    if (weeks < 8) return 'Your baby is about the size of a blueberry.';
    if (weeks < 12) return 'Your baby is about the size of a lime.';
    if (weeks < 16) return 'Your baby is about the size of an avocado.';
    if (weeks < 20) return 'Your baby is about the size of a banana.';
    if (weeks < 24) return 'Your baby is about the size of an ear of corn.';
    if (weeks < 28) return 'Your baby is about the size of an eggplant.';
    if (weeks < 32) return 'Your baby is about the size of a coconut.';
    if (weeks < 36) return 'Your baby is about the size of a pineapple.';
    return 'Your baby is about the size of a watermelon.';
  }

  String _getWeeklyTips(int weeks) {
    if (weeks < 8) {
      return 'Take prenatal vitamins with folic acid. Avoid alcohol, smoking, and certain medications. Get plenty of rest and stay hydrated.';
    } else if (weeks < 16) {
      return 'Schedule your first prenatal appointment. Start eating small, frequent meals to help with nausea. Begin gentle exercise if approved by your doctor.';
    } else if (weeks < 24) {
      return 'Consider prenatal classes. Start talking and singing to your baby. Monitor your weight gain and maintain a healthy diet rich in calcium and protein.';
    } else if (weeks < 32) {
      return 'Start planning for maternity leave. Consider a babymoon trip. Practice relaxation techniques and prepare for your baby shower.';
    } else {
      return 'Pack your hospital bag. Prepare your nursery. Practice breathing exercises and finalize your birth plan with your healthcare provider.';
    }
  }
}
