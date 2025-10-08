import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/appointment_service.dart';
import '../../services/session_manager.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const AppointmentBookingPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final AppointmentService _appointmentService = AppointmentService();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;
  String? _currentDoctorId;

  @override
  void initState() {
    super.initState();
    _currentDoctorId = widget.doctorId;
    // Add listeners to controllers to trigger UI updates
    _reasonController.addListener(_onFormFieldChanged);
    _notesController.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    print('Form field changed - Reason: "${_reasonController.text}", Form valid: $_isFormValid');
    if (mounted) {
      setState(() {
        // Trigger rebuild to update button state
      });
    }
  }

  @override
  void didUpdateWidget(AppointmentBookingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if doctor has changed
    if (oldWidget.doctorId != widget.doctorId) {
      _resetFormForNewDoctor();
    }
  }

  void _resetFormForNewDoctor() {
    setState(() {
      _currentDoctorId = widget.doctorId;
      _selectedDate = null;
      _selectedTimeSlot = null;
      _availableTimeSlots = [];
      _isLoading = false;
    });
    _reasonController.clear();
    _notesController.clear();
  }

  bool get _isFormValid {
    final hasDate = _selectedDate != null;
    final hasTimeSlot = _selectedTimeSlot != null;
    final hasReason = _reasonController.text.trim().isNotEmpty;
    final isValid = hasDate && hasTimeSlot && hasReason;
    
    print('Form validation - Date: $hasDate, TimeSlot: $hasTimeSlot, Reason: $hasReason, Valid: $isValid');
    
    return isValid;
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onFormFieldChanged);
    _notesController.removeListener(_onFormFieldChanged);
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    // Update current doctor if it's different
    if (_currentDoctorId != widget.doctorId) {
      setState(() {
        _currentDoctorId = widget.doctorId;
      });
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
        _isLoading = true;
        print('Date changed: $_selectedDate');
      });
      _onFormFieldChanged();

      try {
        final slots = await _appointmentService.getAvailableTimeSlotsForDate(
          widget.doctorId,
          picked,
        );
        setState(() {
          _availableTimeSlots = slots;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _availableTimeSlots = AppointmentService.getAllTimeSlots();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _bookAppointment() async {
    // Ensure we're still booking for the correct doctor
    if (_currentDoctorId != widget.doctorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor selection changed. Please fill the form again.')),
      );
      _resetFormForNewDoctor();
      return;
    }

    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reason for appointment')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('DEBUG: Creating appointment with patientId: $userId, doctorId: ${widget.doctorId}');
      
      await _appointmentService.createAppointment(
        patientId: userId,
        doctorId: widget.doctorId,
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
      );
      
      print('DEBUG: Appointment created successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully! Waiting for doctor approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor change notification (only show if there's a mismatch and form has data)
            if (_currentDoctorId != null && 
                _currentDoctorId != widget.doctorId && 
                (_selectedDate != null || _selectedTimeSlot != null || _reasonController.text.isNotEmpty))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Doctor selection changed. Please fill the form again.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFormForNewDoctor,
                      child: Text(
                        'Refresh',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),

            // Doctor Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.teal,
                      child: Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctorName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Obstetrics & Gynecology',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Date Selection
            Text(
              'Select Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.teal),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Select a date'
                          : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Time Slot Selection
            if (_selectedDate != null) ...[
              Text(
                'Select Time Slot',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_availableTimeSlots.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No available time slots for this date',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTimeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (selected) {
                        // Update current doctor if it's different
                        if (_currentDoctorId != widget.doctorId) {
                          setState(() {
                            _currentDoctorId = widget.doctorId;
                          });
                        }
                        setState(() {
                          _selectedTimeSlot = selected ? slot : null;
                          print('Time slot changed: $_selectedTimeSlot');
                        });
                        _onFormFieldChanged();
                      },
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),
            ],

            // Reason for Appointment
            Text(
              'Reason for Appointment *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'e.g., Routine checkup, Follow-up consultation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.edit, color: Colors.teal),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Additional Notes
            Text(
              'Additional Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Any additional information or special requests',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.note, color: Colors.teal),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Debug info (remove in production)
            if (true) // Set to true for debugging
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Selected Date: ${_selectedDate != null ? 'Yes' : 'No'}'),
                    Text('Selected Time: ${_selectedTimeSlot != null ? 'Yes' : 'No'}'),
                    Text('Reason Filled: ${_reasonController.text.trim().isNotEmpty ? 'Yes' : 'No'}'),
                    Text('Current Doctor: $_currentDoctorId'),
                    Text('Widget Doctor: ${widget.doctorId}'),
                    Text('Form Valid: $_isFormValid'),
                    Text('Is Loading: $_isLoading'),
                    Text('Button Enabled: ${!_isLoading && _isFormValid}'),
                  ],
                ),
              ),

            // Book Appointment Button - Always show, enable when form is valid
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isLoading || !_isFormValid) 
                    ? null 
                    : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            // Form validation status
            if (!_isFormValid)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please complete the following to book appointment:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_selectedDate == null)
                      Text('• Select a date', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (_selectedTimeSlot == null)
                      Text('• Choose a time slot', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    if (_reasonController.text.trim().isEmpty)
                      Text('• Enter reason for appointment', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Information Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your appointment will be pending until approved by the doctor\n'
                      '• You will receive a notification once approved\n'
                      '• Video call option will be available for confirmed appointments\n'
                      '• Please arrive 10 minutes early for your appointment',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}