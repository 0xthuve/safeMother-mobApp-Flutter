import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigation/family_navigation_handler.dart';

class FamilyContactsScreen extends StatefulWidget {
  const FamilyContactsScreen({super.key});

  @override
  State<FamilyContactsScreen> createState() => _FamilyContactsScreenState();
}

class _FamilyContactsScreenState extends State<FamilyContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  String _linkedPatientName = "Sarah";
  int _currentIndex = 3; // Contacts tab is active

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _contacts = _getMockContacts();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getMockContacts() {
    return [
      {
        'id': '1',
        'name': 'Dr. Sarah Johnson',
        'role': 'Primary Obstetrician',
        'phone': '+1 (555) 123-4567',
        'email': 'sarah.johnson@medicalcenter.com',
        'hospital': 'City General Hospital',
        'department': 'Obstetrics & Gynecology',
        'address': '123 Medical Center Drive, City, State 12345',
        'type': 'doctor',
        'availability': 'Mon-Fri: 9:00 AM - 5:00 PM',
        'emergencyContact': true,
        'photoColor': Color(0xFFE91E63),
      },
      {
        'id': '2',
        'name': 'Dr. Michael Chen',
        'role': 'Radiologist',
        'phone': '+1 (555) 234-5678',
        'email': 'michael.chen@imagingcenter.com',
        'hospital': 'Women\'s Health Imaging Center',
        'department': 'Radiology',
        'address': '456 Ultrasound Avenue, City, State 12345',
        'type': 'doctor',
        'availability': 'Mon-Sat: 8:00 AM - 6:00 PM',
        'emergencyContact': false,
        'photoColor': Color(0xFF2196F3),
      },
      {
        'id': '3',
        'name': 'Dr. Emily Davis',
        'role': 'Nutrition Specialist',
        'phone': '+1 (555) 345-6789',
        'email': 'emily.davis@wellness.com',
        'hospital': 'Pregnancy Wellness Center',
        'department': 'Nutrition',
        'address': '789 Health Street, City, State 12345',
        'type': 'doctor',
        'availability': 'Tue-Thu: 10:00 AM - 4:00 PM',
        'emergencyContact': false,
        'photoColor': Color(0xFF4CAF50),
      },
      {
        'id': '4',
        'name': 'City General Hospital',
        'role': 'Main Hospital',
        'phone': '+1 (555) 911-9111',
        'email': 'info@citygeneral.com',
        'hospital': 'City General Hospital',
        'department': 'Emergency & Maternity',
        'address': '123 Medical Center Drive, City, State 12345',
        'type': 'hospital',
        'availability': '24/7 Emergency',
        'emergencyContact': true,
        'photoColor': Color(0xFFF44336),
      },
      {
        'id': '5',
        'name': 'Emergency Helpline',
        'role': '24/7 Pregnancy Support',
        'phone': '+1 (800) 123-4567',
        'email': 'support@pregnancyhelpline.org',
        'hospital': 'National Pregnancy Helpline',
        'department': 'Emergency Support',
        'address': 'Available Nationwide',
        'type': 'emergency',
        'availability': '24/7',
        'emergencyContact': true,
        'photoColor': Color(0xFFFF9800),
      },
      {
        'id': '6',
        'name': 'Pharmacy',
        'role': 'Prescription Services',
        'phone': '+1 (555) 567-8901',
        'email': 'pharmacy@medicalcenter.com',
        'hospital': 'City General Pharmacy',
        'department': 'Pharmacy',
        'address': '123 Medical Center Drive, City, State 12345',
        'type': 'pharmacy',
        'availability': 'Mon-Sun: 7:00 AM - 11:00 PM',
        'emergencyContact': false,
        'photoColor': Color(0xFF9C27B0),
      },
      {
        'id': '7',
        'name': 'Ambulance Service',
        'role': 'Emergency Transport',
        'phone': '+1 (555) 911-0000',
        'email': 'dispatch@cityambulance.com',
        'hospital': 'City Emergency Services',
        'department': 'Emergency Transport',
        'address': 'Multiple Locations Citywide',
        'type': 'emergency',
        'availability': '24/7',
        'emergencyContact': true,
        'photoColor': Color(0xFFF44336),
      },
    ];
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final isEmergency = contact['emergencyContact'] == true;
    final type = contact['type'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E5F5), // Light purple
            Color(0xFFFCE4EC), // Light pink
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Emergency Badge
            if (isEmergency) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Color(0xFFF44336), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'EMERGENCY CONTACT',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Contact Header
            Row(
              children: [
                // Profile/Avatar Circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: contact['photoColor'].withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: contact['photoColor'].withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getContactIcon(type),
                    color: contact['photoColor'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact['role'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hospital/Organization
            _buildContactDetailRow(
              Icons.business,
              contact['hospital'],
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 8),

            // Department
            if (contact['department'] != null && (contact['department'] as String).isNotEmpty) ...[
              _buildContactDetailRow(
                Icons.people,
                contact['department'],
                const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 8),
            ],

            // Phone Number
            _buildContactActionRow(
              Icons.phone,
              contact['phone'],
              const Color(0xFFE91E63),
              () => _makePhoneCall(contact['phone']),
            ),
            const SizedBox(height: 8),

            // Email
            if (contact['email'] != null && (contact['email'] as String).isNotEmpty) ...[
              _buildContactActionRow(
                Icons.email,
                contact['email'],
                const Color(0xFFFF9800),
                () => _sendEmail(contact['email']),
              ),
              const SizedBox(height: 8),
            ],

            // Address
            _buildContactDetailRow(
              Icons.location_on,
              contact['address'],
              const Color(0xFF9C27B0),
            ),
            const SizedBox(height: 8),

            // Availability
            _buildContactDetailRow(
              Icons.access_time,
              contact['availability'],
              const Color(0xFF607D8B),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Call Now',
                    Icons.phone,
                    const Color(0xFFE91E63),
                    () => _makePhoneCall(contact['phone']),
                  ),
                ),
                const SizedBox(width: 8),
                if (contact['email'] != null && (contact['email'] as String).isNotEmpty) ...[
                  Expanded(
                    child: _buildActionButton(
                      'Send Email',
                      Icons.email,
                      const Color(0xFFFF9800),
                      () => _sendEmail(contact['email']),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _buildActionButton(
                    'Get Directions',
                    Icons.directions,
                    const Color(0xFF2196F3),
                    () => _getDirections(contact['address']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetailRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF2C2C2C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactActionRow(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContactIcon(String type) {
    switch (type) {
      case 'doctor':
        return Icons.medical_services;
      case 'hospital':
        return Icons.local_hospital;
      case 'emergency':
        return Icons.emergency;
      case 'pharmacy':
        return Icons.local_pharmacy;
      default:
        return Icons.person;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot make call to $phoneNumber'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot send email to $email'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }

  void _getDirections(String address) {
    // TODO: Implement maps integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to $address'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC), // Light pink
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', _currentIndex == 0),
            _buildNavItem(Icons.assignment_outlined, 'View Log', _currentIndex == 1),
            _buildNavItem(Icons.calendar_today_outlined, 'Appointments', _currentIndex == 2),
            _buildNavItem(Icons.contact_phone_outlined, 'Contacts', _currentIndex == 3),
            _buildNavItem(Icons.menu_book_outlined, 'Learn', _currentIndex == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final index = _getIndexForLabel(label);
    return GestureDetector(
      onTap: () => FamilyNavigationHandler.navigateToScreen(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFF8BBD0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFFE91E63).withOpacity(0.6),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFFE91E63).withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'View Log':
        return 1;
      case 'Appointments':
        return 2;
      case 'Contacts':
        return 3;
      case 'Learn':
        return 4;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergencyContacts = _contacts.where((c) => c['emergencyContact'] == true).toList();
    final regularContacts = _contacts.where((c) => c['emergencyContact'] == false).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE4EC), // Light pink
              Color(0xFFE3F2FD), // Light blue
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar (Same as Home Page)
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.9),
                    const Color(0xFF2196F3).withOpacity(0.9),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 48), // For balance
                  Expanded(
                    child: Center(
                      child: Text(
                        'Safe Mother',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  // Fixed Profile Icon with Navigation
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                    child: IconButton(
                      onPressed: () {
                        FamilyNavigationHandler.navigateToProfile(context);
                      },
                      icon: const Icon(
                        Icons.person_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF3E5F5), // Light purple
                            Color(0xFFFCE4EC), // Light pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.contact_phone,
                              color: Color(0xFFE91E63),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Emergency & Medical Contacts",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quick access to healthcare providers and emergency services',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_isLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ] else if (_contacts.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF3E5F5), // Light purple
                              Color(0xFFFCE4EC), // Light pink
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.contact_phone_outlined,
                              size: 64,
                              color: const Color(0xFFE91E63).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Contacts Available',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Medical contacts will appear here when added',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Emergency Contacts Section
                      if (emergencyContacts.isNotEmpty) ...[
                        Text(
                          'Emergency Contacts',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Available 24/7 for urgent situations',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...emergencyContacts.map((contact) => _buildContactCard(contact)),
                        const SizedBox(height: 24),
                      ],

                      // Regular Contacts Section
                      if (regularContacts.isNotEmpty) ...[
                        Text(
                          'Medical Team & Services',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Healthcare providers and support services',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...regularContacts.map((contact) => _buildContactCard(contact)),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}