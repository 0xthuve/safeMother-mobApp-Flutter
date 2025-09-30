import 'package:flutter/material.dart';
import '../../navigation/doctor_navigation_handler.dart';
import '../../navigation/doctor_bottom_navigation.dart';

class DoctorSettings extends StatefulWidget {
  const DoctorSettings({super.key});

  @override
  State<DoctorSettings> createState() => _DoctorSettingsState();
}

class _DoctorSettingsState extends State<DoctorSettings> {
  int _currentIndex = 4;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  String _language = 'English';
  String _theme = 'Light';

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    DoctorNavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1976D2), // Blue theme
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Notifications'),
          _card([
            _switchTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            _divider(),
            _switchTile(
              icon: Icons.email,
              title: 'Email Notifications',
              value: _emailNotifications,
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
          ]),

          const SizedBox(height: 16),

          _sectionTitle('Preferences'),
          _card([
            _navTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: _language,
              onTap: () => _pickFrom(['English', 'Spanish', 'French'], (v) => setState(() => _language = v)),
            ),
            _divider(),
            _navTile(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: _theme,
              onTap: () => _pickFrom(['Light', 'Dark', 'System'], (v) => setState(() => _theme = v)),
            ),
          ]),

          const SizedBox(height: 16),

          _sectionTitle('Account'),
          _card([
            _navTile(icon: Icons.lock, title: 'Change Password', subtitle: '********', onTap: () => _toast('Change Password tapped')),
            _divider(),
            _navTile(icon: Icons.verified_user, title: 'Verify License', subtitle: 'Pending', onTap: () => _toast('Verify License tapped')),
            _divider(),
            _navTile(icon: Icons.logout, title: 'Sign Out', subtitle: 'sarah.johnson@hospital.com', onTap: () => _toast('Signed out')), 
          ]),
        ],
      ),
      bottomNavigationBar: DoctorBottomNavigationBar(currentIndex: _currentIndex, onTap: _onItemTapped),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: children),
      );

  Widget _divider() => const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA));

  Widget _switchTile({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) => ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2)), // Blue theme
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF1976D2)), // Blue theme
      );

  Widget _navTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) => ListTile(
        leading: Icon(icon, color: const Color(0xFF1976D2)), // Blue theme
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      );

  void _pickFrom(List<String> options, ValueChanged<String> onPicked) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select'),
        children: options
            .map((e) => SimpleDialogOption(onPressed: () { Navigator.pop(context); onPicked(e); }, child: Text(e)))
            .toList(),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1976D2))); // Blue theme
  }
}


