// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../navigation/doctor_navigation_handler.dart';
// import '../../navigation/doctor_bottom_navigation.dart';
// import '../../models/patient.dart';

// import '../../services/backend_service.dart';
// import '../../services/session_manager.dart';
// import '../../services/firebase_service.dart';



// class _DoctorPatientsState extends State<DoctorPatients> {
//   final int _currentIndex = 1;
//   final BackendService _backendService = BackendService();
//   List<Patient> _patients = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadPatients();
//   }

//   Future<void> _loadPatients() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       final userId = await SessionManager.getUserId();
//       if (userId == null) {
//         throw Exception('User not logged in');
//       }

//       // Use Firebase UID directly since patient requests are stored with Firebase UID
// ...existing code...

//       // Get accepted patients for this doctor using Firebase UID
//       final acceptedPatients = await _backendService.getAcceptedPatientsForDoctor(userId);

//       // Load patient details for each accepted patient
//       Map<String, Map<String, dynamic>> patientDetails = {};
//       List<Patient> realPatients = [];

//       for (final patientLink in acceptedPatients) {
//         try {
//           final patientData = await FirebaseService.getUserData(patientLink.patientId);
//           if (patientData != null) {
//             patientDetails[patientLink.patientId] = patientData;
            
//             // Convert to Patient model for compatibility with existing UI
//             final patient = Patient(
//               id: patientLink.patientId.hashCode.abs(),
//               name: patientData['fullName'] ?? 'Unknown Patient',
//               email: patientData['email'] ?? 'No email',
//               phone: patientData['phone'] ?? patientData['contact'] ?? 'No phone',
//               dateOfBirth: DateTime.tryParse(patientData['dateOfBirth'] ?? '') ?? DateTime.now(),
//               bloodType: patientData['bloodType'] ?? 'Not specified',
//               emergencyContact: patientData['emergencyContact'] ?? 'Not specified',
//               emergencyPhone: patientData['emergencyPhone'] ?? 'Not specified',
//               medicalHistory: patientData['medicalHistory'] ?? 'None',
//               allergies: patientData['allergies'] ?? 'None',
//               currentMedications: patientData['currentMedications'] ?? 'None',
//               lastVisit: DateTime.tryParse(patientData['lastVisit'] ?? '') ?? patientLink.linkedDate,
//               assignedDoctorId: userId.hashCode.abs(),
//               createdAt: patientLink.createdAt,
//               updatedAt: patientLink.updatedAt,
//             );
//             realPatients.add(patient);
//           } else {
//             // Fallback patient data when Firebase data is not available
//             final patient = Patient(
//               id: patientLink.patientId.hashCode.abs(),
//               name: 'Patient ${patientLink.patientId.substring(0, 8)}',
//               email: 'Permission restricted',
//               phone: 'Contact via app',
//               dateOfBirth: DateTime.now().subtract(const Duration(days: 25 * 365)),
//               bloodType: 'Not available',
//               emergencyContact: 'Not available',
//               emergencyPhone: 'Not available',
//               medicalHistory: 'Not available',
//               allergies: 'Not available',
//               currentMedications: 'Not available',
//               lastVisit: patientLink.linkedDate,
//               assignedDoctorId: userId.hashCode.abs(),
//               createdAt: patientLink.createdAt,
//               updatedAt: patientLink.updatedAt,
//             );
//             realPatients.add(patient);
//           }
//         } catch (e) {
// ...existing code...
//           // Fallback patient data when Firebase access is denied
//           final patient = Patient(
//             id: patientLink.patientId.hashCode.abs(),
//             name: 'Patient ${patientLink.patientId.substring(0, 8)}',
//             email: 'Permission restricted',
//             phone: 'Contact via app',
//             dateOfBirth: DateTime.now().subtract(const Duration(days: 25 * 365)),
//             bloodType: 'Not available',
//             emergencyContact: 'Not available',
//             emergencyPhone: 'Not available',
//             medicalHistory: 'Not available',
//             allergies: 'Not available',
//             currentMedications: 'Not available',
//             lastVisit: patientLink.linkedDate,
//             assignedDoctorId: userId.hashCode.abs(),
//             createdAt: patientLink.createdAt,
//             updatedAt: patientLink.updatedAt,
//           );
//           realPatients.add(patient);
//         }
//       }

