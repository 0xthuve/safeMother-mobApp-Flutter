import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AmbulanceButton extends StatelessWidget {
  const AmbulanceButton({super.key});

  void _showEmergencyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const EmergencyCallBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53935),
            Color(0xFFD32F2F),
            Color(0xFFB71C1C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEmergencyDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: const Text(
                    'Emergency',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyCallBottomSheet extends StatefulWidget {
  const EmergencyCallBottomSheet({super.key});

  @override
  State<EmergencyCallBottomSheet> createState() => _EmergencyCallBottomSheetState();
}

class _EmergencyCallBottomSheetState extends State<EmergencyCallBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isSliding = false;
  double _slidePosition = 0.0;
  static const double _slideThreshold = 0.7;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    

    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, double maxWidth) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = details.globalPosition.dx - renderBox.globalToLocal(Offset.zero).dx;
    final slideWidth = maxWidth - 80; // Account for button width
    
    setState(() {
      _slidePosition = (position / slideWidth).clamp(0.0, 1.0);
    });
    
    if (_slidePosition >= _slideThreshold && !_isSliding) {
      setState(() {
        _isSliding = true;
      });
      _slideController.forward();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_slidePosition >= _slideThreshold) {
      _makeEmergencyCall();
    } else {
      setState(() {
        _slidePosition = 0.0;
        _isSliding = false;
      });
      _slideController.reset();
    }
  }

  Future<void> _makeEmergencyCall() async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: '110');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      _showErrorDialog();
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Unable to Call'),
          ],
        ),
        content: const Text(
          'Unable to make the emergency call. Please dial 110 manually or contact emergency services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Emergency icon and title
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Emergency Call',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Slide to call ambulance service\nEmergency Number: 110',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Slide to call
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final slideWidth = maxWidth - 80;
                
                return Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade50,
                        Colors.red.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background text
                      Center(
                        child: Text(
                          _isSliding ? 'Calling Emergency...' : 'Slide to Call Ambulance',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // Sliding button
                      AnimatedPositioned(
                        duration: _isSliding ? Duration.zero : const Duration(milliseconds: 200),
                        left: _slidePosition * slideWidth,
                        top: 4,
                        child: GestureDetector(
                          onPanUpdate: (details) => _onPanUpdate(details, maxWidth),
                          onPanEnd: _onPanEnd,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isSliding ? Icons.phone : Icons.phone_in_talk,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
