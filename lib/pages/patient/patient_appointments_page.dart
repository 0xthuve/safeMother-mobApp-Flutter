import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../services/appointment_service.dart';
import '../../services/session_manager.dart';
import '../../models/appointment.dart';
import 'appointment_booking_page.dart';

class PatientAppointmentsPage extends StatefulWidget {
  const PatientAppointmentsPage({super.key});

  @override
  State<PatientAppointmentsPage> createState() =>
      _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage>
    with SingleTickerProviderStateMixin {
  final AppointmentService _appointmentService = AppointmentService();
  late TabController _tabController;

  List<Appointment> _allAppointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  bool _isLoading = true;
  StreamSubscription<List<Appointment>>? _appointmentsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _appointmentsSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _setupRealtimeListener() async {
    setState(() => _isLoading = true);

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('User not logged in');

      // Cancel any existing subscription
      _appointmentsSubscription?.cancel();

      // Set up real-time listener
      _appointmentsSubscription = _appointmentService
          .getPatientAppointmentsStream(userId)
          .listen(
        (appointments) {
          if (mounted) {
            _processAppointments(appointments);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load appointments: $error')),
            );
          }
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to setup real-time listener: $e')),
        );
      }
    }
  }

  void _processAppointments(List<Appointment> appointments) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    final activeStatuses = [
      'pending',
      'scheduled',
      'rescheduled',
      'confirmed'
    ];

    setState(() {
      _allAppointments = appointments;

      _upcomingAppointments = appointments.where((a) {
        final appointmentDateOnly = DateTime(
            a.appointmentDate.year, a.appointmentDate.month, a.appointmentDate.day);
        final isNotPast = appointmentDateOnly.isAfter(todayOnly) ||
            appointmentDateOnly.isAtSameMomentAs(todayOnly);
        final status = a.status.toLowerCase().trim();
        return isNotPast && activeStatuses.contains(status);
      }).toList();

      _pastAppointments = appointments.where((a) {
        final appointmentDateOnly = DateTime(
            a.appointmentDate.year, a.appointmentDate.month, a.appointmentDate.day);
        final isPastDate = appointmentDateOnly.isBefore(todayOnly);
        final status = a.status.toLowerCase().trim();
        return isPastDate || status == 'cancelled' || status == 'completed';
      }).toList();

      _isLoading = false;
    });
  }

  // Manual refresh method for pull-to-refresh
  Future<void> _refreshAppointments() async {
    // The real-time listener will automatically update,
    // but we can show a loading indicator briefly
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    // The listener will handle the actual refresh
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _appointmentService.cancelAppointment(
          appointment.id!,
          'Cancelled by patient',
        );
        // Real-time listener will automatically update the UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment: $e')),
        );
      }
    }
  }

  Future<void> _bookNewAppointment() async {
    const doctorId = "0AludVmmD2OXGCn1i3M5UElBMSG2";
    const doctorName = "Dr. Sarah Johnson";

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppointmentBookingPage(
          doctorId: doctorId,
          doctorName: doctorName,
        ),
      ),
    );

    // Real-time listener will automatically update when new appointment is booked
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final statusText = _getStatusText(appointment.status);

    final canCancel = [
      'pending',
      'confirmed',
      'scheduled',
      'rescheduled'
    ].contains(appointment.status.toLowerCase().trim());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Dr. Sarah Johnson',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (appointment.reason.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.edit, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.reason,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (appointment.isVideoCallEnabled) ...[
              Row(
                children: [
                  Icon(Icons.videocam, color: Colors.green[600], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Video call enabled',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (canCancel) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _cancelAppointment(appointment),
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'scheduled':
        return Colors.blueGrey;
      case 'rescheduled':
        return Colors.purple;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'scheduled':
        return 'Scheduled';
      case 'rescheduled':
        return 'Rescheduled';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _bookNewAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Book New Appointment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshAppointments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing appointments...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshAppointments,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All appointments
                  _allAppointments.isEmpty
                      ? _buildEmptyState(
                          'No appointments found.\nBook your first appointment!',
                          Icons.calendar_today,
                        )
                      : ListView.builder(
                          itemCount: _allAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(_allAppointments[index]);
                          },
                        ),
                  // Upcoming
                  _upcomingAppointments.isEmpty
                      ? _buildEmptyState(
                          'No upcoming appointments.\nBook a new appointment!',
                          Icons.calendar_month,
                        )
                      : ListView.builder(
                          itemCount: _upcomingAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(_upcomingAppointments[index]);
                          },
                        ),
                  // Past
                  _pastAppointments.isEmpty
                      ? _buildEmptyState(
                          'No past appointments found.',
                          Icons.history,
                        )
                      : ListView.builder(
                          itemCount: _pastAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(_pastAppointments[index]);
                          },
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bookNewAppointment,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
