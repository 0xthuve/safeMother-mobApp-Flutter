import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/family_navigation_handler.dart';
import '../services/family_member_service.dart';

class FamilyAppointmentsScreen extends StatefulWidget {
  const FamilyAppointmentsScreen({super.key});

  @override
  State<FamilyAppointmentsScreen> createState() =>
      _FamilyAppointmentsScreenState();
}

class _FamilyAppointmentsScreenState extends State<FamilyAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  bool _usingFallback = false;
  String _linkedPatientName = "Loading...";
  String _patientUserId = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadAppointmentsData();
  }

  Future<void> _loadAppointmentsData() async {
    try {
      setState(() {
        _isLoading = true;
        _usingFallback = false;
      });

      final user = _auth.currentUser;
      if (user != null) {
        final familyMember = await FamilyMemberService.getFamilyMember(user.uid);
        
        if (familyMember != null) {
          _patientUserId = familyMember.patientUserId;
          _linkedPatientName = await FamilyMemberService.getPatientName(_patientUserId);
          await _loadAppointmentsFromFirestore();
        } else {
          _showNoAppointmentsMessage();
        }
      }
    } catch (e) {
      print('Error loading appointments data: $e');
      _showNoAppointmentsMessage();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAppointmentsFromFirestore() async {
    try {
      // First try the optimized query with ordering
      print('Attempting optimized query with index...');
      final appointmentsQuery = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: _patientUserId)
          .orderBy('appointmentDate', descending: false)
          .get();

      if (appointmentsQuery.docs.isNotEmpty) {
        print('Optimized query successful, processing ${appointmentsQuery.docs.length} appointments');
        _processAppointments(appointmentsQuery.docs);
      } else {
        print('No appointments found with optimized query');
        _showNoAppointmentsMessage();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        print('Index is building, falling back to local sorting: ${e.message}');
        setState(() {
          _usingFallback = true;
        });
        await _loadAppointmentsWithLocalSorting();
      } else {
        print('Firebase error: ${e.code} - ${e.message}');
        _showErrorDialog('Firestore Error', 'Failed to load appointments: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      _showErrorDialog('Error', 'An unexpected error occurred while loading appointments.');
    }
  }

  Future<void> _loadAppointmentsWithLocalSorting() async {
    try {
      print('Loading appointments without server-side ordering...');
      final appointmentsQuery = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: _patientUserId)
          .get();

      if (appointmentsQuery.docs.isNotEmpty) {
        print('Found ${appointmentsQuery.docs.length} appointments, sorting locally...');
        _processAppointments(appointmentsQuery.docs);
        
        // Show temporary message about index building
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Appointments loading with basic sorting (index building...)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        _showNoAppointmentsMessage();
      }
    } catch (e) {
      print('Error in fallback loading: $e');
      _showErrorDialog('Connection Error', 'Unable to load appointments. Please check your connection and try again.');
    }
  }

  void _processAppointments(List<QueryDocumentSnapshot> docs) {
    List<Map<String, dynamic>> appointments = [];
    
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final appointment = _parseAppointmentData(data, doc.id);
      if (appointment != null) {
        appointments.add(appointment);
      }
    }
    
    // Always sort locally to ensure correct order
    appointments.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });
    
    setState(() {
      _appointments = appointments;
    });
    
    print('Processed ${appointments.length} appointments');
  }

  Map<String, dynamic>? _parseAppointmentData(Map<String, dynamic> data, String docId) {
    try {
      DateTime date;
      
      // Handle the string date format "2025-10-16T00:00:00.000"
      if (data['appointmentDate'] is String) {
        date = DateTime.parse(data['appointmentDate']);
      } else if (data['appointmentDate'] is Timestamp) {
        date = (data['appointmentDate'] as Timestamp).toDate();
      } else if (data['appointmentDate'] is DateTime) {
        date = data['appointmentDate'] as DateTime;
      } else {
        print('Invalid date format: ${data['appointmentDate']}');
        return null;
      }

      final now = DateTime.now();
      final isCompleted = date.isBefore(now);
      final status = isCompleted ? 'completed' : 'upcoming';

      return {
        'id': docId,
        'title': data['reason'] ?? 'Appointment',
        'doctor': 'Doctor', // You can fetch this later from users collection
        'specialization': 'General Practitioner',
        'date': date,
        'time': data['timeSlot'] ?? 'Not specified',
        'duration': '30 mins',
        'location': 'Medical Center',
        'address': 'Address not specified',
        'status': status,
        'type': _determineAppointmentType(data['reason']?.toString() ?? ''),
        'notes': data['notes'] ?? '',
        'prescription': data['prescription'] ?? '',
        'isVideoCallEnabled': data['isVideoCallEnabled'] ?? false,
        'videoCallUrl': data['videoCallUrl'] ?? '',
      };
    } catch (e) {
      print('Error parsing appointment data: $e');
      return null;
    }
  }

  String _determineAppointmentType(String reason) {
    final lowerReason = reason.toLowerCase();
    if (lowerReason.contains('checkup') || lowerReason.contains('routine')) {
      return 'routine';
    } else if (lowerReason.contains('scan') || lowerReason.contains('ultrasound')) {
      return 'scan';
    } else if (lowerReason.contains('consult') || lowerReason.contains('discuss')) {
      return 'consultation';
    } else if (lowerReason.contains('lab') || lowerReason.contains('blood') || lowerReason.contains('test')) {
      return 'lab';
    } else if (lowerReason.contains('emergency') || lowerReason.contains('urgent')) {
      return 'emergency';
    } else {
      return 'routine';
    }
  }

  void _showNoAppointmentsMessage() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: Color(0xFFE91E63)),
                  SizedBox(width: 12),
                  Text('No Appointments', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ],
              ),
              content: Text(
                'No appointment schedules found for $_linkedPatientName. '
                'Appointments will appear here when scheduled.',
                style: GoogleFonts.inter(color: Color(0xFF757575)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: GoogleFonts.inter(color: Color(0xFFE91E63), fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      });
    }
    
    setState(() {
      _appointments = [];
    });
  }

  void _showErrorDialog(String title, String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12),
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ],
              ),
              content: Text(message, style: GoogleFonts.inter()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: GoogleFonts.inter(color: Color(0xFFE91E63))),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadAppointmentsData(); // Retry
                  },
                  child: Text('Retry', style: GoogleFonts.inter(color: Color(0xFF2196F3))),
                ),
              ],
            );
          },
        );
      });
    }
  }

  void _refreshAppointments() {
    _loadAppointmentsData();
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
          colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUpcoming 
                        ? Color(0xFFE91E63).withOpacity(0.1)
                        : Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? 'UPCOMING' : 'COMPLETED',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isUpcoming ? Color(0xFFE91E63) : Color(0xFF4CAF50),
                    ),
                  ),
                ),
                if (_usingFallback) 
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                if (isToday) 
                  _buildDateBadge('TODAY', Color(0xFFFF9800))
                else if (isTomorrow) 
                  _buildDateBadge('TOMORROW', Color(0xFF2196F3)),
              ],
            ),
            const SizedBox(height: 16),
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
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment['title'],
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today,
              '${DateFormat('EEE, MMM dd, yyyy').format(date)} • ${appointment['time']} • ${appointment['duration']}',
              Color(0xFFE91E63),
            ),
            SizedBox(height: 8),
            _buildDetailRow(
              Icons.medical_services,
              '${appointment['doctor']} • ${appointment['specialization']}',
              Color(0xFF2196F3),
            ),
            SizedBox(height: 8),
            _buildDetailRow(
              Icons.location_on,
              '${appointment['location']}',
              Color(0xFF4CAF50),
            ),
            if (appointment['notes'] != null && (appointment['notes'] as String).isNotEmpty) ...[
              SizedBox(height: 12),
              _buildInfoSection('Notes', appointment['notes'], Icons.note, Color(0xFFFF9800)),
            ],
            if (appointment['isVideoCallEnabled'] && appointment['videoCallUrl'] != null && (appointment['videoCallUrl'] as String).isNotEmpty) ...[
              SizedBox(height: 12),
              _buildVideoCallSection(appointment['videoCallUrl']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Color(0xFF2C2C2C),
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
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCallSection(String videoCallUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.videocam, color: Colors.blue, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Video call available',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _joinVideoCall(videoCallUrl),
            child: Text(
              'Join Call',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _joinVideoCall(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining video call...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  IconData _getAppointmentIcon(String type) {
    switch (type) {
      case 'routine': return Icons.medical_services;
      case 'scan': return Icons.visibility;
      case 'consultation': return Icons.people;
      case 'lab': return Icons.science;
      case 'wellness': return Icons.self_improvement;
      case 'emergency': return Icons.emergency;
      default: return Icons.event;
    }
  }

  Color _getAppointmentTypeColor(String type) {
    switch (type) {
      case 'routine': return Color(0xFFE91E63);
      case 'scan': return Color(0xFF2196F3);
      case 'consultation': return Color(0xFFFF9800);
      case 'lab': return Color(0xFF4CAF50);
      case 'wellness': return Color(0xFF9C27B0);
      case 'emergency': return Color(0xFFF44336);
      default: return Color(0xFF757575);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
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
            colors: [Color(0xFFFCE4EC), Color(0xFFE3F2FD), Colors.white],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE91E63).withOpacity(0.9),
                    Color(0xFF2196F3).withOpacity(0.9),
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
                  const SizedBox(width: 48),
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: _refreshAppointments,
                        icon: Icon(Icons.refresh, color: Colors.white, size: 24),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                        ),
                        child: IconButton(
                          onPressed: () => FamilyNavigationHandler.navigateToProfile(context),
                          icon: Icon(Icons.person_outlined, color: Colors.white, size: 24),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAppointmentsData,
                color: Color(0xFFE91E63),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_usingFallback) _buildIndexBuildingNotice(),
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFE91E63).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.calendar_today, color: Color(0xFFE91E63), size: 28),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$_linkedPatientName's Appointments",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2C2C2C),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Track and manage healthcare appointments',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading) 
                        Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
                      else if (_appointments.isNotEmpty) ...[
                        if (upcomingAppointments.isNotEmpty) ...[
                          Text(
                            'Upcoming Appointments (${upcomingAppointments.length})',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          SizedBox(height: 16),
                          ...upcomingAppointments.map((appointment) => _buildAppointmentCard(appointment)),
                          SizedBox(height: 24),
                        ],
                        if (completedAppointments.isNotEmpty) ...[
                          Text(
                            'Completed Appointments (${completedAppointments.length})',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                          SizedBox(height: 16),
                          ...completedAppointments.map((appointment) => _buildAppointmentCard(appointment)),
                        ],
                      ] else if (!_isLoading) 
                        _buildEmptyState(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildIndexBuildingNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Appointments loading with basic sorting. Full sorting will be available soon.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No Appointments', 
            style: GoogleFonts.inter(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: Colors.grey.shade600
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No appointments found for $_linkedPatientName.', 
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', 0),
            _buildNavItem(Icons.assignment_outlined, 'View Log', 1),
            _buildNavItem(Icons.calendar_today_outlined, 'Appointments', 2),
            _buildNavItem(Icons.menu_book_outlined, 'Learn', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = index == 2;
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
              color: isActive ? Colors.white : Color(0xFFE91E63).withOpacity(0.6),
              size: 22,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isActive ? Color(0xFFE91E63) : Color(0xFFE91E63).withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}