import 'package:flutter/material.dart';
import 'signup-roleMother.dart'; // keep this for SignupMotherForm()

void main() {
  runApp(const RoleSelectionApp());
}

class RoleSelectionApp extends StatelessWidget {
  const RoleSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - Role Select',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFF0F1724),
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: const Color(0xFF1993E5)),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  final roles = <_RoleInfo>[
    _RoleInfo(
      title: "I'm a Mother",
      subtitle: 'Track pregnancy & health tips',
      icon: Icons.favorite,
      color: Color(0xFFFB7185),
    ),
    _RoleInfo(
      title: "I'm a Family Member",
      subtitle: 'Support & emergency contacts',
      icon: Icons.family_restroom,
      color: Color(0xFF60A5FA),
    ),
    _RoleInfo(
      title: "I'm a Healthcare Professional",
      subtitle: 'Clinical tools & patient view',
      icon: Icons.medical_services,
      color: Color(0xFF34D399),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    // create staggered animations for 3 items
    _slideAnimations = List.generate(roles.length, (i) {
      final start = i * 0.12;
      final end = start + 0.48;
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _fadeAnimations = List.generate(roles.length, (i) {
      final start = i * 0.12 + 0.05;
      final end = start + 0.45;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });

    // play
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onRoleTap(String title) {
    if (title == "I'm a Mother") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Scaffold(body: SignupMotherForm())),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title tapped')));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isWide = media.size.width > 520;

    return Scaffold(
      body: Stack(
        children: [
          // NEW: Different background gradient with purple accent
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1225), Color(0xFF151F38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // NEW: Different decorative shapes and colors
          Positioned(
            top: -60,
            left: -40,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: isWide ? 320 : 200,
                height: isWide ? 320 : 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  color: const Color(0xFF9F7AEA).withOpacity(0.05), // Purple accent
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
                width: isWide ? 380 : 240,
                height: isWide ? 380 : 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: const Color(0xFFF472B6).withOpacity(0.06), // Pink accent
                ),
              ),
            ),
          ),

          // NEW: Additional subtle background element
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.04), // Green accent
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 640 : 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top: logo + title
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            // Logo circle with different styling
                            Container(
                              width: isWide ? 112 : 92,
                              height: isWide ? 112 : 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                                image: const DecorationImage(
                                  image: AssetImage('assets/logo.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Choose your role',
                              style: TextStyle(
                                fontSize: 24, // Slightly larger
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'We\'ll tailor the app experience for you',
                              style: TextStyle(
                                color: Color(0xFFA8B8C8), // Lighter color
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // NEW: Different decorative image styling
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          height: isWide ? 200 : 150,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9F7AEA), Color(0xFFF472B6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Stack(
                            children: [
                              // Optional: You can keep the image or use a solid gradient
                              Opacity(
                                opacity: 0.7,
                                child: Image.asset(
                                  'assets/signup_image.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black.withOpacity(0.25), Colors.transparent],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              const Center(
                                child: Text(
                                  'Welcome to Safe Mother',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Glass card containing role buttons with updated styling
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // heading with updated styling
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Who are you?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Select the option that best describes you',
                                    style: TextStyle(
                                      color: Color(0xFFA8B8C8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Role buttons (stagger animated)
                            Column(
                              children: List.generate(roles.length, (i) {
                                final r = roles[i];
                                return AnimatedBuilder(
                                  animation: _ctrl,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _fadeAnimations[i].value,
                                      child: Transform.translate(
                                        offset: _slideAnimations[i].value * 32,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: RoleCard(
                                      title: r.title,
                                      subtitle: r.subtitle,
                                      icon: r.icon,
                                      color: r.color,
                                      onTap: () => _onRoleTap(r.title),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // small help row with updated styling
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.info_outline, size: 16, color: Color(0xFFA8B8C8)),
                                  SizedBox(width: 8),
                                  Text(
                                    'You can change this later in settings',
                                    style: TextStyle(
                                      color: Color(0xFFA8B8C8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // footer CTA with updated styling
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Need help?",
                              style: TextStyle(
                                color: Color(0xFFA8B8C8),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Contact support tapped'),
                                  backgroundColor: Color(0xFF1993E5),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                backgroundColor: const Color(0xFF1993E5).withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Contact Us',
                                style: TextStyle(
                                  color: Color(0xFF1993E5),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'SAFE MOTHER • 2025',
                        style: TextStyle(
                          color: Color(0xFF738D9A),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const RoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.03),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // avatar icon with updated styling
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              // texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFA8B8C8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFA8B8C8),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _RoleInfo({required this.title, required this.subtitle, required this.icon, required this.color});
}