import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/appointment_service.dart';
import '../../models/patient.dart';

class DoctorAddAppointmentPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final VoidCallback onAppointmentAdded;

  const DoctorAddAppointmentPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.onAppointmentAdded,
  });

  @override
  State<DoctorAddAppointmentPage> createState() => _DoctorAddAppointmentPageState();
}

class _DoctorAddAppointmentPageState extends State<DoctorAddAppointmentPage> {
  final AppointmentService _appointmentService = AppointmentService();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  Patient? _selectedPatient;
  List<String> _availableTimeSlots = [];
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = false;
  bool _isLoadingPatients = false;
  bool _isLoadingTimeSlots = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedPatient != null &&
           _selectedDate != null &&
           _selectedTimeSlot != null &&
           _reasonController.text.trim().isNotEmpty;
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoadingPatients = true;
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Get all users with patient role
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();

      List<Patient> patients = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          final userData = doc.data();
          
          // Create patient from user data
          String patientName = userData['name']?.toString() ?? 
                             userData['fullName']?.toString() ?? 
                             userData['firstName']?.toString() ?? 
                             'Unknown Patient';
          
          if (userData['firstName'] != null && userData['lastName'] != null) {
            patientName = '${userData['firstName']} ${userData['lastName']}';
          }
          
          final patient = Patient(
            id: doc.id,
            name: patientName,
            email: userData['email']?.toString() ?? '',
            phone: userData['phone']?.toString() ?? '',
            dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)),
            bloodType: userData['bloodType']?.toString() ?? 'Unknown',
            emergencyContact: userData['emergencyContact']?.toString() ?? '',
            emergencyPhone: userData['emergencyPhone']?.toString() ?? '',
            lastVisit: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          patients.add(patient);
        } catch (e) {
          print('Error processing patient ${doc.id}: $e');
        }
      }

      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoadingPatients = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _isLoadingPatients = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load patients: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((patient) {
          return patient.name.toLowerCase().contains(query) ||
                 patient.email.toLowerCase().contains(query) ||
                 patient.phone.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot selection
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoadingTimeSlots = true;
    });

    try {
      final slots = await _appointmentService.getAvailableTimeSlotsForDate(
        widget.doctorId,
        _selectedDate!,
      );

      setState(() {
        _availableTimeSlots = slots;
        _isLoadingTimeSlots = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTimeSlots = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load time slots: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Appointment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
                Color(0xFF1E40AF),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.1),
                    const Color(0xFF1E40AF).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Creating appointment for:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Patient Selection
            _buildSectionTitle('Select Patient'),
            const SizedBox(height: 12),
            _buildPatientSelection(),
            
            const SizedBox(height: 24),
            
            // Date Selection
            _buildSectionTitle('Select Date'),
            const SizedBox(height: 12),
            _buildDateSelection(),
            
            const SizedBox(height: 24),
            
            // Time Slot Selection
            _buildSectionTitle('Select Time Slot'),
            const SizedBox(height: 12),
            _buildTimeSlotSelection(),
            
            const SizedBox(height: 24),
            
            // Reason Field
            _buildSectionTitle('Reason for Visit *'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _reasonController,
              hintText: 'Enter reason for the appointment',
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Notes Field
            _buildSectionTitle('Additional Notes'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _notesController,
              hintText: 'Enter any additional notes (optional)',
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFormValid && !_isLoading ? _createAppointment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? const Color(0xFF2563EB) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isFormValid ? 4 : 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildPatientSelection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients by name, email, or phone...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          
          // Selected patient display
          if (_selectedPatient != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPatient!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (_selectedPatient!.email.isNotEmpty)
                          Text(
                            _selectedPatient!.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedPatient = null;
                      });
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),
          
          // Patient list
          if (_selectedPatient == null)
            Container(
              height: 200,
              child: _isLoadingPatients
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPatients.isEmpty
                      ? const Center(
                          child: Text(
                            'No patients found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                                child: Text(
                                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                              title: Text(
                                patient.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(patient.email),
                              onTap: () {
                                setState(() {
                                  _selectedPatient = patient;
                                  _searchController.clear();
                                });
                              },
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate != null 
                ? const Color(0xFF2563EB) 
                : Colors.grey.withOpacity(0.3),
          ),
          color: _selectedDate != null 
              ? const Color(0xFF2563EB).withOpacity(0.05) 
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedDate != null 
                  ? const Color(0xFF2563EB) 
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!)
                    : 'Select appointment date',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate != null 
                      ? const Color(0xFF1E293B) 
                      : Colors.grey,
                  fontWeight: _selectedDate != null 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotSelection() {
    if (_selectedDate == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Text(
          'Please select a date first',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isLoadingTimeSlots) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_availableTimeSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
          color: Colors.orange.withOpacity(0.1),
        ),
        child: const Text(
          'No available time slots for this date',
          style: TextStyle(color: Colors.orange),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Available time slots (${_availableTimeSlots.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _availableTimeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = _availableTimeSlots[index];
                final isSelected = _selectedTimeSlot == timeSlot;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlot = timeSlot;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF2563EB) 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF2563EB) 
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        timeSlot,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _createAppointment() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Creating appointment for doctor: ${widget.doctorId}');

      final appointmentId = await _appointmentService.createAppointment(
        patientId: _selectedPatient!.id!,
        doctorId: widget.doctorId, // Use the doctor's Firebase UID
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim(),
        status: 'confirmed', // Doctor-created appointments are confirmed by default
      );

      print('Appointment created successfully with ID: $appointmentId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        setState(() {
          _selectedPatient = null;
          _selectedDate = null;
          _selectedTimeSlot = null;
          _availableTimeSlots = [];
          _reasonController.clear();
          _notesController.clear();
          _searchController.clear();
          _filteredPatients = _allPatients;
        });

        // Notify parent widget
        widget.onAppointmentAdded();
      }
    } catch (e) {
      print('Error creating appointment: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create appointment: $e'),
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
}