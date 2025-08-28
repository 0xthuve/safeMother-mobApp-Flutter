import 'package:flutter/material.dart';
import 'signup-roleMother.dart';

void main() {
  runApp(const RoleSelectionApp());
}

class RoleSelectionApp extends StatelessWidget {
  const RoleSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          children: [
            RoleSelectionScreen(),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Image Section
        Container(
          width: double.infinity,
          height: 320,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/signup_image.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Buttons Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CustomButton(text: "I'm a Mother"),
              const SizedBox(height: 12),
              CustomButton(text: "I'm a Family Member"),
              const SizedBox(height: 12),
              CustomButton(text: "I'm a Healthcare Professional"),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bottom White Space
        Container(
          width: double.infinity,
          height: 20,
          color: Colors.white,
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;

  const CustomButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1993E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () {
          if (text == "I'm a Mother") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(body: SignupMotherForm()),
              ),
            );
          }
          // Add navigation for other buttons if needed
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }
}