//       setState(() {
//         _patients = realPatients;
//         _isLoading = false;
//       });
//     } catch (e) {
// ...existing code...
//       setState(() {
//         _patients = []; // Show empty list on error
//         _isLoading = false;
//       });
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading patients: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }



//   void _onItemTapped(int index) {
//     if (index == _currentIndex) return;
//     DoctorNavigationHandler.navigateToScreen(context, index);
//   }

//   List<Patient> get _filteredPatients {
//     if (_searchQuery.isEmpty) return _patients;
//     return _patients.where((patient) {
//       return patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//              patient.email.toLowerCase().contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE3F2FD), // Light blue background
//       appBar: AppBar(
//         title: const Text(
//           'My Patients',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF1976D2), // Blue theme
//         elevation: 0,
//         automaticallyImplyLeading: false, // Remove back arrow
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: () {
//               _showAddPatientDialog();
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             padding: const EdgeInsets.all(16),
//             color: Colors.white,
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search patients...',
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)), // Blue theme
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ),
          
//           // Patients List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _filteredPatients.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No patients found',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: _filteredPatients.length,
//                         itemBuilder: (context, index) {
//                           final patient = _filteredPatients[index];
//                           return _buildPatientCard(patient);
//                         },
//                       ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: DoctorBottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }

//   Widget _buildPatientCard(Patient patient) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: const Color(0xFF1976D2).withOpacity(0.1), // Blue theme
//                 child: Text(
//                   patient.name[0].toUpperCase(),
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1976D2), // Blue theme
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       patient.name,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF333333),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       patient.email,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       patient.phone,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 onSelected: (value) {
//                   switch (value) {
//                     case 'view':
//                       _viewPatientDetails(patient);
//                       break;
//                     case 'chat':
//                       _openChatWithPatient(patient);
//                       break;
//                     case 'edit':
//                       _editPatient(patient);
//                       break;
//                     case 'delete':
//                       _deletePatient(patient);
//                       break;
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'view',
//                     child: Row(
//                       children: [
//                         Icon(Icons.visibility, color: Color(0xFF1976D2)), // Blue theme
//                         SizedBox(width: 8),
//                         Text('View Details'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'chat',
//                     child: Row(
//                       children: [
//                         Icon(Icons.chat, color: Color(0xFF4CAF50)),
//                         SizedBox(width: 8),
//                         Text('Chat'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(Icons.edit, color: Color(0xFF2196F3)),
//                         SizedBox(width: 8),
//                         Text('Edit'),
//                       ],
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete, color: Colors.red),
//                         SizedBox(width: 8),
//                         Text('Delete'),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               _buildInfoChip('Blood Type', patient.bloodType, const Color(0xFF1976D2)), // Blue theme
//               const SizedBox(width: 8),
//               _buildInfoChip('Age', _calculateAge(patient.dateOfBirth).toString(), const Color(0xFF1E88E5)), // Lighter blue
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(Icons.calendar_today, color: Color(0xFF1976D2), size: 16),
//               const SizedBox(width: 4),
//               Text(
//                 'Last Visit: ${patient.lastVisit.day}/${patient.lastVisit.month}/${patient.lastVisit.year}',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF1976D2),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           if (patient.allergies.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.warning, color: Colors.orange, size: 16),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(
//                     'Allergies: ${patient.allergies}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.orange,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           const SizedBox(height: 12),
//           // Action buttons
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () => _viewPatientDetails(patient),
//                   icon: const Icon(Icons.visibility, size: 16),
//                   label: const Text('View'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFF1976D2),
//                     side: const BorderSide(color: Color(0xFF1976D2)),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _openChatWithPatient(patient),
//                   icon: const Icon(Icons.chat, size: 16),
//                   label: const Text('Chat'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4CAF50),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           // Care Management buttons - Row 1
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () => _assignMealPlan(patient),
//                   icon: const Icon(Icons.restaurant, size: 16),
//                   label: const Text('Meal'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFF4CAF50),
//                     side: const BorderSide(color: Color(0xFF4CAF50)),
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () => _assignExercise(patient),
//                   icon: const Icon(Icons.fitness_center, size: 16),
//                   label: const Text('Exercise'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFF2196F3),
//                     side: const BorderSide(color: Color(0xFF2196F3)),
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           // Care Management buttons - Row 2
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () => _viewSymptoms(patient),
//                   icon: const Icon(Icons.healing, size: 16),
//                   label: const Text('Symptoms'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFFFF9800),
//                     side: const BorderSide(color: Color(0xFFFF9800)),
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () => _callEmergencyContact(patient),
//                   icon: const Icon(Icons.phone, size: 16),
//                   label: const Text('Emergency'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFFE91E63),
//                     side: const BorderSide(color: Color(0xFFE91E63)),
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//         ],
//       ),
//     );
//   }

