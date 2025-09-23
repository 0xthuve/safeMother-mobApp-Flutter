import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.class FamilyLinkScreen extends StatefulWidget {

import 'services/auth_service.dart';

import 'patientDashboard.dart';import 'services/auth_service.dart';  const FamilyLinkScreen({super.key});

import 'signin.dart';

import 'patientDashboard.dart';

void main() {

  runApp(const FamilyLinkApp());import 'signin.dart';  @override

}

  State<FamilyLinkScreen> createState() => _FamilyLinkScreenState();

class FamilyLinkApp extends StatelessWidget {

  const FamilyLinkApp({super.key});void main() {}



  @override  runApp(const FamilyLinkApp());

  Widget build(BuildContext context) {

    return MaterialApp(}class _FamilyLinkScreenState extends State<FamilyLinkScreen> {

      debugShowCheckedModeBanner: false,

      title: 'Safe Mother - Family Registration',  final _formKey = GlobalKey<FormState>();

      theme: ThemeData(

        fontFamily: 'Lexend',class FamilyLinkApp extends StatelessWidget {  final _fullNameController = TextEditingController();

        scaffoldBackgroundColor: const Color(0xFFF8F6F8),

        colorScheme: ColorScheme.fromSwatch().copyWith(  const FamilyLinkApp({super.key});  final _emailController = TextEditingController();

          primary: const Color(0xFFE91E63),

          secondary: const Color(0xFF9C27B0),  final _passwordController = TextEditingController();

        ),

        textTheme: const TextTheme(  @override  final _confirmPasswordController = TextEditingController();

          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),

        ),  Widget build(BuildContext context) {  final _motherEmailController = TextEditingController();

      ),

      home: const FamilyLinkScreen(),    return MaterialApp(  final _phoneController = TextEditingController();

    );

  }      debugShowCheckedModeBanner: false,  

}

      title: 'Safe Mother - Family Registration',  bool _obscurePassword = true;

class FamilyLinkScreen extends StatefulWidget {

  const FamilyLinkScreen({super.key});      theme: ThemeData(  bool _obscureConfirmPassword = true;



  @override        fontFamily: 'Lexend',  bool _isLoading = false;

  State<FamilyLinkScreen> createState() => _FamilyLinkScreenState();

}        scaffoldBackgroundColor: const Color(0xFFF8F6F8),  String _selectedRelationship = 'Spouse';



class _FamilyLinkScreenState extends State<FamilyLinkScreen> {        colorScheme: ColorScheme.fromSwatch().copyWith(

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();          primary: const Color(0xFFE91E63),  final List<String> _relationships = [

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();          secondary: const Color(0xFF9C27B0),    'Spouse',

  final _confirmPasswordController = TextEditingController();

  final _motherEmailController = TextEditingController();        ),    'Mother',

  final _phoneController = TextEditingController();

          textTheme: const TextTheme(    'Father',

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),    'Sister',

  bool _isLoading = false;

  String _selectedRelationship = 'Spouse';        ),    'Brother',



  final List<String> _relationships = [      ),    'Daughter',

    'Spouse',

    'Mother',      home: const FamilyLinkScreen(),    'Son',

    'Father',

    'Sister',    );    'Mother-in-law',

    'Brother',

    'Daughter',  }    'Father-in-law',

    'Son',

    'Mother-in-law',}    'Other Family Member',

    'Father-in-law',

    'Other Family Member',  ];

  ];

class FamilyLinkScreen extends StatefulWidget {

  @override

  void dispose() {  const FamilyLinkScreen({super.key});  @override

    _fullNameController.dispose();

    _emailController.dispose();  void dispose() {

    _passwordController.dispose();

    _confirmPasswordController.dispose();  @override    _fullNameController.dispose();

    _motherEmailController.dispose();

    _phoneController.dispose();  State<FamilyLinkScreen> createState() => _FamilyLinkScreenState();    _emailController.dispose();

    super.dispose();

  }}    _passwordController.dispose();



