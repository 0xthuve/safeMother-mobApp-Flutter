import 'package:flutter/material.dart';

class RoleMotherP2 extends StatelessWidget {
  const RoleMotherP2({super.key});

  @override
  Widget build(BuildContext context) {
    return const DeliveryDetailsForm();
  }
}

void main() {
  runApp(const DeliveryDetailsApp());
}

class DeliveryDetailsApp extends StatelessWidget {
  const DeliveryDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1993E5),
          secondary: const Color(0xFFEFF2F4),
        ),
      ),
      home: const DeliveryDetailsForm(),
    );
  }
}


class DeliveryDetailsForm extends StatelessWidget {
  const DeliveryDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    const double padding = 16.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Header
              const Padding(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: Text(
                    'Safe Mother',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                child: Text(
                  'Tell us about your delivery',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Input Fields
              _buildInputField('Delivery Date (Optional)'),
              _buildInputField('Pregnancy Confirmed Date'),
              _buildInputField('Medical History'),
              _buildInputField('Weight?'),
              _buildInputField('First Child?'),
              _buildInputField('Pregnancy loss?'),
              _buildInputField('Baby already born?'),

              // Continue Button
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
                          builder: (context) => const NextPage(),
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
                      'Continue',
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
        ),
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

// Dummy Next Page
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: const Center(
        child: Text(
          'Next Page',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
