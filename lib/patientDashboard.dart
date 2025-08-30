import 'package:flutter/material.dart';
import 'bottom_navigation.dart'; // Import the separate navigation bar
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
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Container(
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
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Good evening,\n',
                          style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Mathu',
                          style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pregnancy progress card
                  Container(
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
                        const Text(
                          'Your Pregnancy Journey',
                          style: TextStyle(
                            color: Color(0xFF7B1FA2),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Progress section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Day 56',
                                    style: TextStyle(
                                      color: Color(0xFFE91E63),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  const Text(
                                    '37 weeks to go!',
                                    style: TextStyle(
                                      color: Color(0xFF9575CD),
                                      fontSize: 14,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Progress bar
                                  Container(
                                    width: double.infinity,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 136,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE91E63),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Due date button
                                  Container(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E5F5),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Due 10 Apr',
                                        style: TextStyle(
                                          color: Color(0xFF7B1FA2),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Baby image
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/baby.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's tip card
                  Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Tip",
                                style: TextStyle(
                                  color: Color(0xFF9575CD),
                                  fontSize: 14,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Stay Hydrated',
                                style: TextStyle(
                                  color: Color(0xFF7B1FA2),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              const Text(
                                'Drink at least 8 glasses of water today to support your health and the baby\'s development.',
                                style: TextStyle(
                                  color: Color(0xFF5A5A5A),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Learn more button
                              Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E5F5),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Learn More',
                                    style: TextStyle(
                                      color: Color(0xFF7B1FA2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Tip image
                        Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/tip.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  
                  // Log symptoms button
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 200,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle symptoms logging
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
}