  Future<void> _registerFamilyMember() async {    _confirmPasswordController.dispose();

    if (_formKey.currentState!.validate()) {

      setState(() {class _FamilyLinkScreenState extends State<FamilyLinkScreen> {    _motherEmailController.dispose();

        _isLoading = true;

      });  final _formKey = GlobalKey<FormState>();    _phoneController.dispose();



      try {  final _fullNameController = TextEditingController();    super.dispose();

        final result = await AuthService.registerFamilyMember(

          fullName: _fullNameController.text.trim(),  final _emailController = TextEditingController();  }

          email: _emailController.text.trim(),

          password: _passwordController.text.trim(),  final _passwordController = TextEditingController();

          motherEmail: _motherEmailController.text.trim(),

          relationship: _selectedRelationship,  final _confirmPasswordController = TextEditingController();  Future<void> _registerFamilyMember() async {

          phoneNumber: _phoneController.text.trim().isEmpty 

              ? null   final _motherEmailController = TextEditingController();    if (_formKey.currentState!.validate()) {

              : _phoneController.text.trim(),

        );  final _phoneController = TextEditingController();      setState(() {



        if (result.success && mounted) {          _isLoading = true;

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(  bool _obscurePassword = true;      });

              content: Text('Welcome to Safe Mother, ${_fullNameController.text.trim()}!'),

              backgroundColor: const Color(0xFF4CAF50),  bool _obscureConfirmPassword = true;

              behavior: SnackBarBehavior.floating,

              shape: RoundedRectangleBorder(  bool _isLoading = false;      try {

                borderRadius: BorderRadius.circular(12),

              ),  String _selectedRelationship = 'Spouse';        final result = await AuthService.registerFamilyMember(

            ),

          );          fullName: _fullNameController.text.trim(),



          Navigator.pushAndRemoveUntil(  final List<String> _relationships = [          email: _emailController.text.trim(),

            context,

            MaterialPageRoute(    'Spouse',          password: _passwordController.text.trim(),

              builder: (context) => const HomeScreen(),

            ),    'Mother',          motherEmail: _motherEmailController.text.trim(),

            (route) => false,

          );    'Father',          relationship: _selectedRelationship,

        } else if (mounted) {

          ScaffoldMessenger.of(context).showSnackBar(    'Sister',          phoneNumber: _phoneController.text.trim().isEmpty 

            SnackBar(

              content: Text(result.message),    'Brother',              ? null 

              backgroundColor: const Color(0xFFE91E63),

              behavior: SnackBarBehavior.floating,    'Daughter',              : _phoneController.text.trim(),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),    'Son',        );

              ),

            ),    'Mother-in-law',

          );

        }    'Father-in-law',        if (result.success && mounted) {

      } catch (e) {

        if (mounted) {    'Other Family Member',          ScaffoldMessenger.of(context).showSnackBar(

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(  ];            SnackBar(

              content: Text('Registration failed: ${e.toString()}'),

              backgroundColor: const Color(0xFFE91E63),              content: Text('Welcome to Safe Mother, ${_fullNameController.text.trim()}!'),

              behavior: SnackBarBehavior.floating,

              shape: RoundedRectangleBorder(  @override              backgroundColor: const Color(0xFF4CAF50),

                borderRadius: BorderRadius.circular(12),

              ),  void dispose() {              behavior: SnackBarBehavior.floating,

            ),

          );    _fullNameController.dispose();              shape: RoundedRectangleBorder(

        }

      } finally {    _emailController.dispose();                borderRadius: BorderRadius.circular(12),

        if (mounted) {

          setState(() {    _passwordController.dispose();              ),

            _isLoading = false;

          });    _confirmPasswordController.dispose();            ),

        }

      }    _motherEmailController.dispose();          );

    }

  }    _phoneController.dispose();



  @override    super.dispose();          // Navigate to family member dashboard

  Widget build(BuildContext context) {

    return Scaffold(  }          Navigator.pushAndRemoveUntil(

      body: Container(

        decoration: const BoxDecoration(            context,

          gradient: LinearGradient(

            colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)],  Future<void> _registerFamilyMember() async {            MaterialPageRoute(

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,    if (_formKey.currentState!.validate()) {              builder: (context) => const HomeScreen(), // You might want a different screen for family members

          ),

        ),      setState(() {            ),

        child: SafeArea(

          child: SingleChildScrollView(        _isLoading = true;            (route) => false,

            padding: const EdgeInsets.all(20),

            child: Center(      });          );

              child: ConstrainedBox(

                constraints: const BoxConstraints(maxWidth: 440),        } else if (mounted) {

                child: Column(

                  children: [      try {          ScaffoldMessenger.of(context).showSnackBar(

                    Row(

                      children: [        final result = await AuthService.registerFamilyMember(            SnackBar(

                        IconButton(

                          onPressed: () => Navigator.pop(context),          fullName: _fullNameController.text.trim(),              content: Text(result.message),

                          icon: const Icon(Icons.arrow_back),

                        ),          email: _emailController.text.trim(),              backgroundColor: const Color(0xFFE91E63),

                        const Expanded(

                          child: Text(          password: _passwordController.text.trim(),              behavior: SnackBarBehavior.floating,

                            'Family Registration',

                            textAlign: TextAlign.center,          motherEmail: _motherEmailController.text.trim(),              shape: RoundedRectangleBorder(

                            style: TextStyle(

                              fontSize: 18,          relationship: _selectedRelationship,                borderRadius: BorderRadius.circular(12),

                              fontWeight: FontWeight.bold,

                              color: Color(0xFF7B1FA2),          phoneNumber: _phoneController.text.trim().isEmpty               ),

                            ),

                          ),              ? null             ),

                        ),

                        const SizedBox(width: 48),              : _phoneController.text.trim(),          );

                      ],

                    ),        );        }

                    

                    const SizedBox(height: 30),      } catch (e) {

                    

                    Container(        if (result.success && mounted) {        if (mounted) {

                      width: 80,

                      height: 80,          ScaffoldMessenger.of(context).showSnackBar(          ScaffoldMessenger.of(context).showSnackBar(

                      decoration: const BoxDecoration(

                        shape: BoxShape.circle,            SnackBar(            SnackBar(

                        color: Colors.white,

                      ),              content: Text('Welcome to Safe Mother, ${_fullNameController.text.trim()}!'),              content: Text('Registration failed: ${e.toString()}'),

                      child: const Icon(

                        Icons.family_restroom,              backgroundColor: const Color(0xFF4CAF50),              backgroundColor: const Color(0xFFE91E63),

                        size: 40,

                        color: Color(0xFF7B1FA2),              behavior: SnackBarBehavior.floating,              behavior: SnackBarBehavior.floating,

                      ),

                    ),              shape: RoundedRectangleBorder(              shape: RoundedRectangleBorder(

                    

                    const SizedBox(height: 20),                borderRadius: BorderRadius.circular(12),                borderRadius: BorderRadius.circular(12),

                    

                    const Text(              ),              ),

                      'Join as Family Member',

                      style: TextStyle(            ),            ),

                        fontSize: 24,

                        fontWeight: FontWeight.bold,          );          );

                        color: Color(0xFF7B1FA2),

                      ),        }

                    ),

                              Navigator.pushAndRemoveUntil(      } finally {

                    const SizedBox(height: 30),

                                context,        if (mounted) {

                    Container(

                      padding: const EdgeInsets.all(20),            MaterialPageRoute(          setState(() {

                      decoration: BoxDecoration(

                        color: Colors.white,              builder: (context) => const HomeScreen(),            _isLoading = false;

                        borderRadius: BorderRadius.circular(20),

                      ),            ),          });

                      child: Form(

                        key: _formKey,            (route) => false,        }

                        child: Column(

                          children: [          );      }

                            TextFormField(

                              controller: _fullNameController,        } else if (mounted) {    }

                              decoration: const InputDecoration(

                                labelText: 'Full Name',          ScaffoldMessenger.of(context).showSnackBar(  }rt';

                                prefixIcon: Icon(Icons.person),

                              ),            SnackBar(import 'services/auth_service.dart';

                              validator: (value) {

                                if (value?.isEmpty ?? true) {              content: Text(result.message),import 'patientDashboard.dart';

                                  return 'Please enter your name';

                                }              backgroundColor: const Color(0xFFE91E63),import 'signin.dart';

                                return null;

                              },              behavior: SnackBarBehavior.floating,

                            ),

                                          shape: RoundedRectangleBorder(void main() {

                            const SizedBox(height: 16),

                                            borderRadius: BorderRadius.circular(12),  runApp(const FamilyLinkApp());

                            TextFormField(

                              controller: _emailController,              ),}

                              decoration: const InputDecoration(

                                labelText: 'Your Email',            ),

                                prefixIcon: Icon(Icons.email),

                              ),          );class FamilyLinkApp extends StatelessWidget {

                              validator: (value) {

                                if (value?.isEmpty ?? true) {        }  const FamilyLinkApp({super.key});

                                  return 'Please enter your email';

                                }      } catch (e) {

                                return null;

                              },        if (mounted) {  @override

                            ),

                                      ScaffoldMessenger.of(context).showSnackBar(  Widget build(BuildContext context) {

                            const SizedBox(height: 16),

                                        SnackBar(    return MaterialApp(

                            TextFormField(

                              controller: _motherEmailController,              content: Text('Registration failed: ${e.toString()}'),      debugShowCheckedModeBanner: false,

                              decoration: const InputDecoration(

                                labelText: 'Mother\'s Email',              backgroundColor: const Color(0xFFE91E63),      title: 'Safe Mother - Family Link',

                                prefixIcon: Icon(Icons.favorite),

                              ),              behavior: SnackBarBehavior.floating,      theme: ThemeData(

                              validator: (value) {

                                if (value?.isEmpty ?? true) {              shape: RoundedRectangleBorder(        fontFamily: 'Lexend',

                                  return 'Please enter mother\'s email';

                                }                borderRadius: BorderRadius.circular(12),        scaffoldBackgroundColor: const Color(0xFFF8F6F8), // Soft off-white background

                                return null;

                              },              ),        colorScheme: ColorScheme.fromSwatch().copyWith(

                            ),

                                        ),          primary: const Color(0xFFE91E63), // Soft pink accent

                            const SizedBox(height: 16),

                                      );          secondary: const Color(0xFF9C27B0), // Soft purple

                            DropdownButtonFormField<String>(

                              value: _selectedRelationship,        }        ),

                              decoration: const InputDecoration(

                                labelText: 'Relationship',      } finally {        textTheme: const TextTheme(

                                prefixIcon: Icon(Icons.family_restroom),

                              ),        if (mounted) {          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)), // Dark gray text

                              items: _relationships.map((String relationship) {

                                return DropdownMenuItem<String>(          setState(() {        ),

                                  value: relationship,

                                  child: Text(relationship),            _isLoading = false;      ),

                                );

                              }).toList(),          });      home: const FamilyLinkScreen(),

                              onChanged: (String? newValue) {

                                if (newValue != null) {        }    );

                                  setState(() {

                                    _selectedRelationship = newValue;      }  }

                                  });

                                }    }}

                              },

                            ),  }

                            

                            const SizedBox(height: 16),class FamilyLinkScreen extends StatelessWidget {

                            

                            TextFormField(  @override  const FamilyLinkScreen({super.key});

                              controller: _phoneController,

                              decoration: const InputDecoration(  Widget build(BuildContext context) {

                                labelText: 'Phone (Optional)',

                                prefixIcon: Icon(Icons.phone),    return Scaffold(  @override

                              ),

                            ),      body: Stack(  Widget build(BuildContext context) {

                            

                            const SizedBox(height: 16),        children: [    return Scaffold(

                            

                            TextFormField(          Container(      body: Stack(

                              controller: _passwordController,

                              obscureText: _obscurePassword,            decoration: const BoxDecoration(        children: [

                              decoration: InputDecoration(

                                labelText: 'Password',              gradient: LinearGradient(          // Soft gradient background

                                prefixIcon: const Icon(Icons.lock),

                                suffixIcon: IconButton(                colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)],          Container(

                                  icon: Icon(

                                    _obscurePassword                 begin: Alignment.topLeft,            decoration: const BoxDecoration(

                                        ? Icons.visibility 

                                        : Icons.visibility_off,                end: Alignment.bottomRight,              gradient: LinearGradient(

                                  ),

                                  onPressed: () {              ),                colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)], // Soft peach to off-white

                                    setState(() {

                                      _obscurePassword = !_obscurePassword;            ),                begin: Alignment.topLeft,

                                    });

                                  },          ),                end: Alignment.bottomRight,

                                ),

                              ),                        ),

                              validator: (value) {

                                if (value?.isEmpty ?? true) {          SafeArea(            ),

                                  return 'Please enter password';

                                }            child: SingleChildScrollView(          ),

                                if (value!.length < 6) {

                                  return 'Password must be at least 6 characters';              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),          

                                }

                                return null;              child: Center(          // Decorative shapes with softer colors

                              },

                            ),                child: ConstrainedBox(          Positioned(

                            

                            const SizedBox(height: 16),                  constraints: const BoxConstraints(maxWidth: 440),            top: -60,

                            

                            TextFormField(                  child: Column(            left: -40,

                              controller: _confirmPasswordController,

                              obscureText: _obscureConfirmPassword,                    crossAxisAlignment: CrossAxisAlignment.center,            child: Transform.rotate(

                              decoration: InputDecoration(

                                labelText: 'Confirm Password',                    children: [              angle: -0.4,

                                prefixIcon: const Icon(Icons.lock),

                                suffixIcon: IconButton(                      Row(              child: Container(

                                  icon: Icon(

                                    _obscureConfirmPassword                         mainAxisAlignment: MainAxisAlignment.spaceBetween,                width: 200,

                                        ? Icons.visibility 

                                        : Icons.visibility_off,                        children: [                height: 200,

                                  ),

                                  onPressed: () {                          IconButton(                decoration: BoxDecoration(

                                    setState(() {

                                      _obscureConfirmPassword = !_obscureConfirmPassword;                            onPressed: () => Navigator.pop(context),                  borderRadius: BorderRadius.circular(70),

                                    });

                                  },                            icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),                  color: const Color(0xFFFFCCBC).withOpacity(0.4), // Soft peach

                                ),

                              ),                          ),                ),

                              validator: (value) {

                                if (value?.isEmpty ?? true) {                          const Text(              ),

                                  return 'Please confirm password';

                                }                            'Family Registration',            ),

                                if (value != _passwordController.text) {

                                  return 'Passwords do not match';                            style: TextStyle(          ),

                                }

                                return null;                              color: Color(0xFF7B1FA2),          Positioned(

                              },

                            ),                              fontSize: 18,            right: -70,

                            

                            const SizedBox(height: 24),                              fontWeight: FontWeight.w700,            bottom: -100,

                            

                            SizedBox(                            ),            child: Transform.rotate(

                              width: double.infinity,

                              height: 50,                          ),              angle: 0.5,

                              child: ElevatedButton(

                                onPressed: _isLoading ? null : _registerFamilyMember,                          const SizedBox(width: 48),              child: Container(

                                style: ElevatedButton.styleFrom(

                                  backgroundColor: const Color(0xFFE91E63),                        ],                width: 240,

                                ),

                                child: _isLoading                      ),                height: 240,

                                    ? const CircularProgressIndicator(color: Colors.white)

                                    : const Text(                                      decoration: BoxDecoration(

                                        'Create Account',

                                        style: TextStyle(                      const SizedBox(height: 20),                  borderRadius: BorderRadius.circular(90),

                                          color: Colors.white,

                                          fontWeight: FontWeight.bold,                                        color: const Color(0xFFF8BBD0).withOpacity(0.3), // Soft pink

                                        ),

                                      ),                      Container(                ),

                              ),

                            ),                        width: 88,              ),

                          ],

                        ),                        height: 88,            ),

                      ),

                    ),                        decoration: BoxDecoration(          ),

                  ],

                ),                          shape: BoxShape.circle,          

              ),

            ),                          color: Colors.white,          // Content

          ),

        ),                          boxShadow: [          SafeArea(

      ),

    );                            BoxShadow(            child: SingleChildScrollView(

  }

}                              color: Colors.purple[100]!,              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),

                              blurRadius: 20,              child: Center(

                              offset: const Offset(0, 8),                child: ConstrainedBox(

                            ),                  constraints: const BoxConstraints(maxWidth: 440),

                          ],                  child: Column(

                        ),                    crossAxisAlignment: CrossAxisAlignment.center,

                        child: const Icon(                    children: [

                          Icons.family_restroom,                      // Header with back button

                          size: 40,                      Container(

                          color: Color(0xFF7B1FA2),                        width: double.infinity,

                        ),                        padding: const EdgeInsets.only(bottom: 16),

                      ),                        child: Row(

                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      const SizedBox(height: 20),                          children: [

                                                  IconButton(

                      const Text(                              onPressed: () {

                        'Join as Family Member',                                Navigator.pop(context);

                        style: TextStyle(                              },

                          fontSize: 24,                              icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),

                          fontWeight: FontWeight.w800,                            ),

                          color: Color(0xFF7B1FA2),                            const Text(

                        ),                              'Link to Family Member',

                      ),                              style: TextStyle(

                                                      color: Color(0xFF7B1FA2),

                      const SizedBox(height: 8),                                fontSize: 20,

                                                      fontWeight: FontWeight.w700,

                      const Text(                              ),

                        'Support your loved one\'s journey',                            ),

                        style: TextStyle(                            const SizedBox(width: 48), // For balance

                          color: Color(0xFF9575CD),                          ],

                          fontSize: 15,                        ),

                        ),                      ),

                      ),                      

                                            const SizedBox(height: 16),

                      const SizedBox(height: 32),                      

                                            // Title

                      Container(                      const Text(

                        padding: const EdgeInsets.all(20),                        'Connect with your loved ones',

                        decoration: BoxDecoration(                        style: TextStyle(

                          color: Colors.white,                          fontSize: 24,

                          borderRadius: BorderRadius.circular(20),                          fontWeight: FontWeight.w800,

                          boxShadow: [                          color: Color(0xFF7B1FA2),

                            BoxShadow(                        ),

                              color: Colors.purple[50]!,                        textAlign: TextAlign.center,

                              blurRadius: 25,                      ),

                              offset: const Offset(0, 10),                      

                            ),                      const SizedBox(height: 16),

                          ],                      

                        ),                      // Description

                        child: Form(                      const Text(

                          key: _formKey,                        'Share your journey with family members by linking their accounts. They\'ll be able to view updates and support you along the way.',

                          child: Column(                        style: TextStyle(

                            children: [                          color: Color(0xFF9575CD),

                              _buildInputField(                          fontSize: 16,

                                'Full Name',                          height: 1.5,

                                Icons.person_outline,                        ),

                                controller: _fullNameController,                        textAlign: TextAlign.center,

                                validator: (value) {                      ),

                                  if (value == null || value.isEmpty) {                      

                                    return 'Please enter your full name';                      const SizedBox(height: 32),

                                  }                      

                                  return null;                      // Form container

                                },                      Container(

                              ),                        padding: const EdgeInsets.all(20),

                                                      decoration: BoxDecoration(

                              const SizedBox(height: 16),                          color: Colors.white,

                                                        borderRadius: BorderRadius.circular(20),

                              _buildInputField(                          border: Border.all(

                                'Your Email',                            color: const Color(0xFFF3E5F5).withOpacity(0.8),

                                Icons.email_outlined,                            width: 1,

                                controller: _emailController,                          ),

                                keyboardType: TextInputType.emailAddress,                          boxShadow: [

                                validator: (value) {                            BoxShadow(

                                  if (value == null || value.isEmpty) {                              color: Colors.purple[50]!,

                                    return 'Please enter your email';                              blurRadius: 25,

                                  }                              offset: const Offset(0, 10),

                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {                            ),

                                    return 'Please enter a valid email';                          ],

                                  }                        ),

                                  return null;                        child: Column(

                                },                          children: [

                              ),                            // Code input field

                                                          TextFormField(

                              const SizedBox(height: 16),                              style: const TextStyle(color: Color(0xFF5A5A5A)),

                                                            decoration: InputDecoration(

                              _buildInputField(                                labelText: 'Enter Code',

                                'Mother\'s Email',                                labelStyle: const TextStyle(color: Color(0xFF9575CD)),

                                Icons.favorite_outline,                                filled: true,

                                controller: _motherEmailController,                                fillColor: const Color(0xFFF5F5F5),

                                keyboardType: TextInputType.emailAddress,                                border: OutlineInputBorder(

                                validator: (value) {                                  borderRadius: BorderRadius.circular(14),

                                  if (value == null || value.isEmpty) {                                  borderSide: BorderSide.none,

                                    return 'Please enter mother\'s email';                                ),

                                  }                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),

                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {                              ),

                                    return 'Please enter a valid email';                            ),

                                  }                            

                                  return null;                            const SizedBox(height: 20),

                                },                            

                              ),                            // Link with Code button

                                                          SizedBox(

                              const SizedBox(height: 16),                              width: double.infinity,

                                                            height: 50,

                              DropdownButtonFormField<String>(                              child: ElevatedButton(

                                value: _selectedRelationship,                                onPressed: () {

                                decoration: InputDecoration(                                  // Handle linking with code

                                  labelText: 'Relationship to Mother',                                },

                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),                                style: ElevatedButton.styleFrom(

                                  filled: true,                                  backgroundColor: const Color(0xFFE91E63),

                                  fillColor: const Color(0xFFF5F5F5),                                  shape: RoundedRectangleBorder(

                                  border: OutlineInputBorder(                                    borderRadius: BorderRadius.circular(14),

                                    borderRadius: BorderRadius.circular(14),                                  ),

                                    borderSide: BorderSide.none,                                  padding: const EdgeInsets.symmetric(vertical: 16),

                                  ),                                ),

                                  prefixIcon: const Icon(Icons.family_restroom, color: Color(0xFF9575CD)),                                child: const Text(

                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),                                  'Link with Code',

                                ),                                  style: TextStyle(

                                items: _relationships.map((String relationship) {                                    fontSize: 16,

                                  return DropdownMenuItem<String>(                                    fontWeight: FontWeight.w600,

                                    value: relationship,                                    color: Colors.white,

                                    child: Text(relationship),                                  ),

                                  );                                ),

                                }).toList(),                              ),

                                onChanged: (String? newValue) {                            ),

                                  if (newValue != null) {                            

                                    setState(() {                            const SizedBox(height: 24),

                                      _selectedRelationship = newValue;                            

                                    });                            // Divider with "Or" text

                                  }                            Row(

                                },                              children: [

                              ),                                Expanded(

                                                                child: Divider(

                              const SizedBox(height: 16),                                    color: const Color(0xFF9575CD).withOpacity(0.3),

                                                                  thickness: 1,

                              _buildInputField(                                  ),

                                'Phone (Optional)',                                ),

                                Icons.phone_outlined,                                Padding(

                                controller: _phoneController,                                  padding: const EdgeInsets.symmetric(horizontal: 16),

                                keyboardType: TextInputType.phone,                                  child: Text(

                              ),                                    'Or',

                                                                  style: TextStyle(

                              const SizedBox(height: 16),                                      color: const Color(0xFF7B1FA2),

                                                                    fontSize: 16,

                              _buildPasswordField(                                      fontWeight: FontWeight.w600,

                                'Password',                                    ),

                                controller: _passwordController,                                  ),

                                obscureText: _obscurePassword,                                ),

                                onToggle: () {                                Expanded(

                                  setState(() {                                  child: Divider(

                                    _obscurePassword = !_obscurePassword;                                    color: const Color(0xFF9575CD).withOpacity(0.3),

                                  });                                    thickness: 1,

                                },                                  ),

                                validator: (value) {                                ),

                                  if (value == null || value.isEmpty) {                              ],

                                    return 'Please enter a password';                            ),

                                  }                            

                                  if (value.length < 6) {                            const SizedBox(height: 24),

                                    return 'Password must be at least 6 characters';                            

                                  }                            // Scan QR Code button

                                  return null;                            SizedBox(

                                },                              width: double.infinity,

                              ),                              height: 50,

                                                            child: OutlinedButton(

                              const SizedBox(height: 16),                                onPressed: () {

                                                                // Handle QR code scanning

                              _buildPasswordField(                                },

                                'Confirm Password',                                style: OutlinedButton.styleFrom(

                                controller: _confirmPasswordController,                                  backgroundColor: const Color(0xFFF5F5F5),

                                obscureText: _obscureConfirmPassword,                                  side: BorderSide.none,

                                onToggle: () {                                  shape: RoundedRectangleBorder(

                                  setState(() {                                    borderRadius: BorderRadius.circular(14),

                                    _obscureConfirmPassword = !_obscureConfirmPassword;                                  ),

                                  });                                  padding: const EdgeInsets.symmetric(vertical: 16),

                                },                                ),

                                validator: (value) {                                child: const Text(

                                  if (value == null || value.isEmpty) {                                  'Scan QR Code',

                                    return 'Please confirm your password';                                  style: TextStyle(

                                  }                                    fontSize: 16,

                                  if (value != _passwordController.text) {                                    fontWeight: FontWeight.w600,

                                    return 'Passwords do not match';                                    color: Color(0xFF5A5A5A),

                                  }                                  ),

                                  return null;                                ),

                                },                              ),

                              ),                            ),

                                                        ],

                              const SizedBox(height: 24),                        ),

                                                    ),

                              SizedBox(                      

                                width: double.infinity,                      const SizedBox(height: 40),

                                height: 54,                      

                                child: ElevatedButton(                      // Bottom navigation bar

                                  onPressed: _isLoading ? null : _registerFamilyMember,                      // Container(

                                  style: ElevatedButton.styleFrom(                      //   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

                                    backgroundColor: const Color(0xFFE91E63),                      //   decoration: BoxDecoration(

                                    shape: RoundedRectangleBorder(                      //     color: Colors.white,

                                      borderRadius: BorderRadius.circular(14),                      //     borderRadius: const BorderRadius.only(

                                    ),                      //       topLeft: Radius.circular(20),

                                    padding: const EdgeInsets.symmetric(vertical: 16),                      //       topRight: Radius.circular(20),

                                  ),                      //     ),

                                  child: _isLoading                      //     boxShadow: [

                                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)                      //       BoxShadow(

                                      : const Text(                      //         color: Colors.purple[50]!,

                                          'Create Account',                      //         blurRadius: 20,

                                          style: TextStyle(                      //         offset: const Offset(0, -5),

                                            fontSize: 16,                      //       ),

                                            fontWeight: FontWeight.w600,                      //     ],

                                            color: Colors.white,                      //   ),

                                          ),                      //   child: Row(

                                        ),                      //     mainAxisAlignment: MainAxisAlignment.spaceAround,

                                ),                      //     children: [

                              ),                      //       _buildNavItem(Icons.home_outlined, 'Home', isActive: false),

                            ],                      //       _buildNavItem(Icons.school_outlined, 'Learn', isActive: false),

                          ),                      //       _buildNavItem(Icons.show_chart_outlined, 'Track', isActive: false),

                        ),                      //       _buildNavItem(Icons.people_outline, 'Community', isActive: false),

                      ),                      //       _buildNavItem(Icons.person_outline, 'Me', isActive: true),

                    ],                      //     ],

                  ),                      //   ),

                ),                      // ),

              ),                    ],

            ),                  ),

          ),                ),

        ],              ),

      ),            ),

    );          ),

  }        ],

      ),

  Widget _buildInputField(    );

    String label,  }

    IconData icon, {  

    TextEditingController? controller,  // Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {

    TextInputType keyboardType = TextInputType.text,  //   return Column(

    String? Function(String?)? validator,  //     mainAxisSize: MainAxisSize.min,

  }) {  //     children: [

    return TextFormField(  //       Icon(

      controller: controller,  //         icon,

      keyboardType: keyboardType,  //         color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),

      style: const TextStyle(color: Color(0xFF5A5A5A)),  //         size: 24,

      decoration: InputDecoration(  //       ),

        labelText: label,  //       const SizedBox(height: 4),

        labelStyle: const TextStyle(color: Color(0xFF9575CD)),  //       Text(

        filled: true,  //         label,

        fillColor: const Color(0xFFF5F5F5),  //         style: TextStyle(

        border: OutlineInputBorder(  //           color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),

          borderRadius: BorderRadius.circular(14),  //           fontSize: 12,

          borderSide: BorderSide.none,  //           fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,

        ),  //         ),

        prefixIcon: Icon(icon, color: const Color(0xFF9575CD)),  //       ),

        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),  //     ],

      ),  //   );

      validator: validator,  // }

    );}
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