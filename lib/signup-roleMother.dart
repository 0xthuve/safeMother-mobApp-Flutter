import 'package:flutter/material.dart';
import 'signup-roleMother-p2.dart'; // Make sure this file contains `RoleMotherP2` widget
import 'signin.dart';

void main() {
  runApp(const SignupMotherApp());
}

class SignupMotherApp extends StatelessWidget {
  const SignupMotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - Signup',
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
      home: const SafeArea(child: SignupMotherForm()),
    );
  }
}

class SignupMotherForm extends StatefulWidget {
  const SignupMotherForm({super.key});

  @override
  State<SignupMotherForm> createState() => _SignupMotherFormState();
}

class _SignupMotherFormState extends State<SignupMotherForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _eddController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _eddController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63), // Soft pink
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF5A5A5A),
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eddController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
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
                colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)], // Soft peach to off-white
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative shapes with softer colors
          Positioned(
            top: -80,
            left: -60,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFF8BBD0).withOpacity(0.3), // Soft pink
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -120,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFE1BEE7).withOpacity(0.3), // Soft lavender
                ),
              ),
            ),
          ),
          
          // Additional subtle background element
          Positioned(
            top: 150,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCCBC).withOpacity(0.4), // Soft peach
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
                      // Logo with soft styling
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink[100]!, // Soft pink shadow
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFFFCDD2).withOpacity(0.5),
                            width: 1.5,
                            ),
                          color: Colors.white,
                          image: const DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      const Text(
                        'Tell us about yourself',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B1FA2), // Soft purple
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Create your account to get started',
                        style: TextStyle(
                          color: Color(0xFF9575CD), // Light purple
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Form container with soft styling
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
                              color: Colors.purple[50]!, // Very soft purple shadow
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Full Name
                              _buildInputField(
                                'Full Name',
                                Icons.person_outline,
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Age
                              _buildInputField(
                                'Age',
                                Icons.cake_outlined,
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your age';
                                  }
                                  if (int.tryParse(value) == null || int.parse(value) < 15 || int.parse(value) > 50) {
                                    return 'Please enter a valid age';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Username
                              _buildInputField(
                                'Username',
                                Icons.alternate_email_outlined,
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose a username';
                                  }
                                  if (value.length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Email
                              _buildInputField(
                                'Email',
                                Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Password
                              _buildPasswordField(
                                'Password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                onToggle: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Confirm Password
                              _buildPasswordField(
                                'Confirm Password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                onToggle: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Location
                              _buildInputField(
                                'Location',
                                Icons.location_on_outlined,
                                controller: _locationController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your location';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // EDD (Estimated Due Date)
                              TextFormField(
                                controller: _eddController,
                                readOnly: true,
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                decoration: InputDecoration(
                                  labelText: 'Estimated Due Date',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF9575CD)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                ),
                                onTap: () => _selectDate(context),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your estimated due date';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // Continue Button - FIXED NAVIGATION
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Fixed navigation to RoleMotherP2
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const RoleMotherP2(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E63),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Already have account prompt
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                color: Color(0xFF7E57C2),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInApp(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                backgroundColor: const Color(0xFFE91E63).withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInputField(
    String label,
    IconData icon, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF5A5A5A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9575CD)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9575CD)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(
    String label, {
    TextEditingController? controller,
    bool obscureText = true,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF5A5A5A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9575CD)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9575CD)),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF9575CD),
          ),
          onPressed: onToggle,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    );
  }
}