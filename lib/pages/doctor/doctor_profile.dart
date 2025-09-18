import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';
import '../../models/doctor.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  int _currentIndex = 3;
  late Doctor _doctor; // Demo doctor

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _doctor = Doctor(
      id: 1,
      name: 'Dr. Sarah Johnson',
      email: 'sarah.johnson@hospital.com',
      phone: '+1-555-0101',
      specialization: 'Obstetrics & Gynecology',
      licenseNumber: 'MD123456',
      hospital: 'City General Hospital',
      experience: '10 years',
      bio: 'Specialized in high-risk pregnancies and maternal-fetal medicine.',
      rating: 4.8,
      totalPatients: 150,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      _doctor.name[0],
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _doctor.name,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _doctor.specialization,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 18),
                      const SizedBox(width: 4),
                      Text('${_doctor.rating}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text('${_doctor.totalPatients} patients', style: const TextStyle(color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            _infoTile(Icons.badge, 'License Number', _doctor.licenseNumber),
            _infoTile(Icons.local_hospital, 'Hospital', _doctor.hospital),
            _infoTile(Icons.work, 'Experience', _doctor.experience),
            _infoTile(Icons.email, 'Email', _doctor.email),
            _infoTile(Icons.phone, 'Phone', _doctor.phone),
            _infoTile(Icons.info, 'Bio', _doctor.bio),
            _infoTile(Icons.verified, 'Available', _doctor.isAvailable ? 'Yes' : 'No'),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE91E63)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


