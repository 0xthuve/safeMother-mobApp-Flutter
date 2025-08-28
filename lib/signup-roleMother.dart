import 'package:flutter/material.dart';
import 'signup-roleMother-p2.dart'; // Make sure this file contains `RoleMotherP2` widget

void main() {
  runApp(const SignupMotherApp());
}


class SignupMotherApp extends StatelessWidget {
  const SignupMotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const SafeArea(child: SignupMotherForm()),
    );
  }
}


class SignupMotherForm extends StatelessWidget {
  const SignupMotherForm({super.key});

  @override
  Widget build(BuildContext context) {
    const double padding = 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: Text(
                'Safe Mother',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
            child: Text(
              'Tell us about yourself',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildInputField('Full Name'),
          _buildInputField('Age'),
          _buildInputField('Username'),
          _buildInputField('Email'),
          _buildInputField('Password', obscureText: true),
          _buildInputField('Confirm Password', obscureText: true),
          _buildInputField('Location'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoleMotherP2(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1993E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInputField(String hint, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFEFF2F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }
}
