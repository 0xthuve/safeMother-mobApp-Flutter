import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../pages/pregnancy_journey_detail.dart';
import '../l10n/app_localizations.dart';

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
            Text(
              AppLocalizations.of(context)!.startYourPregnancyJourney,
              style: const TextStyle(
                color: Color(0xFF7B1FA2),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.completePregnancyDetails,
              style: const TextStyle(
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
              child: Text(
                AppLocalizations.of(context)!.setupPregnancyTracking,
                style: const TextStyle(color: Colors.white),
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
    final expectedDeliveryDateStr = _progressData!['expectedDeliveryDate'] as String?;

    // Parse expected delivery date for better display
    DateTime? expectedDeliveryDate;
    if (expectedDeliveryDateStr != null) {
      try {
        expectedDeliveryDate = DateTime.parse(expectedDeliveryDateStr);
      } catch (e) {
        // Failed to parse date, use null
      }
    }

    return GestureDetector(
      onTap: widget.onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PregnancyJourneyDetailPage(),
          ),
        );
      },
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
            // Header with refresh and trimester badge - Responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 280;
                
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.yourPregnancyJourney,
                          style: const TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.showRefreshButton) ...[
                        const SizedBox(width: 8),
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
                      ],
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.trimesterLabel(trimester),
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout - stack vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.yourPregnancyJourney,
                              style: const TextStyle(
                                color: Color(0xFF7B1FA2),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
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
                      ),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 20),
            
            // Main progress section - Fixed responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we should use vertical or horizontal layout
                final isWide = constraints.maxWidth > 320;
                
                if (isWide) {
                  // Wide layout - use Row for larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Progress circle - fixed size
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 6,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.weeksLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF7B1FA2),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Content - flexible
                      Expanded(
                        child: _buildProgressContent(babyName, weeks, days, totalDays, weeksRemaining, daysRemaining, percentage),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout - use Column for smaller screens
                  return Column(
                    children: [
                      // Progress circle centered
                      SizedBox(
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
                                Text(
                                  AppLocalizations.of(context)!.weeksLabel,
                                  style: const TextStyle(
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
                      
                      const SizedBox(height: 16),
                      
                      // Content - full width
                      _buildProgressContent(babyName, weeks, days, totalDays, weeksRemaining, daysRemaining, percentage),
                    ],
                  );
                }
              },
            ),
            
            const SizedBox(height: 20),
            
            // Due date display with enhanced styling
            if (expectedDeliveryDate != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE91E63).withOpacity(0.1),
                      const Color(0xFF7B1FA2).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFE91E63),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.expectedDueDate,
                            style: const TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(expectedDeliveryDate),
                            style: const TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Baby development info with enhanced styling
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF3E5F5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.child_care,
                          color: Color(0xFFE91E63),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.thisWeeksDevelopment,
                        style: const TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getBabyDevelopmentText(weeks),
                    style: const TextStyle(
                      color: Color(0xFF5A5A5A),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Milestone timeline indicator
            _buildMilestoneTimeline(weeks, trimester),
            
            const SizedBox(height: 16),
            
            // View details button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PregnancyJourneyDetailPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.timeline, size: 18),
                label: Text(AppLocalizations.of(context)!.viewFullJourney),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneTimeline(int weeks, String trimester) {
    List<Map<String, dynamic>> milestones = [
      {'week': 4, 'title': AppLocalizations.of(context)!.heartBegins, 'icon': Icons.favorite, 'completed': weeks >= 4},
      {'week': 8, 'title': AppLocalizations.of(context)!.allOrgans, 'icon': Icons.psychology, 'completed': weeks >= 8},
      {'week': 12, 'title': AppLocalizations.of(context)!.endFirstTrimester, 'icon': Icons.celebration, 'completed': weeks >= 12},
      {'week': 20, 'title': AppLocalizations.of(context)!.halfwayPoint, 'icon': Icons.star, 'completed': weeks >= 20},
      {'week': 24, 'title': AppLocalizations.of(context)!.viability, 'icon': Icons.security, 'completed': weeks >= 24},
      {'week': 28, 'title': AppLocalizations.of(context)!.eyesOpen, 'icon': Icons.visibility, 'completed': weeks >= 28},
      {'week': 32, 'title': AppLocalizations.of(context)!.rapidGrowth, 'icon': Icons.trending_up, 'completed': weeks >= 32},
      {'week': 36, 'title': AppLocalizations.of(context)!.fullTermSoon, 'icon': Icons.baby_changing_station, 'completed': weeks >= 36},
      {'week': 40, 'title': AppLocalizations.of(context)!.dueDate, 'icon': Icons.cake, 'completed': weeks >= 40},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF3E5F5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.pregnancyMilestones,
            style: const TextStyle(
              color: Color(0xFF7B1FA2),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                final milestone = milestones[index];
                final isCompleted = milestone['completed'] as bool;
                final isCurrent = weeks >= milestone['week'] - 2 && weeks <= milestone['week'] + 2;
                
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? const Color(0xFFE91E63)
                              : isCurrent
                                  ? const Color(0xFFE91E63).withOpacity(0.3)
                                  : const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(18),
                          border: isCurrent
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
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${milestone['week']}w',
                        style: TextStyle(
                          color: isCompleted || isCurrent 
                              ? const Color(0xFF7B1FA2)
                              : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  Widget _buildProgressContent(String babyName, int weeks, int days, int totalDays, int weeksRemaining, int daysRemaining, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.babyGrowing(babyName),
          style: const TextStyle(
            color: Color(0xFF111611),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 8),
        
        // Pregnancy details with better wrapping
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF638763).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context)!.dayLabel(totalDays),
                style: const TextStyle(
                  color: Color(0xFF638763),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context)!.weeksDaysLabel(days, weeks),
                style: const TextStyle(
                  color: Color(0xFFE91E63),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Time remaining - compact display
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Color(0xFFE91E63),
              size: 14,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.timeRemaining(daysRemaining % 7, weeksRemaining),
                style: const TextStyle(
                  color: Color(0xFFE91E63),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Progress bar
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              minHeight: 6,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Progress percentage - simplified
        Text(
          AppLocalizations.of(context)!.progressComplete(percentage.toStringAsFixed(1), totalDays),
          style: const TextStyle(
            color: Color(0xFFE91E63),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getBabyDevelopmentText(int weeks) {
    if (weeks < 4) {
      return AppLocalizations.of(context)!.babyDevWeek4;
    } else if (weeks < 8) {
      return AppLocalizations.of(context)!.babyDevWeek8;
    } else if (weeks < 12) {
      return AppLocalizations.of(context)!.babyDevWeek12;
    } else if (weeks < 16) {
      return AppLocalizations.of(context)!.babyDevWeek16;
    } else if (weeks < 20) {
      return AppLocalizations.of(context)!.babyDevWeek20;
    } else if (weeks < 24) {
      return AppLocalizations.of(context)!.babyDevWeek24;
    } else if (weeks < 28) {
      return AppLocalizations.of(context)!.babyDevWeek28;
    } else if (weeks < 32) {
      return AppLocalizations.of(context)!.babyDevWeek32;
    } else if (weeks < 36) {
      return AppLocalizations.of(context)!.babyDevWeek36;
    } else {
      return AppLocalizations.of(context)!.babyDevWeek40;
    }
  }
}
