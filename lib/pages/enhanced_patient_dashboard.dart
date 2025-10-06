import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../services/appointment_service.dart';
import '../services/session_manager.dart';
import '../widgets/pregnancy_progress_widget.dart';
import '../models/appointment.dart';
import '../models/reminder.dart';
import '../models/medical_record.dart';
import '../utils/demo_data_initializer.dart';

class EnhancedPatientDashboard extends StatefulWidget {
  const EnhancedPatientDashboard({Key? key}) : super(key: key);

  @override
  State<EnhancedPatientDashboard> createState() => _EnhancedPatientDashboardState();
}

class _EnhancedPatientDashboardState extends State<EnhancedPatientDashboard> {
  final BackendService _backendService = BackendService();
  final AppointmentService _appointmentService = AppointmentService();
  
  List<Appointment> upcomingAppointments = [];
  List<Reminder> todayReminders = [];
  List<MedicalRecord> recentRecords = [];
  Map<String, dynamic> dashboardSummary = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);
    
    try {
      // Initialize all demo data
      await DemoDataInitializer.initializeAllDemoData();
      
      // Get user ID from session manager
      final userId = await SessionManager.getUserId() ?? '1';
      
      // Load all dashboard data
      final summary = await _backendService.getDashboardSummary(userId);
      final appointments = await _appointmentService.getUpcomingAppointments(userId);
      final allReminders = await _backendService.getReminders(userId);
      final allRecords = await _backendService.getMedicalRecords(userId);
      
      // Filter today's reminders and recent records
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final reminders = allReminders.where((r) => 
        r.reminderDate.year == today.year && 
        r.reminderDate.month == today.month && 
        r.reminderDate.day == today.day &&
        r.isActive && !r.isCompleted
      ).toList();
      final records = allRecords.take(3).toList();
      
      setState(() {
        dashboardSummary = summary;
        upcomingAppointments = appointments;
        todayReminders = reminders;
        recentRecords = records;
        isLoading = false;
      });
    } catch (e) {

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              
              // Pregnancy Progress Widget
              PregnancyProgressWidget(
                showRefreshButton: true,
                onTap: () {
                  // Optional: Navigate to detailed pregnancy tracking page

                },
              ),
              const SizedBox(height: 24),
              
              // Quick Stats Cards
              _buildQuickStatsCards(),
              const SizedBox(height: 24),
              
              // Today's Reminders
              _buildTodayReminders(),
              const SizedBox(height: 24),
              
              // Upcoming Appointments
              _buildUpcomingAppointments(),
              const SizedBox(height: 24),
              
              // Recent Medical Records
              _buildRecentMedicalRecords(),
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade100, Colors.purple.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hope you\'re feeling well today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.pink.shade400,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Appointments',
            upcomingAppointments.length.toString(),
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Reminders',
            todayReminders.length.toString(),
            Icons.notifications,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Records',
            recentRecords.length.toString(),
            Icons.folder,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReminders() {
    return _buildSectionCard(
      title: 'Today\'s Reminders',
      icon: Icons.notifications_active,
      iconColor: Colors.orange,
      child: todayReminders.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No reminders for today'),
              ),
            )
          : Column(
              children: todayReminders.map((reminder) => _buildReminderItem(reminder)).toList(),
            ),
    );
  }

  Widget _buildReminderItem(Reminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: Colors.orange,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getReminderIcon(reminder.type),
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (reminder.description.isNotEmpty)
                  Text(
                    reminder.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatTime(reminder.reminderDate),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return _buildSectionCard(
      title: 'Upcoming Appointments',
      icon: Icons.calendar_today,
      iconColor: Colors.blue,
      child: upcomingAppointments.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No upcoming appointments'),
              ),
            )
          : Column(
              children: upcomingAppointments.map((appointment) => _buildAppointmentItem(appointment)).toList(),
            ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.reason,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                _formatAppointmentDate(appointment.appointmentDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                appointment.timeSlot,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (appointment.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appointment.notes,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentMedicalRecords() {
    return _buildSectionCard(
      title: 'Recent Medical Records',
      icon: Icons.folder_outlined,
      iconColor: Colors.green,
      child: recentRecords.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No recent medical records'),
              ),
            )
          : Column(
              children: recentRecords.map((record) => _buildMedicalRecordItem(record)).toList(),
            ),
    );
  }

  Widget _buildMedicalRecordItem(MedicalRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            _getRecordIcon(record.recordType),
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  record.recordType.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRecordDate(record.recordDate),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _buildSectionCard(
      title: 'Quick Actions',
      icon: Icons.flash_on,
      iconColor: Colors.purple,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Book Appointment',
                    Icons.add_circle,
                    Colors.blue,
                    () => _showBookAppointmentDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Add Reminder',
                    Icons.notification_add,
                    Colors.orange,
                    () => _showAddReminderDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Emergency Contact',
                    Icons.emergency,
                    Colors.red,
                    () => _showEmergencyContacts(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Health Tips',
                    Icons.lightbulb,
                    Colors.green,
                    () => _showHealthTips(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  // Helper methods
  IconData _getReminderIcon(String type) {
    switch (type) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.calendar_today;
      case 'exercise':
        return Icons.fitness_center;
      case 'checkup':
        return Icons.health_and_safety;
      default:
        return Icons.notification_important;
    }
  }

  IconData _getRecordIcon(String type) {
    switch (type) {
      case 'checkup':
        return Icons.health_and_safety;
      case 'lab_result':
        return Icons.science;
      case 'ultrasound':
        return Icons.monitor_heart;
      case 'prescription':
        return Icons.medication;
      default:
        return Icons.description;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatAppointmentDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRecordDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  // Dialog methods (placeholder implementations)
  void _showBookAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Appointment'),
        content: const Text('Appointment booking feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder'),
        content: const Text('Add reminder feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContacts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contacts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚨 Emergency: 911'),
            SizedBox(height: 8),
            Text('🏥 Hospital: +1-555-0199'),
            SizedBox(height: 8),
            Text('👩‍⚕️ Doctor: +1-555-0101'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHealthTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💧 Stay hydrated - drink plenty of water'),
            SizedBox(height: 8),
            Text('🥗 Eat nutritious meals regularly'),
            SizedBox(height: 8),
            Text('😴 Get adequate rest (7-9 hours)'),
            SizedBox(height: 8),
            Text('🚶‍♀️ Light exercise as approved by doctor'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