//   Widget _buildInfoChip(String label, String value, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         '$label: $value',
//         style: TextStyle(
//           fontSize: 12,
//           color: color,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   int _calculateAge(DateTime dateOfBirth) {
//     final now = DateTime.now();
//     int age = now.year - dateOfBirth.year;
//     if (now.month < dateOfBirth.month || 
//         (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
//       age--;
//     }
//     return age;
//   }

//   void _showAddPatientDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add New Patient'),
//         content: const Text('This feature will be implemented in the next phase.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _viewPatientDetails(Patient patient) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.8,
//           padding: const EdgeInsets.all(0),
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF1976D2),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       child: Text(
//                         patient.name[0].toUpperCase(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             patient.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'Patient ID: ${patient.id}',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Personal Information
//                       _buildSectionTitle('Personal Information'),
//                       _buildDetailCard([
//                         _buildDetailRow('Email', patient.email),
//                         _buildDetailRow('Phone', patient.phone),
//                         _buildDetailRow('Age', '${_calculateAge(patient.dateOfBirth)} years'),
//                         _buildDetailRow('Date of Birth', '${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}'),
//                         _buildDetailRow('Blood Type', patient.bloodType),
//                       ]),
                      
//                       const SizedBox(height: 16),
                      
//                       // Emergency Contact
//                       _buildSectionTitle('Emergency Contact'),
//                       _buildDetailCard([
//                         _buildDetailRow('Contact Name', patient.emergencyContact),
//                         _buildDetailRow('Contact Phone', patient.emergencyPhone),
//                       ]),
                      
//                       const SizedBox(height: 16),
                      
//                       // Medical Information
//                       _buildSectionTitle('Medical Information'),
//                       _buildDetailCard([
//                         _buildDetailRow('Medical History', patient.medicalHistory.isNotEmpty ? patient.medicalHistory : 'None'),
//                         _buildDetailRow('Allergies', patient.allergies.isNotEmpty ? patient.allergies : 'None'),
//                         _buildDetailRow('Current Medications', patient.currentMedications.isNotEmpty ? patient.currentMedications : 'None'),
//                         _buildDetailRow('Last Visit', '${patient.lastVisit.day}/${patient.lastVisit.month}/${patient.lastVisit.year}'),
//                       ]),
                      
//                       const SizedBox(height: 16),
                      
//                       // Current Care Plan (Demo Data)
//                       _buildSectionTitle('Current Care Plan'),
//                       _buildDetailCard([
//                         _buildDetailRow('Meal Plan', 'Balanced Nutrition'),
//                         _buildDetailRow('Exercise Plan', 'Light Walking, Prenatal Yoga, Breathing Exercises'),
//                         _buildDetailRow('Next Appointment', '${DateTime.now().add(const Duration(days: 7)).day}/${DateTime.now().add(const Duration(days: 7)).month}/${DateTime.now().add(const Duration(days: 7)).year}'),
//                       ]),
                      
//                       const SizedBox(height: 16),
                      
//                       // Recent Vitals (Demo Data)
//                       _buildSectionTitle('Recent Vitals'),
//                       _buildDetailCard([
//                         _buildDetailRow('Blood Pressure', '120/80 mmHg'),
//                         _buildDetailRow('Weight', '65 kg'),
//                         _buildDetailRow('Heart Rate', '72 bpm'),
//                         _buildDetailRow('Temperature', '36.5°C'),
//                       ]),
                      
//                       const SizedBox(height: 20),
                      
//                       // Action Buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _assignMealPlan(patient);
//                               },
//                               icon: const Icon(Icons.restaurant, size: 16),
//                               label: const Text('Meal Plan'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF4CAF50),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _assignExercise(patient);
//                               },
//                               icon: const Icon(Icons.fitness_center, size: 16),
//                               label: const Text('Exercise'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF2196F3),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _setUrgentAlert(patient);
//                               },
//                               icon: const Icon(Icons.warning, size: 16),
//                               label: const Text('Alert'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFFF9800),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF666666),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Color(0xFF333333),
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF1976D2),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailCard(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       ),
//     );
//   }

