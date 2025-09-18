import 'package:flutter/material.dart';

class DoctorBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DoctorBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _buildNavItem(Icons.people_outline, 'Patients', 1),
          _buildNavItem(Icons.calendar_today_outlined, 'Appointments', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
          _buildNavItem(Icons.settings_outlined, 'Settings', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
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
}

