import 'package:flutter/material.dart';
import 'signup-roleSelection.dart';

void main() {
  runApp(const SignIn());
}

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        fontFamily: 'Lexend',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1993E5),
        ),
      ),
      home: const Scaffold(
        body: SafeArea(child: SignInForm()),
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
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'User';

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      final id = _emailOrPhoneController.text.trim();
      // Demo action: show snackbar. Replace with real auth call.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signing in as $id ($_selectedRole)')),
      );
      // TODO: call your auth API or Firebase here.
    }
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFEFF2F4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF637787),
          fontSize: 16,
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Constrain to mobile-like width but remain responsive
    final maxWidth = 480.0;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Center(
          child: Container(
            width: maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Header / title row
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: Row(
                    children: const [
                      Spacer(),
                      Text(
                        'Safe Mother',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF111416),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),

                // Welcome texts
                const SizedBox(height: 8),
                const Text(
                  'Welcome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111416),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF111416),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email / Phone
                      TextFormField(
                        controller: _emailOrPhoneController,
                        decoration: _inputDecoration('Email or Phone'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter email or phone';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: _inputDecoration('Password'),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter password';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // // Role dropdown
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFEFF2F4),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   child: DropdownButtonFormField<String>(
                      //     value: _selectedRole,
                      //     decoration: const InputDecoration(border: InputBorder.none),
                      //     items: ['User', 'Doctor', 'Admin']
                      //         .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      //         .toList(),
                      //     onChanged: (v) {
                      //       if (v != null) setState(() => _selectedRole = v);
                      //     },
                      //   ),
                      // ),
                      // const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Forgot password tapped')),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Color(0xFF637787)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _onSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1993E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Color.fromARGB(255, 255, 255, 255) ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Scaffold(body: RoleSelectionScreen())),
                            );
                          },
                          child: const Text(
                            "Don't Have An Account?",
                            style: TextStyle(color: Color(0xFF637787)),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Register button
                      SizedBox(
                        width: 183,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Register tapped')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFEFF2F4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111416)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),
                      const Text(
                        'SAFEMOTHER-2025',
                        style: TextStyle(color: Color(0xFF637787)),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
