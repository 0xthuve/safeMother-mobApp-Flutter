import 'package:flutter/material.dart';

void main() {
  runApp(const FamilyLinkApp());
}

class FamilyLinkApp extends StatelessWidget {
  const FamilyLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother - Family Link',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF8F6F8), // Soft off-white background
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63), // Soft pink accent
          secondary: const Color(0xFF9C27B0), // Soft purple
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)), // Dark gray text
        ),
      ),
      home: const FamilyLinkScreen(),
    );
  }
}

class FamilyLinkScreen extends StatelessWidget {
  const FamilyLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Soft gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)], // Soft peach to off-white
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
                  color: const Color(0xFFFFCCBC).withOpacity(0.4), // Soft peach
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
                  color: const Color(0xFFF8BBD0).withOpacity(0.3), // Soft pink
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header with back button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),
                            ),
                            const Text(
                              'Link to Family Member',
                              style: TextStyle(
                                color: Color(0xFF7B1FA2),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 48), // For balance
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Title
                      const Text(
                        'Connect with your loved ones',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B1FA2),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      const Text(
                        'Share your journey with family members by linking their accounts. They\'ll be able to view updates and support you along the way.',
                        style: TextStyle(
                          color: Color(0xFF9575CD),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Form container
                      Container(
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
                            // Code input field
                            TextFormField(
                              style: const TextStyle(color: Color(0xFF5A5A5A)),
                              decoration: InputDecoration(
                                labelText: 'Enter Code',
                                labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Link with Code button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle linking with code
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Link with Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Divider with "Or" text
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: const Color(0xFF9575CD).withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Or',
                                    style: TextStyle(
                                      color: const Color(0xFF7B1FA2),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: const Color(0xFF9575CD).withOpacity(0.3),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Scan QR Code button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Handle QR code scanning
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Scan QR Code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Bottom navigation bar
                      // Container(
                      //   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: const BorderRadius.only(
                      //       topLeft: Radius.circular(20),
                      //       topRight: Radius.circular(20),
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.purple[50]!,
                      //         blurRadius: 20,
                      //         offset: const Offset(0, -5),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //     children: [
                      //       _buildNavItem(Icons.home_outlined, 'Home', isActive: false),
                      //       _buildNavItem(Icons.school_outlined, 'Learn', isActive: false),
                      //       _buildNavItem(Icons.show_chart_outlined, 'Track', isActive: false),
                      //       _buildNavItem(Icons.people_outline, 'Community', isActive: false),
                      //       _buildNavItem(Icons.person_outline, 'Me', isActive: true),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(
  //         icon,
  //         color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
  //         size: 24,
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
  //           fontSize: 12,
  //           fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
