import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/tips_service.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';
import '../models/daily_tip.dart';
import '../pages/learn_page.dart';
import '../l10n/app_localizations.dart';

class DynamicTipWidget extends StatefulWidget {
  final VoidCallback? onLearnMorePressed;

  const DynamicTipWidget({
    super.key,
    this.onLearnMorePressed,
  });

  @override
  State<DynamicTipWidget> createState() => _DynamicTipWidgetState();
}

class _DynamicTipWidgetState extends State<DynamicTipWidget> {
  final TipsService _tipsService = TipsService();
  final BackendService _backendService = BackendService();

  DailyTip? _todaysTip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer until after first frame so localization is available
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadTodaysTip();
    });
  }

  Future<void> _loadTodaysTip() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current pregnancy week for personalized tips
      int pregnancyWeek = 0;
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final progress =
            await _backendService.calculatePregnancyProgress(userId);
        pregnancyWeek = progress['weeks'] as int? ?? 0;
      }

      // Get today's tip (pass localization if available)
      final l10n = AppLocalizations.of(context);
      final tip = await _tipsService.getTodaysTip(
          pregnancyWeek: pregnancyWeek, l10n: l10n);

      setState(() {
        _todaysTip = tip;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTipDetail() {
    if (_todaysTip != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _TipDetailSheet(tip: _todaysTip!),
      );
    }
  }

  void _navigateToLearnPage() {
    if (widget.onLearnMorePressed != null) {
      widget.onLearnMorePressed!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LearnPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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

    if (_todaysTip == null) {
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
        child: Column(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFF9575CD),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.noTipsAvailable ?? 'No Tips Available',
              style: const TextStyle(
                color: Color(0xFF7B1FA2),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.noTipsAvailable ??
                  'Check back later for helpful pregnancy tips',
              style: const TextStyle(
                color: Color(0xFF9575CD),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToLearnPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n?.learn ?? 'Explore Learn Page'),
            ),
          ],
        ),
      );
    }

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use column layout for narrow screens to prevent overflow
          final isNarrow = constraints.maxWidth < 350;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Text(
                      l10n?.todaysFeaturedTip ?? "Today's Tip",
                      style: const TextStyle(
                        color: Color(0xFF9575CD),
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _localizedCategory(_todaysTip!.category, context),
                        style: const TextStyle(
                          color: Color(0xFFE91E63),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  _todaysTip!.title,
                  style: const TextStyle(
                    color: Color(0xFF7B1FA2),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  _todaysTip!.description,
                  style: const TextStyle(
                    color: Color(0xFF5A5A5A),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Action buttons - responsive
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      onTap: _showTipDetail,
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            l10n?.readMore ?? 'Read More',
                            style: const TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToLearnPage,
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            l10n?.learn ?? 'Learn More',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          // Wide layout - use Row
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n?.todaysFeaturedTip ?? "Today's Tip",
                          style: const TextStyle(
                            color: Color(0xFF9575CD),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _localizedCategory(_todaysTip!.category, context),
                            style: const TextStyle(
                              color: Color(0xFFE91E63),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _todaysTip!.title,
                      style: const TextStyle(
                        color: Color(0xFF7B1FA2),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _todaysTip!.description,
                      style: const TextStyle(
                        color: Color(0xFF5A5A5A),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _showTipDetail,
                            child: Container(
                              height: 36,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E5F5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  l10n?.readMore ?? 'Read More',
                                  style: const TextStyle(
                                    color: Color(0xFF7B1FA2),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToLearnPage,
                            child: Container(
                              height: 36,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Center(
                                child: Text(
                                  l10n?.learn ?? 'Learn More',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Tip image - flexible size
              GestureDetector(
                onTap: _showTipDetail,
                child: Container(
                  width: 80,
                  height: 100,
                  constraints:
                      const BoxConstraints(minWidth: 60, maxWidth: 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _todaysTip!.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(_todaysTip!.category),
                            color: const Color(0xFFE91E63),
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.health_and_safety;
      case 'nutrition':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'medical':
        return Icons.medical_services;
      case 'preparation':
        return Icons.baby_changing_station;
      case 'development':
        return Icons.child_care;
      default:
        return Icons.lightbulb;
    }
  }

  String _localizedCategory(String category, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = category.toLowerCase();
    if (c == 'health') return l10n?.health ?? category;
    if (c == 'nutrition') return l10n?.nutrition ?? category;
    if (c == 'fitness') return l10n?.exerciseMinutesDaily ?? category;
    if (c == 'medical') return l10n?.doctor ?? category;
    if (c == 'preparation') return l10n?.pregnancy ?? category;
    if (c == 'development') return l10n?.baby ?? category;
    return category;
  }
}

class _TipDetailSheet extends StatelessWidget {
  final DailyTip tip;

  const _TipDetailSheet({required this.tip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String localizedCategory() {
      final c = tip.category.toLowerCase();
      if (c == 'health') return l10n?.health ?? tip.category;
      if (c == 'nutrition') return l10n?.nutrition ?? tip.category;
      if (c == 'fitness') return l10n?.exerciseMinutesDaily ?? tip.category;
      if (c == 'medical') return l10n?.doctor ?? tip.category;
      if (c == 'preparation') return l10n?.pregnancy ?? tip.category;
      if (c == 'development') return l10n?.baby ?? tip.category;
      return tip.category;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(tip.category),
                        color: const Color(0xFFE91E63),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                localizedCategory(),
                                style: const TextStyle(
                                  color: Color(0xFF9575CD),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (tip.pregnancyWeek > 0) ...[
                                const Text(' • ',
                                    style: TextStyle(color: Color(0xFF9575CD))),
                                Text(
                                  'Week ${tip.pregnancyWeek}',
                                  style: const TextStyle(
                                    color: Color(0xFF9575CD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            tip.title,
                            style: const TextStyle(
                              color: Color(0xFF7B1FA2),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF9575CD)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        tip.description,
                        style: const TextStyle(
                          color: Color(0xFF5A5A5A),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Key Points
                      if (tip.keyPoints.isNotEmpty) ...[
                        Text(
                          l10n?.keyPoints ?? 'Key Points',
                          style: const TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...tip.keyPoints
                            .map((point) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE91E63),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          point,
                                          style: const TextStyle(
                                            color: Color(0xFF5A5A5A),
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        const SizedBox(height: 24),
                      ],

                      // Full Content
                      Text(
                        l10n?.detailedInformation ?? 'Detailed Information',
                        style: const TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tip.fullContent,
                        style: const TextStyle(
                          color: Color(0xFF5A5A5A),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.health_and_safety;
      case 'nutrition':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'medical':
        return Icons.medical_services;
      case 'preparation':
        return Icons.baby_changing_station;
      case 'development':
        return Icons.child_care;
      default:
        return Icons.lightbulb;
    }
  }
}
