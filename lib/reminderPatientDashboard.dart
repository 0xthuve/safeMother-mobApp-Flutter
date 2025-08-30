import 'package:flutter/material.dart';
import 'navigation_handler.dart';

void main() {
  runApp(const PregnancyApp());
}

class PregnancyApp extends StatelessWidget {
  const PregnancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - Reminders',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF9F7F9), // Slightly different background
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF9C27B0),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const RemindersScreen(),
    );
  }
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  int _currentIndex = 2; // Reminders is active

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // NEW: Different gradient background for reminders screen
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5E8FF), Color(0xFFF9F7F9)], // Soft lavender to off-white
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // NEW: Different decorative shapes and colors
          Positioned(
            top: -50,
            left: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(0xFFD1C4E9).withOpacity(0.4), // Soft lavender
                ),
              ),
            ),
          ),
          
          // NEW: Additional decorative element
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1BEE7).withOpacity(0.3), // Light purple
              ),
            ),
          ),
          
          Positioned(
            right: -60,
            bottom: -90,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFC5CAE9).withOpacity(0.3), // Soft blue-purple
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
                  // Header with back button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),
                      ),
                      const Text(
                        'Reminders',
                        style: TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 48), // For balance
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today section with different styling
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(Icons.today, color: Color(0xFF7B1FA2), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Today',
                          style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Today's reminders
                  _buildReminderCard(
                    icon: Icons.fitness_center,
                    title: 'Prenatal Yoga',
                    time: '10:00 AM',
                    color: const Color(0xFFE91E63),
                  ),
                  
                  _buildReminderCard(
                    icon: Icons.medical_services,
                    title: 'Take Vitamins',
                    time: '12:00 PM',
                    color: const Color(0xFF9C27B0),
                  ),
                  
                  _buildReminderCard(
                    icon: Icons.local_hospital,
                    title: 'Doctor\'s Appointment',
                    time: '2:00 PM',
                    color: const Color(0xFF4CAF50),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Tomorrow section with different styling
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFF7B1FA2), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tomorrow',
                          style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tomorrow's reminders
                  _buildReminderCard(
                    icon: Icons.directions_walk,
                    title: 'Morning Walk',
                    time: '9:00 AM',
                    color: const Color(0xFF2196F3),
                  ),
                  
                  _buildReminderCard(
                    icon: Icons.school,
                    title: 'Nutrition Class',
                    time: '11:00 AM',
                    color: const Color(0xFFFF9800),
                  ),
                  
                  _buildReminderCard(
                    icon: Icons.shopping_cart,
                    title: 'Baby Shopping',
                    time: '3:00 PM',
                    color: const Color(0xFF607D8B),
                  ),
                  
                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
          
          // Bottom navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Home', 0),
                  _buildNavItem(Icons.assignment_outlined, 'Log', 1),
                  _buildNavItem(Icons.notifications_outlined, 'Reminders', 2),
                  _buildNavItem(Icons.school_outlined, 'Learn', 3),
                  _buildNavItem(Icons.chat_outlined, 'AI Bot', 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3E5F5).withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[50]!,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF5A5A5A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF9575CD),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Checkbox or action button
          IconButton(
            onPressed: () {
              // Handle reminder action
            },
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF9575CD),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}