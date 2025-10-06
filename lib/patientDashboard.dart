import 'package:flutter/material.dart';
import 'bottom_navigation.dart'; // Import the separate navigation bar
import 'navigation_handler.dart';
import 'patientProfile.dart';
import 'services/session_manager.dart';
import 'services/route_guard.dart';
import 'services/backend_service.dart';
import 'widgets/pregnancy_progress_widget.dart';
import 'widgets/dynamic_tip_widget.dart';
import 'pages/learn_page.dart';

void main() {
  runApp(const PregnancyApp());
}

class PregnancyApp extends StatelessWidget {
  const PregnancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother - Home',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF8F6F8),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF9C27B0),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  final BackendService _backendService = BackendService();
  String _userName = 'User';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Get user data from session
      final userName = await SessionManager.getUserName();

      // Initialize demo data if needed
      await _backendService.initializeDemoData();

      setState(() {
        _userName = userName ?? 'User';
        _isLoading = false;
      });
    } catch (e) {

      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getGreetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return RouteGuard.patientRouteGuard(
      context: context,
      child: Scaffold(
      body: Stack(
        children: [
          // Soft gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative shapes with softer colors
          Positioned(
            top: -60,
            left: -40,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  color: const Color(0xFFFFCCBC).withOpacity(0.4),
                ),
              ),
            ),
          ),
          Positioned(
            right: -70,
            bottom: -100,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: const Color(0xFFF8BBD0).withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFCDD2).withOpacity(0.5),
                              width: 1.5,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/profile.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Safe Mother',
                        style: TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Greeting
                  _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${_getGreetingTime()},\n',
                                style: const TextStyle(
                                  color: Color(0xFF7B1FA2),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: _userName,
                                style: const TextStyle(
                                  color: Color(0xFF7B1FA2),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                  const SizedBox(height: 24),
                  
                  // Pregnancy progress card - Dynamic implementation
                  const PregnancyProgressWidget(
                    showRefreshButton: true,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's tip card - Dynamic implementation
                  DynamicTipWidget(
                    onLearnMorePressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LearnPage()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's meal preference
                  const Text(
                    'Today Meal Preference',
                    style: TextStyle(
                      color: Color(0xFF7B1FA2),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Horizontal scroll for meal preferences
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildMealItem('Chia Seed', 'assets/chia_seed.png'),
                        const SizedBox(width: 16),
                        _buildMealItem('Coconut', 'assets/coconut.png'),
                        const SizedBox(width: 16),
                        _buildMealItem('Banana', 'assets/banana.png'),
                        const SizedBox(width: 16),
                        _buildMealItem('Avocado', 'assets/avocado.png'),
                        const SizedBox(width: 16),
                        _buildMealItem('Yogurt', 'assets/yogurt.png'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's exercise preference
                  const Text(
                    'Today Exercise Preference',
                    style: TextStyle(
                      color: Color(0xFF7B1FA2),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildExerciseItem('Prenatal Yoga', Icons.self_improvement),
                        const SizedBox(width: 12),
                        _buildExerciseItem('Walking', Icons.directions_walk),
                        const SizedBox(width: 12),
                        _buildExerciseItem('Pelvic Floor', Icons.fitness_center),
                        const SizedBox(width: 12),
                        _buildExerciseItem('Gentle Stretch', Icons.accessibility_new),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Log symptoms button
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 200,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            NavigationHandler.navigateToScreen(context, 1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Log Symptoms',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
          
          // Bottom navigation bar - Now using the separate widget
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    ),
    );
  }
  
  Widget _buildMealItem(String name, String imageUrl) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF5A5A5A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String name, IconData iconData) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(iconData, color: const Color(0xFFE91E63), size: 36),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5A5A5A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
