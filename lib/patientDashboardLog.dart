import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

void main() {
  runApp(const PregnancyAppLog());
}

class PregnancyAppLog extends StatelessWidget {
  const PregnancyAppLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF9F7F9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63), // Pink
          secondary: const Color(0xFF9C27B0), // Purple
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const LogScreen(),
    );
  }
}

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  int _currentIndex = 1;
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _babyKicksController = TextEditingController();
  String _selectedMood = '';
  int _kickCount = 0;
  bool _isCounting = false;
  
  // Pre-filled information
  String _currentLocation = 'Not set';
  String _medicalConditions = 'None';
  String _emergencyContacts = 'Not set';
  
  final List<String> _moodOptions = [
    'Joyful',
    'Neutral',
    'Down',
    'Worried',
    'Fatigued'
  ];

  // Telemedicine state
  String? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _symptomsController = TextEditingController();

  // Appointments
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadPrefilledInfo();
    _loadAppointments();
  }

  Future<void> _loadPrefilledInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocation = prefs.getString('currentLocation') ?? 'Not set';
      _medicalConditions = prefs.getString('medicalConditions') ?? 'None';
      _emergencyContacts = prefs.getString('emergencyContacts') ?? 'Not set';
    });
  }

  Future<void> _loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('appointments');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      setState(() {
        _appointments = list.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appointments', jsonEncode(_appointments));
  }

  Future<void> _savePrefilledInfo(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  void _startKickCounting() {
    setState(() {
      _isCounting = true;
      _kickCount = 0;
    });
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Count Baby Kicks'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Press the button each time you feel a kick:'),
                  const SizedBox(height: 20),
                  Text('Kicks: $_kickCount', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _kickCount++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: const Text('Kicked!!'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isCounting = false;
                      _babyKicksController.text = _kickCount.toString();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showTelemedicinePopup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Schedule a Consultation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Doctor Selection
                      const Text(
                        'Select Doctor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedDoctor,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Dr. Anya Sharma', child: Text('Dr. Anya Sharma - Obstetrician')),
                            DropdownMenuItem(value: 'Dr. Ethan Patel', child: Text('Dr. Ethan Patel - Pediatrician')),
                            DropdownMenuItem(value: 'Dr. Sophia Chen', child: Text('Dr. Sophia Chen - Gynecologist')),
                            DropdownMenuItem(value: 'Dr. Michael Rodriguez', child: Text('Dr. Michael Rodriguez - Nutritionist')),
                          ],
                          onChanged: (value) {
                            setStatePopup(() {
                              _selectedDoctor = value;
                            });
                          },
                          hint: const Text('Choose a doctor'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Selection
                      const Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            _selectedDate == null 
                              ? 'Select appointment date'
                              : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (pickedDate != null) {
                              setStatePopup(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Time Selection
                      const Text(
                        'Select Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            _selectedTime == null 
                              ? 'Select appointment time'
                              : _selectedTime!.format(context),
                            style: TextStyle(
                              color: _selectedTime == null ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setStatePopup(() {
                                _selectedTime = pickedTime;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Symptoms/Notes
                      const Text(
                        'Symptoms or Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _symptomsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe your symptoms or concerns',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Schedule Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_selectedDoctor == null || _selectedDate == null || _selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select doctor, date and time'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            // Show confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Appointment'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Doctor: $_selectedDoctor'),
                                      Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'),
                                      Text('Time: ${_selectedTime!.format(context)}'),
                                      if (_symptomsController.text.isNotEmpty)
                                        Text('Notes: ${_symptomsController.text}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 221, 221, 221),
                                      ),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed ?? false) {
                              Navigator.pop(context, true); // Close telemedicine with true
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Schedule Appointment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF638763),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result ?? false) {
      // Add appointment
      _appointments.add({
        'doctor': _selectedDoctor!,
        'date': _selectedDate!.toIso8601String(),
        'time': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'notes': _symptomsController.text,
        'status': 'Not scheduled yet',
        'meetingLink': null,
      });
      await _saveAppointments();
      setState(() {});
      _showAppointmentConfirmation();
    }
  }

  void _showAppointmentConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Scheduled'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your appointment has been scheduled successfully!'),
              const SizedBox(height: 16),
              Text('Doctor: $_selectedDoctor'),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'),
              Text('Time: ${_selectedTime!.format(context)}'),
              const SizedBox(height: 16),
              const Text('You will receive a confirmation and meeting link once the doctor accepts your request.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Reset form
                _selectedDoctor = null;
                _selectedDate = null;
                _selectedTime = null;
                _symptomsController.clear();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Emergency Assistance',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'In case of emergency, call for help immediately',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF161111),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _callAmbulance();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Call Ambulance',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Pre-fill Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF161111),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text('Current Location: $_currentLocation'),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF638763)),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _editPrefilledInfo('Current Location', 'currentLocation', _currentLocation);
                          _showEmergencyPopup();
                        },
                      ),
                      ListTile(
                        title: Text('Medical Conditions: $_medicalConditions'),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF638763)),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _editPrefilledInfo('Medical Conditions', 'medicalConditions', _medicalConditions);
                          _showEmergencyPopup();
                        },
                      ),
                      ListTile(
                        title: Text('Emergency Contacts: $_emergencyContacts'),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF638763)),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _editPrefilledInfo('Emergency Contacts', 'emergencyContacts', _emergencyContacts);
                          _showEmergencyPopup();
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              color: Color(0xFF638763),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _getCurrentLocation(TextEditingController controller) async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      controller.text = '${position.latitude}, ${position.longitude}';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> _pickContact(TextEditingController controller) async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      if (contacts.isNotEmpty) {
        Contact? selected = await showDialog<Contact>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Select Contact'),
              children: contacts.take(10).map((contact) {
                String name = contact.displayName ?? 'No Name';
                String phone = contact.phones?.isNotEmpty == true ? contact.phones!.first.value ?? '' : '';
                return SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, contact),
                  child: Text('$name${phone.isNotEmpty ? ' - $phone' : ''}'),
                );
              }).toList(),
            );
          },
        );
        if (selected != null) {
          String name = selected.displayName ?? 'No Name';
          String phone = selected.phones?.isNotEmpty == true ? selected.phones!.first.value ?? '' : '';
          controller.text = phone.isNotEmpty ? '$name: $phone' : name;
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied')),
      );
    }
  }

  Future<void> _editPrefilledInfo(String title, String key, String currentValue) async {
    TextEditingController controller = TextEditingController(text: currentValue);
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (key == 'currentLocation')
                    ElevatedButton(
                      onPressed: () async {
                        await _getCurrentLocation(controller);
                        setStateDialog(() {});
                      },
                      child: const Text('Get Current Location'),
                    ),
                  if (key == 'emergencyContacts')
                    ElevatedButton(
                      onPressed: () async {
                        await _pickContact(controller);
                        setStateDialog(() {});
                      },
                      child: const Text('Select Contact'),
                    ),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your $title',
                    ),
                    onChanged: (_) {
                      setStateDialog(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Current: \n${controller.text}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await _savePrefilledInfo(key, controller.text);
                      setState(() {
                        if (key == 'currentLocation') {
                          _currentLocation = controller.text;
                        } else if (key == 'medicalConditions') {
                          _medicalConditions = controller.text;
                        } else if (key == 'emergencyContacts') {
                          _emergencyContacts = controller.text;
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _callAmbulance() async {
    // Open the phone dialer with 110
    final Uri telUri = Uri(scheme: 'tel', path: '110');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer.')),
      );
    }
  }

  void _saveSymptoms() {
    // Save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Symptoms saved successfully!'),
        backgroundColor: Color(0xFFE91E63),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.assignment_outlined, 'Log', 1),
            _buildNavItem(Icons.notifications_outlined, 'Reminders', 2),
            _buildNavItem(Icons.school_outlined, 'Learn', 3),
            _buildNavItem(Icons.chat_outlined, 'Chat', 4),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5E8FF), Color(0xFFF9F7F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative elements
          Positioned(
            top: -50,
            left: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(0xFFD1C4E9).withOpacity(0.4),
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1BEE7).withOpacity(0.3),
              ),
            ),
          ),
          
          Positioned(
            right: -60,
            bottom: -90,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFC5CAE9).withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF111611)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 48),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 262,
                                child: Text(
                                  'Log Symptoms',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF111611),
                                    fontSize: 18,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        // Today's Date
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 358,
                                child: Text(
                                  'Today - ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                                  style: const TextStyle(
                                    color: Color(0xFF111611),
                                    fontSize: 18,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Blood Pressure Input
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _bloodPressureController,
                            decoration: InputDecoration(
                              labelText: 'Blood Pressure (mmHg)',
                              labelStyle: const TextStyle(
                                color: Color(0xFF638763),
                                fontSize: 16,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEFF4EF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        
                        // Weight Input
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: 'Weight (lbs)',
                              labelStyle: const TextStyle(
                                color: Color(0xFF638763),
                                fontSize: 16,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEFF4EF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        
                        // Baby Kicks Input
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _babyKicksController,
                                  decoration: InputDecoration(
                                    labelText: 'Baby Kicks',
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF638763),
                                      fontSize: 16,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFEFF4EF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF4EF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: _startKickCounting,
                                  child: Text(
                                    _isCounting ? 'Counting...' : 'Count Kicks',
                                    style: const TextStyle(
                                      color: Color(0xFF111611),
                                      fontSize: 14,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Mood Selection
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 358,
                                child: Text(
                                  'Mood',
                                  style: TextStyle(
                                    color: Color(0xFF111611),
                                    fontSize: 18,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _moodOptions.map((mood) {
                              return FilterChip(
                                label: Text(mood),
                                selected: _selectedMood == mood,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedMood = selected ? mood : '';
                                  });
                                },
                                selectedColor: const Color(0xFFE91E63),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: _selectedMood == mood ? Colors.white : const Color(0xFF111611),
                                  fontSize: 14,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w500,
                                ),
                                backgroundColor: const Color(0xFFEFF4EF),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFDBE5DB),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        // Telemedicine & Counseling
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 358,
                                child: Text(
                                  'Telemedicine & Counseling',
                                  style: TextStyle(
                                    color: Color(0xFF111611),
                                    fontSize: 18,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: _showTelemedicinePopup,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.medical_services, color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Get Advice',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Ambulance Service
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 358,
                                child: Text(
                                  'Ambulance Service',
                                  style: TextStyle(
                                    color: Color(0xFF111611),
                                    fontSize: 18,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: _showEmergencyPopup,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.local_hospital, color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Call Ambulance',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Upcoming Appointments
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 358,
                                child: Text(
                                  'Upcoming Appointments',
                                  style: TextStyle(
                                    color: Color(0xFF111611),
                                    fontSize: 18,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w700,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_appointments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text('No appointments scheduled yet.'),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appt = _appointments[index];
                              DateTime date = DateTime.parse(appt['date']);
                              String timeStr = appt['time'];
                              String status = appt['status'];
                              String? link = appt['meetingLink'];

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Doctor: ${appt['doctor']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Date: ${DateFormat('MMM dd, yyyy').format(date)}'),
                                      Text('Time: $timeStr'),
                                      if (appt['notes'].isNotEmpty) Text('Notes: ${appt['notes']}'),
                                      const SizedBox(height: 8),
                                      Text('Status: $status'),
                                      if (status == 'Not scheduled yet')
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _appointments[index]['status'] = 'Scheduled';
                                              _appointments[index]['meetingLink'] = 'https://meet.example.com/${DateTime.now().millisecondsSinceEpoch}';
                                            });
                                            _saveAppointments();
                                          },
                                          child: const Text('Simulate Doctor Accept'),
                                        )
                                      else if (status == 'Scheduled' && link != null)
                                        ElevatedButton(
                                          onPressed: () async {
                                            final Uri url = Uri.parse(link);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Could not launch $link')),
                                              );
                                            }
                                          },
                                          child: const Text('Join Meeting'),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Save Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: ElevatedButton(
                            onPressed: _saveSymptoms,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}