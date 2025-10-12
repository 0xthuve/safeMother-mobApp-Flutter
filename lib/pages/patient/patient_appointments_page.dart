import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../services/appointment_service.dart';
import '../../services/session_manager.dart';
import '../../services/backend_service.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';

class PatientAppointmentsPage extends StatefulWidget {
  const PatientAppointmentsPage({super.key});

  @override
  State<PatientAppointmentsPage> createState() =>
      _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage>
    with SingleTickerProviderStateMixin {
  final AppointmentService _appointmentService = AppointmentService();
  final BackendService _backendService = BackendService();
  late TabController _tabController;

  List<Appointment> _allAppointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  List<Doctor> _linkedDoctors = [];
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

      // Load linked doctors
      await _loadLinkedDoctors();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to setup real-time listener: $e')),
        );
      }
    }
  }

  Future<void> _loadLinkedDoctors() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      final doctorsData = await _backendService.getLinkedDoctorsWithContact(userId);

      // Convert Map data to Doctor objects
      final doctors = doctorsData.map((data) => Doctor(
        id: data['id']?.toString(),
        firebaseUid: data['firebaseUid'],
        name: data['name'] ?? 'Unknown Doctor',
        email: data['email'] ?? '',
        phone: data['phoneNumber'] ?? '',
        specialization: data['specialization'] ?? 'General Practice',
        licenseNumber: '',
        hospital: data['hospital'] ?? 'Unknown Hospital',
        experience: '0 years',
        bio: 'Healthcare professional',
        profileImage: '',
        rating: 0.0,
        totalPatients: 0,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();

      if (mounted) {
        setState(() {
          _linkedDoctors = doctors;
        });
      }

      print('Successfully loaded ${doctors.length} linked doctors for patient $userId');
    } catch (e) {
      print('Error loading linked doctors: $e');
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
    if (_linkedDoctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No linked doctors available. Please link with a doctor first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show doctor selection dialog
    final selectedDoctor = await showDialog<Doctor>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Doctor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _linkedDoctors.map((doctor) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Text(
                  doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                doctor.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                doctor.specialization,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(
                Icons.calendar_today,
                color: Colors.teal,
                size: 20,
              ),
              onTap: () => Navigator.pop(context, doctor),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedDoctor != null) {
      _showBookAppointmentBottomSheet(selectedDoctor);
    }
  }

  void _showBookAppointmentBottomSheet(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookAppointmentBottomSheet(
        linkedDoctors: [doctor],
        selectedDoctor: doctor,
        onAppointmentBooked: () {
          // Real-time listener will automatically update when new appointment is booked
        },
      ),
    );
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

// Book Appointment Bottom Sheet
class _BookAppointmentBottomSheet extends StatefulWidget {
  final List<Doctor> linkedDoctors;
  final Doctor? selectedDoctor;
  final VoidCallback onAppointmentBooked;

  const _BookAppointmentBottomSheet({
    required this.linkedDoctors,
    this.selectedDoctor,
    required this.onAppointmentBooked,
  });

  @override
  State<_BookAppointmentBottomSheet> createState() => _BookAppointmentBottomSheetState();
}

class _BookAppointmentBottomSheetState extends State<_BookAppointmentBottomSheet> {
  final AppointmentService _appointmentService = AppointmentService();
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String _reason = '';
  String _notes = '';
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDoctor = widget.selectedDoctor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Selection
                  const Text(
                    'Select Doctor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Doctor>(
                    value: _selectedDoctor,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: widget.linkedDoctors.map((doctor) {
                      return DropdownMenuItem(
                        value: doctor,
                        child: Text(doctor.name),
                      );
                    }).toList(),
                    onChanged: (doctor) {
                      setState(() {
                        _selectedDoctor = doctor;
                        _selectedDate = null;
                        _selectedTimeSlot = null;
                        _availableTimeSlots = [];
                      });
                    },
                    hint: const Text('Choose your doctor'),
                  ),

                  const SizedBox(height: 16),

                  // Date Selection
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectedDoctor != null ? _selectDate : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Choose appointment date',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time Slot Selection
                  if (_availableTimeSlots.isNotEmpty) ...[
                    const Text(
                      'Select Time',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimeSlots.map((slot) {
                        final isSelected = _selectedTimeSlot == slot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reason
                  const Text(
                    'Reason for Visit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'e.g., Routine checkup, Specific concern',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: (value) => _reason = value,
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  const Text(
                    'Additional Notes (Optional)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any specific concerns or questions',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    onChanged: (value) => _notes = value,
                  ),

                  const SizedBox(height: 24),

                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canBookAppointment() ? _bookAppointment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Book Appointment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 90));

    final date = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTimeSlot = null;
      });
      await _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;

    try {
      final slots = await _appointmentService.getAvailableTimeSlots(
        doctorId: _selectedDoctor!.firebaseUid ?? _selectedDoctor!.id.toString(),
        date: _selectedDate!,
      );
      setState(() {
        _availableTimeSlots = slots;
      });
    } catch (e) {
      print('Error loading time slots: $e');
    }
  }

  bool _canBookAppointment() {
    return _selectedDoctor != null &&
           _selectedDate != null &&
           _selectedTimeSlot != null &&
           _reason.isNotEmpty &&
           !_isLoading;
  }

  Future<void> _bookAppointment() async {
    if (!_canBookAppointment()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final success = await _appointmentService.bookAppointment(
        patientId: userId,
        doctorId: _selectedDoctor!.firebaseUid ?? _selectedDoctor!.id.toString(),
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        reason: _reason,
        notes: _notes,
      );

      if (success) {
        widget.onAppointmentBooked();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
