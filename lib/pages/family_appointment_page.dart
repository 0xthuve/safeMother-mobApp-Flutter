import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../navigation/family_navigation_handler.dart';

class FamilyAppointmentsScreen extends StatefulWidget {
  const FamilyAppointmentsScreen({super.key});

  @override
  State<FamilyAppointmentsScreen> createState() => _FamilyAppointmentsScreenState();
}

class _FamilyAppointmentsScreenState extends State<FamilyAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _linkedPatientName = "Sarah";
  int _currentIndex = 2; // Appointments tab is active

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _appointments = _getMockAppointments();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getMockAppointments() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'title': 'Prenatal Checkup',
        'doctor': 'Dr. Sarah Johnson',
        'specialization': 'Obstetrician',
        'date': DateTime(now.year, now.month, now.day + 2, 14, 30),
        'duration': '45 mins',
        'location': 'City General Hospital',
        'address': '123 Medical Center, City',
        'status': 'upcoming',
        'type': 'routine',
        'notes': 'Regular monthly checkup',
        'preparation': 'Bring ultrasound reports',
      },
      {
        'id': '2',
        'title': 'Ultrasound Scan',
        'doctor': 'Dr. Michael Chen',
        'specialization': 'Radiologist',
        'date': DateTime(now.year, now.month, now.day + 7, 10, 0),
        'duration': '30 mins',
        'location': 'Women\'s Health Center',
        'address': '456 Health Avenue, City',
        'status': 'upcoming',
        'type': 'scan',
        'notes': '20-week anatomy scan',
        'preparation': 'Drink 1 liter water before appointment',
      },
      {
        'id': '3',
        'title': 'Nutrition Consultation',
        'doctor': 'Dr. Emily Davis',
        'specialization': 'Nutritionist',
        'date': DateTime(now.year, now.month, now.day + 14, 11, 15),
        'duration': '60 mins',
        'location': 'Wellness Clinic',
        'address': '789 Wellness Street, City',
        'status': 'upcoming',
        'type': 'consultation',
        'notes': 'Discuss pregnancy diet plan',
        'preparation': 'Bring food diary',
      },
      {
        'id': '4',
        'title': 'Blood Work',
        'doctor': 'Dr. Robert Wilson',
        'specialization': 'Pathologist',
        'date': DateTime(now.year, now.month, now.day - 3, 9, 0),
        'duration': '20 mins',
        'location': 'City Lab Center',
        'address': '321 Test Street, City',
        'status': 'completed',
        'type': 'lab',
        'notes': 'Complete blood count and glucose test',
        'results': 'All values within normal range',
      },
      {
        'id': '5',
        'title': 'Prenatal Yoga Class',
        'doctor': 'Instructor Maria Garcia',
        'specialization': 'Yoga Instructor',
        'date': DateTime(now.year, now.month, now.day + 1, 16, 0),
        'duration': '60 mins',
        'location': 'Peaceful Yoga Studio',
        'address': '654 Relaxation Road, City',
        'status': 'upcoming',
        'type': 'wellness',
        'notes': 'Beginner prenatal yoga',
        'preparation': 'Bring yoga mat and water bottle',
      },
    ];
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final isUpcoming = appointment['status'] == 'upcoming';
    final date = appointment['date'] as DateTime;
    final isToday = _isSameDay(date, DateTime.now());
    final isTomorrow = _isSameDay(date, DateTime.now().add(const Duration(days: 1)));

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
            // Header with Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUpcoming 
                        ? const Color(0xFFE91E63).withOpacity(0.1)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? 'UPCOMING' : 'COMPLETED',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isUpcoming ? const Color(0xFFE91E63) : const Color(0xFF4CAF50),
                    ),
                  ),
                ),
                if (isToday) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TODAY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ),
                ] else if (isTomorrow) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TOMORROW',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Appointment Title and Type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getAppointmentTypeColor(appointment['type']).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAppointmentIcon(appointment['type']),
                    color: _getAppointmentTypeColor(appointment['type']),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment['title'],
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and Time
            _buildDetailRow(
              Icons.calendar_today,
              '${DateFormat('EEE, MMM dd, yyyy').format(date)} • ${DateFormat('hh:mm a').format(date)} • ${appointment['duration']}',
              const Color(0xFFE91E63),
            ),
            const SizedBox(height: 8),

            // Doctor Information
            _buildDetailRow(
              Icons.medical_services,
              '${appointment['doctor']} • ${appointment['specialization']}',
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 8),

            // Location
            _buildDetailRow(
              Icons.location_on,
              '${appointment['location']}',
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 12),

            // Notes
            if (appointment['notes'] != null && (appointment['notes'] as String).isNotEmpty) ...[
              _buildInfoSection(
                'Notes',
                appointment['notes'],
                Icons.note,
                const Color(0xFFFF9800),
              ),
              const SizedBox(height: 8),
            ],

            // Preparation
            if (isUpcoming && appointment['preparation'] != null && (appointment['preparation'] as String).isNotEmpty) ...[
              _buildInfoSection(
                'Preparation',
                appointment['preparation'],
                Icons.checklist,
                const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 8),
            ],

            // Results (for completed appointments)
            if (!isUpcoming && appointment['results'] != null && (appointment['results'] as String).isNotEmpty) ...[
              _buildInfoSection(
                'Results',
                appointment['results'],
                Icons.assignment_turned_in,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 8),
            ],

            // Action Buttons
            if (isUpcoming) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Add to Calendar',
                      Icons.calendar_today,
                      const Color(0xFF2196F3),
                      () {
                        _addToCalendar(appointment);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      'Get Directions',
                      Icons.directions,
                      const Color(0xFF4CAF50),
                      () {
                        _getDirections(appointment);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
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

  Widget _buildInfoSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
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

  IconData _getAppointmentIcon(String type) {
    switch (type) {
      case 'routine':
        return Icons.medical_services;
      case 'scan':
        return Icons.visibility;
      case 'consultation':
        return Icons.people;
      case 'lab':
        return Icons.science;
      case 'wellness':
        return Icons.self_improvement;
      default:
        return Icons.event;
    }
  }

  Color _getAppointmentTypeColor(String type) {
    switch (type) {
      case 'routine':
        return const Color(0xFFE91E63);
      case 'scan':
        return const Color(0xFF2196F3);
      case 'consultation':
        return const Color(0xFFFF9800);
      case 'lab':
        return const Color(0xFF4CAF50);
      case 'wellness':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF757575);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _addToCalendar(Map<String, dynamic> appointment) {
    // TODO: Implement calendar integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${appointment['title']}" to calendar'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _getDirections(Map<String, dynamic> appointment) {
    // TODO: Implement maps integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening directions to ${appointment['location']}'),
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
    final upcomingAppointments = _appointments.where((a) => a['status'] == 'upcoming').toList();
    final completedAppointments = _appointments.where((a) => a['status'] == 'completed').toList();

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
                              Icons.calendar_today,
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
                                  "$_linkedPatientName's Appointments",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track and manage healthcare appointments',
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
                    ] else if (_appointments.isEmpty) ...[
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
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: const Color(0xFFE91E63).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Appointments',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appointments will appear here when scheduled',
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
                      // Upcoming Appointments Section
                      if (upcomingAppointments.isNotEmpty) ...[
                        Text(
                          'Upcoming Appointments',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...upcomingAppointments.map((appointment) => _buildAppointmentCard(appointment)),
                        const SizedBox(height: 24),
                      ],

                      // Completed Appointments Section
                      if (completedAppointments.isNotEmpty) ...[
                        Text(
                          'Completed Appointments',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...completedAppointments.map((appointment) => _buildAppointmentCard(appointment)),
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