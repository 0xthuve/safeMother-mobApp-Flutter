import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'navigation_handler.dart';

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
  final int _currentIndex = 1;
  late final TextEditingController _bloodPressureController;
  late final TextEditingController _weightController;
  late final TextEditingController _babyKicksController;
  late final TextEditingController _symptomsController;
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
    'Fatigued',
  ];

  // Telemedicine state
  // These fields are set/used in dialogs; analyzer may think they're unused.
  // ignore: unused_field
  String? _selectedDoctor;
  // ignore: unused_field
  DateTime? _selectedDate;
  // ignore: unused_field
  TimeOfDay? _selectedTime;

  // Appointments
  List<Map<String, dynamic>> _appointments = [];

  // SharedPreferences instance
  late SharedPreferences _prefs;

  // Configurable emergency number
  final String _emergencyNumber = '911'; // Change based on region

  @override
  void initState() {
    super.initState();
    _bloodPressureController = TextEditingController();
    _weightController = TextEditingController();
    _babyKicksController = TextEditingController();
    _symptomsController = TextEditingController();
    _initializePrefs();
    _loadAppointments();
  }

  @override
  void dispose() {
    _bloodPressureController.dispose();
    _weightController.dispose();
    _babyKicksController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPrefilledInfo();
  }

  Future<void> _loadPrefilledInfo() async {
    setState(() {
      _currentLocation = _prefs.getString('currentLocation') ?? 'Not set';
      _medicalConditions = _prefs.getString('medicalConditions') ?? 'None';
      _emergencyContacts = _prefs.getString('emergencyContacts') ?? 'Not set';
    });
  }

  Future<void> _loadAppointments() async {
    final jsonString = _prefs.getString('appointments');
    if (jsonString != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonString);
        setState(() {
          _appointments = list.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  Future<void> _saveAppointments() async {
    try {
      await _prefs.setString('appointments', jsonEncode(_appointments));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving appointments: $e')),
      );
    }
  }

  Future<void> _savePrefilledInfo(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving $key: $e')),
      );
    }
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
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Count Baby Kicks'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Press the button each time you feel a kick:'),
                  const SizedBox(height: 20),
                  Text(
                    'Kicks: $_kickCount',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setStateDialog(() {
                        _kickCount++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
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
    String? localSelectedDoctor;
    DateTime? localSelectedDate;
    TimeOfDay? localSelectedTime;
    final localSymptomsController = TextEditingController();

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
                          initialValue: localSelectedDoctor,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Dr. Anya Sharma',
                              child: Text('Dr. Anya Sharma - Obstetrician'),
                            ),
                            DropdownMenuItem(
                              value: 'Dr. Ethan Patel',
                              child: Text('Dr. Ethan Patel - Pediatrician'),
                            ),
                            DropdownMenuItem(
                              value: 'Dr. Sophia Chen',
                              child: Text('Dr. Sophia Chen - Gynecologist'),
                            ),
                            DropdownMenuItem(
                              value: 'Dr. Michael Rodriguez',
                              child: Text('Dr. Michael Rodriguez - Nutritionist'),
                            ),
                          ],
                          onChanged: (value) {
                            setStatePopup(() {
                              localSelectedDoctor = value;
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
                            localSelectedDate == null
                                ? 'Select appointment date'
                                : DateFormat('MMM dd, yyyy').format(localSelectedDate!),
                            style: TextStyle(
                              color: localSelectedDate == null ? Colors.grey : Colors.black,
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
                                localSelectedDate = pickedDate;
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
                            localSelectedTime == null
                                ? 'Select appointment time'
                                : localSelectedTime!.format(context),
                            style: TextStyle(
                              color: localSelectedTime == null ? Colors.grey : Colors.black,
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
                                localSelectedTime = pickedTime;
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
                        controller: localSymptomsController,
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
                            if (localSelectedDoctor == null ||
                                localSelectedDate == null ||
                                localSelectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select doctor, date, and time'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Appointment'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Doctor: $localSelectedDoctor'),
                                      Text(
                                        'Date: ${DateFormat('MMM dd, yyyy').format(localSelectedDate!)}',
                                      ),
                                      Text('Time: ${localSelectedTime!.format(context)}'),
                                      if (localSymptomsController.text.isNotEmpty)
                                        Text('Notes: ${localSymptomsController.text}'),
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
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed ?? false) {
                              Navigator.pop(context, true);
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
                            style: TextStyle(color: Color(0xFF638763)),
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
      setState(() {
        _appointments.add({
          'doctor': localSelectedDoctor!,
          'date': localSelectedDate!.toIso8601String(),
          'time': '${localSelectedTime!.hour.toString().padLeft(2, '0')}:${localSelectedTime!.minute.toString().padLeft(2, '0')}',
          'notes': localSymptomsController.text,
          'status': 'Not scheduled yet',
          'meetingLink': null,
        });
      });
      await _saveAppointments();
      _showAppointmentConfirmation(
        localSelectedDoctor!,
        localSelectedDate!,
        localSelectedTime!,
        localSymptomsController.text,
      );
      localSymptomsController.dispose();
    } else {
      localSymptomsController.dispose();
    }
  }

  void _showAppointmentConfirmation(
    String doctor,
    DateTime date,
    TimeOfDay time,
    String notes,
  ) {
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
              Text('Doctor: $doctor'),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(date)}'),
              Text('Time: ${time.format(context)}'),
              if (notes.isNotEmpty) Text('Notes: $notes'),
              const SizedBox(height: 16),
              const Text(
                'You will receive a confirmation and meeting link once the doctor accepts your request.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedDoctor = null;
                  _selectedDate = null;
                  _selectedTime = null;
                  _symptomsController.clear();
                });
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
                      onPressed: _callAmbulance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Call Ambulance ($_emergencyNumber)',
                        style: const TextStyle(
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
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF638763),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _editPrefilledInfo(
                        'Current Location',
                        'currentLocation',
                        _currentLocation,
                      );
                      _showEmergencyPopup();
                    },
                  ),
                  ListTile(
                    title: Text('Medical Conditions: $_medicalConditions'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF638763),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _editPrefilledInfo(
                        'Medical Conditions',
                        'medicalConditions',
                        _medicalConditions,
                      );
                      _showEmergencyPopup();
                    },
                  ),
                  ListTile(
                    title: Text('Emergency Contacts: $_emergencyContacts'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF638763),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _editPrefilledInfo(
                        'Emergency Contacts',
                        'emergencyContacts',
                        _emergencyContacts,
                      );
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
  }

  Future<void> _getCurrentLocation(TextEditingController controller) async {
    bool serviceEnabled;
    PermissionStatus permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    permission = await Permission.location.request();
    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        controller.text = '${position.latitude}, ${position.longitude}';
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } else if (permission.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied. Please enable it in settings.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> _pickContact(TextEditingController controller) async {
    PermissionStatus permission = await Permission.contacts.request();
    if (permission.isGranted) {
      try {
        // Request contacts with minimal data for efficiency
        List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        if (contacts.isNotEmpty) {
          Contact? selected = await showDialog<Contact>(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Select Contact'),
                children: contacts.take(10).map((contact) {
                  String name = contact.displayName;
                  String phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, contact),
                    child: Text('$name${phone.isNotEmpty ? ' - $phone' : ''}'),
                  );
                }).toList(),
              );
            },
          );
          if (selected != null) {
            String name = selected.displayName;
            String phone = selected.phones.isNotEmpty ? selected.phones.first.number : '';
            controller.text = phone.isNotEmpty ? '$name: $phone' : name;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No contacts found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing contacts: $e')),
        );
      }
    } else if (permission.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contacts permission permanently denied. Please enable it in settings.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
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
                    decoration: InputDecoration(hintText: 'Enter your $title'),
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
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title cannot be empty')),
                      );
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
    controller.dispose();
  }

  void _callAmbulance() async {
    final Uri telUri = Uri(scheme: 'tel', path: _emergencyNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching dialer: $e')),
      );
    }
  }

  void _saveSymptoms() {
    // Validate inputs
    if (_bloodPressureController.text.isNotEmpty) {
      try {
        final bp = _bloodPressureController.text.split('/');
        if (bp.length != 2 || int.tryParse(bp[0]) == null || int.tryParse(bp[1]) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter blood pressure in format: systolic/diastolic (e.g., 120/80)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid blood pressure format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_weightController.text.isNotEmpty) {
      if (double.tryParse(_weightController.text) == null || double.parse(_weightController.text) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid weight'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (_babyKicksController.text.isNotEmpty) {
      if (int.tryParse(_babyKicksController.text) == null || int.parse(_babyKicksController.text) < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid number of baby kicks'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Save functionality (e.g., to SharedPreferences or a backend)
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
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                  decoration: const BoxDecoration(color: Color.fromARGB(0, 255, 255, 255)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF111611)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Log Symptoms',
                            style: TextStyle(
                              color: const Color(0xFF111611),
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Placeholder for alignment
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Today's Date
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                          child: Text(
                            'Today - ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                            style: const TextStyle(
                              color: Color(0xFF111611),
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // Blood Pressure Input
                        Padding(
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
                            keyboardType: TextInputType.text, // Allow for systolic/diastolic format
                          ),
                        ),

                        // Weight Input
                        Padding(
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
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),

                        // Baby Kicks Input
                        Padding(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                          child: Text(
                            'Mood',
                            style: const TextStyle(
                              color: Color(0xFF111611),
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Padding(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                          child: Text(
                            'Telemedicine & Counseling',
                            style: const TextStyle(
                              color: Color(0xFF111611),
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Padding(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                          child: Text(
                            'Ambulance Service',
                            style: const TextStyle(
                              color: Color(0xFF111611),
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Padding(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                          child: Text(
                            'Upcoming Appointments',
                            style: const TextStyle(
                              color: Color(0xFF111611),
                              fontSize: 18,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (_appointments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('No appointments scheduled yet.'),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appt = _appointments[index];
                              DateTime? date;
                              try {
                                date = DateTime.parse(appt['date']);
                              } catch (e) {
                                return const ListTile(
                                  title: Text('Error: Invalid appointment date'),
                                );
                              }
                              String timeStr = appt['time'];
                              String status = appt['status'];
                              String? link = appt['meetingLink'];

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Doctor: ${appt['doctor']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
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
                                              _appointments[index]['meetingLink'] =
                                                  'https://meet.example.com/${DateTime.now().millisecondsSinceEpoch}';
                                            });
                                            _saveAppointments();
                                          },
                                          child: const Text('Simulate Doctor Accept'),
                                        )
                                      else if (status == 'Scheduled' && link != null)
                                        ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              final Uri url = Uri.parse(link);
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Could not launch $link')),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error launching URL: $e')),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: SizedBox(
                            width: double.infinity,
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