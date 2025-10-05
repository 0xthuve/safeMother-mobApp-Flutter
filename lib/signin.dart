import 'package:flutter/material.dart';
import 'signup-roleSelection.dart';
import 'signup-roleMother-p2.dart';
import 'patientDashboard.dart';
import 'patientDashboardLog.dart';
import 'reminderPatientDashboard.dart';
import 'patientDashboardTip.dart';
import 'chatPatient.dart';
import 'pages/doctor/doctor_login.dart';
import 'services/user_management_service.dart';

void main() {
  runApp(const SignInApp());
}

class SignInApp extends StatelessWidget {
  const SignInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - Login',
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
      home: const SignInScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/log': (context) => PatientDashboardLog(),
        '/reminders': (context) => const RemindersScreen(),
        '/learn': (context) => const LearnScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
            top: 120,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCCBC).withOpacity(0.4), // Soft peach
              ),
            ),
          ),
          
          Positioned(
            top: -60,
            left: -40,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFF8BBD0).withOpacity(0.3), // Soft pink
                ),
              ),
            ),
          ),
          
          Positioned(
            right: -70,
            bottom: -100,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFE1BEE7).withOpacity(0.3), // Soft lavender
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
                      // Logo with soft styling
                      Container(
                        width: 96,
                        height: 96,
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
                      const SizedBox(height: 20),
                      
                      // Title
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B1FA2), // Soft purple
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Subtitle
                      const Text(
                        'Patient Login - Sign in to continue your motherhood journey',
                        style: TextStyle(
                          color: Color(0xFF9575CD), // Light purple
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
                      
                      // Form container with soft styling
                      Container(
                        padding: const EdgeInsets.all(24),
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
                        child: const SignInForm(),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Sign up prompt
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
                              "New to Safe Mother?",
                              style: TextStyle(
                                color: Color(0xFF7E57C2),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                // Navigate to role selection screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RoleSelectionScreen(),
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
                                'Create Account',
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
                      
                      const SizedBox(height: 20),

                      // // Demo mode button
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFE3F2FD).withOpacity(0.6),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: const Color(0xFF1976D2).withOpacity(0.3),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.info_outline,
                      //         color: Color(0xFF1976D2),
                      //         size: 20,
                      //       ),
                      //       const SizedBox(width: 12),
                      //       const Expanded(
                      //         child: Text(
                      //           'Demo Mode: Firebase not configured',
                      //           style: TextStyle(
                      //             color: Color(0xFF1976D2),
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //       ),
                      //       TextButton(
                      //         onPressed: () {
                      //           // Import the FirebaseMockService to show instructions
                      //           showDialog(
                      //             context: context,
                      //             builder: (context) => AlertDialog(
                      //               title: const Text(
                      //                 'Demo Mode',
                      //                 style: TextStyle(
                      //                   color: Color(0xFF7B1FA2),
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //               content: Column(
                      //                 mainAxisSize: MainAxisSize.min,
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 children: [
                      //                   const Text(
                      //                     'Firebase is not configured. Using demo mode with these credentials:',
                      //                     style: TextStyle(fontSize: 16),
                      //                   ),
                      //                   const SizedBox(height: 16),
                      //                   Container(
                      //                     padding: const EdgeInsets.all(12),
                      //                     decoration: BoxDecoration(
                      //                       color: const Color(0xFFF3E5F5),
                      //                       borderRadius: BorderRadius.circular(8),
                      //                     ),
                      //                     child: const Column(
                      //                       crossAxisAlignment: CrossAxisAlignment.start,
                      //                       children: [
                      //                         Text(
                      //                           'Demo Credentials:',
                      //                           style: TextStyle(
                      //                             fontWeight: FontWeight.bold,
                      //                             color: Color(0xFF7B1FA2),
                      //                           ),
                      //                         ),
                      //                         SizedBox(height: 8),
                      //                         Text('Email: demo@safemother.com'),
                      //                         Text('Password: demo123'),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                   const SizedBox(height: 16),
                      //                   const Text(
                      //                     'Or create a new account - all data will be stored locally.',
                      //                     style: TextStyle(
                      //                       fontSize: 14,
                      //                       color: Color(0xFF9575CD),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               actions: [
                      //                 TextButton(
                      //                   onPressed: () => Navigator.of(context).pop(),
                      //                   child: const Text(
                      //                     'Got it!',
                      //                     style: TextStyle(
                      //                       color: Color(0xFFE91E63),
                      //                       fontWeight: FontWeight.bold,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           );
                      //         },
                      //         style: TextButton.styleFrom(
                      //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      //         ),
                      //         child: const Text(
                      //           'Info',
                      //           style: TextStyle(
                      //             color: Color(0xFF1976D2),
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      
                      const SizedBox(height: 20),
                      
                      const SizedBox(height: 32),
                      
                      // Healthcare Provider Login Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE3F2FD).withOpacity(0.6),
                              const Color(0xFFF1F8E9).withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF81C784).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.medical_services,
                                    color: Color(0xFF1976D2),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Healthcare Provider?',
                                  style: TextStyle(
                                    color: Color(0xFF1976D2),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Access your medical dashboard and patient management tools',
                              style: TextStyle(
                                color: Color(0xFF64B5F6),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DoctorLogin(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.login,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Healthcare Login',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await UserManagementService.signInUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          context,
        );

        if (success) {
          // Get user data to show welcome message
          final userData = await UserManagementService.getCurrentUserData();
          final userName = userData?['fullName'] ?? 'User';
          final userRole = userData?['role'];

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, $userName!'),
                backgroundColor: const Color(0xFFE91E63),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            // Navigate to appropriate dashboard based on role
            if (userRole == 'doctor' || userRole == 'healthcare') {
              // Doctors should not access patient dashboard - show error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Healthcare providers cannot access patient dashboard. Please use Healthcare Login.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              // Sign out the user and return to login
              await UserManagementService.signOutUser();
              return;
            } else {
              // Only patients can access patient dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          }
        } else {
          throw Exception('Invalid email or password');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }



  Future<void> _onGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await UserManagementService.signInWithGoogle(context);

      if (result != null && result['success'] == true) {
        final userName = result['userName'] ?? 'User';
        final needsPregnancyInfo = result['needsPregnancyInfo'] as bool? ?? false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, $userName!'),
              backgroundColor: const Color(0xFFE91E63),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Check if user role is allowed to access patient dashboard
          final userRole = result['userRole'] as String?;
          if (userRole == 'doctor' || userRole == 'healthcare') {
            // Doctors should not access patient dashboard via Google Sign-In
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Healthcare providers cannot access patient dashboard. Please use Healthcare Login.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            // Sign out the user and return to login
            await UserManagementService.signOutUser();
            return;
          }

          // Navigate based on profile completion status
          if (needsPregnancyInfo) {
            // New user or incomplete profile - go to pregnancy questions
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RoleMotherP2(), // Pregnancy questions page
              ),
            );
          } else {
            // Existing user with complete profile - go to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        throw Exception('Google sign-in was cancelled or failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onForgotPassword() async {
    // Show dialog to ask for email or username
    final TextEditingController resetController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFF7B1FA2),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address or username to receive a password reset link.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: resetController,
              decoration: InputDecoration(
                labelText: 'Email or Username',
                labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9575CD)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF9575CD)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (resetController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(resetController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Send Reset Link',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        // Check if input is email or username and convert to email if needed
        String emailToReset = result;
        
        // If input doesn't contain @, treat it as username and try to find the email
        if (!result.contains('@')) {
          final userEmail = await UserManagementService.getEmailByUsername(result);
          if (userEmail != null) {
            emailToReset = userEmail;
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Username not found. Please try with your email address.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
            return;
          }
        }

        final success = await UserManagementService.resetPassword(emailToReset);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password reset email sent to $emailToReset'),
                backgroundColor: const Color(0xFFE91E63),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to send reset email. Please check your email address.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reset email: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Color(0xFF5A5A5A)),
            decoration: InputDecoration(
              labelText: 'Email or Phone',
              labelStyle: const TextStyle(color: Color(0xFF9575CD)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9575CD)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Color(0xFF5A5A5A)),
            decoration: InputDecoration(
              labelText: 'Password',
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
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF9575CD),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Remember me checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFFE91E63),
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Remember me',
                style: TextStyle(
                  color: Color(0xFF7E57C2),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _isLoading ? null : _onForgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Sign in button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Google Sign-In option
          const Text(
            'Or continue with',
            style: TextStyle(
              color: Color(0xFF9575CD),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          
          // Google Sign-In only
          Center(
            child: IconButton(
              onPressed: _isLoading ? null : _onGoogleSignIn,
              icon: Image.asset(
                'assets/google_icon.png',
                width: 24,
                height: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5F5),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}