//   void _editPatient(Patient patient) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Edit patient feature will be implemented in the next phase'),
//         backgroundColor: Colors.orange,
//       ),
//     );
//   }

//   void _deletePatient(Patient patient) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Patient'),
//         content: Text('Are you sure you want to delete ${patient.name}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // Demo-only: remove from local list
//               setState(() {
//                 _patients.removeWhere((p) => p.id == patient.id);
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Patient deleted (demo)'),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _assignMealPlan(Patient patient) {
//     showDialog(
//       context: context,
//       builder: (context) => _MealPlanDialog(patient: patient),
//     );
//   }

//   void _assignExercise(Patient patient) {
//     showDialog(
//       context: context,
//       builder: (context) => _ExerciseDialog(patient: patient),
//     );
//   }

//   void _setUrgentAlert(Patient patient) {
//     showDialog(
//       context: context,
//       builder: (context) => _UrgentAlertDialog(patient: patient),
//     );
//   }

//   void _openChatWithPatient(Patient patient) {
//     showDialog(
//       context: context,
//       builder: (context) => _ChatDialog(patient: patient),
//     );
//   }



//   void _viewSymptoms(Patient patient) {
//     // Show patient symptoms in a dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('${patient.name} - Symptoms'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Medical History:', style: TextStyle(fontWeight: FontWeight.bold)),
//               Text(patient.medicalHistory.isNotEmpty ? patient.medicalHistory : 'No medical history recorded'),
//               SizedBox(height: 8),
//               Text('Allergies:', style: TextStyle(fontWeight: FontWeight.bold)),
//               Text(patient.allergies.isNotEmpty ? patient.allergies : 'No allergies recorded'),
//               SizedBox(height: 8),
//               Text('Current Medications:', style: TextStyle(fontWeight: FontWeight.bold)),
//               Text(patient.currentMedications.isNotEmpty ? patient.currentMedications : 'No medications recorded'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _callEmergencyContact(Patient patient) async {
//     // Show emergency contact info and provide call option
//     if (patient.emergencyPhone.isNotEmpty) {
//       final Uri phoneUri = Uri(scheme: 'tel', path: patient.emergencyPhone);
      
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.emergency, color: Colors.red),
//               SizedBox(width: 8),
//               Text('Emergency Contact'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Patient: ${patient.name}', style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text('Emergency Contact: ${patient.emergencyContact.isNotEmpty ? patient.emergencyContact : 'Not provided'}'),
//               SizedBox(height: 4),
//               Text('Phone: ${patient.emergencyPhone}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 try {
//                   if (await canLaunchUrl(phoneUri)) {
//                     await launchUrl(phoneUri);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Could not make phone call')),
//                     );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Error: $e')),
//                   );
//                 }
//               },
//               icon: Icon(Icons.phone),
//               label: Text('Call'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             ),
//           ],
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No emergency contact available for ${patient.name}')),
//       );
//     }
//   }
// }

// class _ChatDialog extends StatefulWidget {
//   final Patient patient;

//   const _ChatDialog({required this.patient});

//   @override
//   State<_ChatDialog> createState() => _ChatDialogState();
// }

// class _ChatDialogState extends State<_ChatDialog> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
  
//   List<Map<String, dynamic>> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     // Load demo messages
//     _messages = [
//       {
//         'text': 'Hello Doctor, I wanted to ask about my upcoming appointment.',
//         'isDoctor': false,
//         'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
//       },
//       {
//         'text': 'Hi ${widget.patient.name}! I\'m here to help. What would you like to know?',
//         'isDoctor': true,
//         'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
//       },
//       {
//         'text': 'Should I continue taking my current medications?',
//         'isDoctor': false,
//         'timestamp': DateTime.now().subtract(const Duration(minutes: 20)),
//       },
//       {
//         'text': 'Yes, please continue with your current medications. We\'ll review them during your next visit.',
//         'isDoctor': true,
//         'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
//       },
//     ];
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     setState(() {
//       _messages.add({
//         'text': _messageController.text.trim(),
//         'isDoctor': true,
//         'timestamp': DateTime.now(),
//       });
//     });

//     _messageController.clear();
    
//     // Auto scroll to bottom
//     Future.delayed(const Duration(milliseconds: 100), () {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         height: MediaQuery.of(context).size.height * 0.7,
//         padding: const EdgeInsets.all(0),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 color: Color(0xFF1976D2),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 20,
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     child: Text(
//                       widget.patient.name[0].toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.patient.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Online',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Messages
//             Expanded(
//               child: Container(
//                 color: const Color(0xFFF5F5F5),
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(8),
//                   itemCount: _messages.length,
//                   itemBuilder: (context, index) {
//                     final message = _messages[index];
//                     return _buildMessage(message);
//                   },
//                 ),
//               ),
//             ),
            
//             // Input
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   top: BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: 'Type your message...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: const BorderSide(color: Color(0xFF1976D2)),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                       ),
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF1976D2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       onPressed: _sendMessage,
//                       icon: const Icon(Icons.send, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessage(Map<String, dynamic> message) {
//     final isDoctor = message['isDoctor'] as bool;
//     final text = message['text'] as String;
//     final timestamp = message['timestamp'] as DateTime;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: isDoctor ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isDoctor) ...[
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
//               child: Text(
//                 widget.patient.name[0].toUpperCase(),
//                 style: const TextStyle(
//                   color: Color(0xFF1976D2),
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.6,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: isDoctor ? const Color(0xFF1976D2) : Colors.white,
//                 borderRadius: BorderRadius.circular(18),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 3,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     text,
//                     style: TextStyle(
//                       color: isDoctor ? Colors.white : Colors.black87,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
//                     style: TextStyle(
//                       color: isDoctor ? Colors.white.withOpacity(0.7) : Colors.grey,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isDoctor) ...[
//             const SizedBox(width: 8),
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
//               child: const Icon(
//                 Icons.medical_services,
//                 color: Color(0xFF1976D2),
//                 size: 16,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// // Meal Plan Dialog
// class _MealPlanDialog extends StatefulWidget {
//   final Patient patient;

//   const _MealPlanDialog({required this.patient});

//   @override
//   State<_MealPlanDialog> createState() => _MealPlanDialogState();
// }

// class _MealPlanDialogState extends State<_MealPlanDialog> {
//   String selectedMealPlan = 'Balanced Nutrition';
//   List<String> mealPlanOptions = [
//     'Balanced Nutrition',
//     'High Protein',
//     'Low Sodium',
//     'Diabetic Friendly',
//     'High Fiber',
//     'Iron Rich',
//     'Calcium Rich',
//     'Custom Plan'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.restaurant, color: Color(0xFF4CAF50), size: 24),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Assign Meal Plan',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Patient: ${widget.patient.name}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF666666),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Select Meal Plan:',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 itemCount: mealPlanOptions.length,
//                 itemBuilder: (context, index) {
//                   final option = mealPlanOptions[index];
//                   return RadioListTile<String>(
//                     title: Text(option),
//                     value: option,
//                     groupValue: selectedMealPlan,
//                     onChanged: (value) {
//                       setState(() {
//                         selectedMealPlan = value!;
//                       });
//                     },
//                     activeColor: const Color(0xFF4CAF50),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.grey,
//                       side: const BorderSide(color: Colors.grey),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text('Cancel'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('$selectedMealPlan assigned to ${widget.patient.name}'),
//                           backgroundColor: const Color(0xFF4CAF50),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4CAF50),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text('Assign'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Exercise Dialog
// class _ExerciseDialog extends StatefulWidget {
//   final Patient patient;

//   const _ExerciseDialog({required this.patient});

//   @override
//   State<_ExerciseDialog> createState() => _ExerciseDialogState();
// }

// class _ExerciseDialogState extends State<_ExerciseDialog> {
//   List<String> selectedExercises = ['Light Walking'];
//   List<String> exerciseOptions = [
//     'Light Walking',
//     'Prenatal Yoga',
//     'Swimming',
//     'Stationary Cycling',
//     'Stretching Exercises',
//     'Breathing Exercises',
//     'Pelvic Floor Exercises',
//     'Custom Routine'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.fitness_center, color: Color(0xFF2196F3), size: 24),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Recommend Exercise',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Patient: ${widget.patient.name}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF666666),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Select Exercise Types (Multiple Selection):',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Selected: ${selectedExercises.length} exercise${selectedExercises.length == 1 ? '' : 's'}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: const Color(0xFF2196F3),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           selectedExercises = List.from(exerciseOptions);
//                         });
//                       },
//                       style: TextButton.styleFrom(
//                         foregroundColor: const Color(0xFF2196F3),
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         minimumSize: Size.zero,
//                       ),
//                       child: const Text(
//                         'Select All',
//                         style: TextStyle(fontSize: 12),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           selectedExercises.clear();
//                         });
//                       },
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.grey[600],
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         minimumSize: Size.zero,
//                       ),
//                       child: const Text(
//                         'Clear All',
//                         style: TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 itemCount: exerciseOptions.length,
//                 itemBuilder: (context, index) {
//                   final option = exerciseOptions[index];
//                   final isSelected = selectedExercises.contains(option);
//                   return CheckboxListTile(
//                     title: Text(
//                       option,
//                       style: TextStyle(
//                         color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
//                         fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                       ),
//                     ),
//                     value: isSelected,
//                     onChanged: (bool? value) {
//                       setState(() {
//                         if (value == true) {
//                           selectedExercises.add(option);
//                         } else {
//                           selectedExercises.remove(option);
//                         }
//                       });
//                     },
//                     activeColor: const Color(0xFF2196F3),
//                     checkColor: Colors.white,
//                     controlAffinity: ListTileControlAffinity.leading,
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.grey,
//                       side: const BorderSide(color: Colors.grey),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text('Cancel'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (selectedExercises.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please select at least one exercise'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Exercise plan assigned to ${widget.patient.name}',
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               if (selectedExercises.length > 1) ...[
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Selected: ${selectedExercises.join(', ')}',
//                                   style: const TextStyle(fontSize: 12),
//                                 ),
//                               ] else
//                                 Text(selectedExercises.first),
//                             ],
//                           ),
//                           backgroundColor: const Color(0xFF2196F3),
//                           duration: const Duration(seconds: 4),
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2196F3),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: Text('Recommend (${selectedExercises.length})'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Urgent Alert Dialog
// class _UrgentAlertDialog extends StatefulWidget {
//   final Patient patient;

//   const _UrgentAlertDialog({required this.patient});

//   @override
//   State<_UrgentAlertDialog> createState() => _UrgentAlertDialogState();
// }

// class _UrgentAlertDialogState extends State<_UrgentAlertDialog> {
//   String selectedAlertType = 'Medication Reminder';
//   final TextEditingController _messageController = TextEditingController();
  
//   List<String> alertTypes = [
//     'Medication Reminder',
//     'Appointment Follow-up',
//     'Lab Test Required',
//     'Blood Pressure Check',
//     'Weight Monitoring',
//     'Emergency Contact',
//     'Diet Compliance',
//     'Custom Alert'
//   ];

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.9,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.warning, color: Color(0xFFFF9800), size: 24),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Set Urgent Alert',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF333333),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Patient: ${widget.patient.name}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF666666),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Alert Type:',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333),
//               ),
//             ),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               initialValue: selectedAlertType,
//               onChanged: (value) {
//                 setState(() {
//                   selectedAlertType = value!;
//                 });
//               },
//               items: alertTypes.map((type) {
//                 return DropdownMenuItem(
//                   value: type,
//                   child: Text(type),
//                 );
//               }).toList(),
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Alert Message:',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _messageController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: 'Enter detailed alert message...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.all(12),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.grey,
//                       side: const BorderSide(color: Colors.grey),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text('Cancel'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_messageController.text.trim().isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please enter an alert message'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('$selectedAlertType alert set for ${widget.patient.name}'),
//                           backgroundColor: const Color(0xFFFF9800),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFFF9800),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                     child: const Text('Set Alert'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



