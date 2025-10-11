import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/backend_service.dart';
import '../services/appointment_service.dart';
import '../services/session_manager.dart';
import '../widgets/pregnancy_progress_widget.dart';
import '../models/appointment.dart';
import '../models/reminder.dart';
import '../models/medical_record.dart';


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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 20),
                
                // Pregnancy Progress Widget
                PregnancyProgressWidget(
                  showRefreshButton: true,
                  onTap: () {
                    // Optional: Navigate to detailed pregnancy tracking page
                  },
                ),
                const SizedBox(height: 20),
                
                // Quick Stats Cards
                _buildQuickStatsCards(),
                const SizedBox(height: 20),
                
                // Today's Reminders
                _buildTodayReminders(),
                const SizedBox(height: 20),
                
                // Upcoming Appointments
                _buildUpcomingAppointments(),
                const SizedBox(height: 20),
                
                // Recent Medical Records
                _buildRecentMedicalRecords(),
                const SizedBox(height: 20),
                
                // Quick Actions
                _buildQuickActions(),
                
                // Bottom padding for better scrolling
                const SizedBox(height: 20),
              ],
            ),
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.welcomeBack,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.feelingWell,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Container(
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
            AppLocalizations.of(context)!.appointments,
            upcomingAppointments.length.toString(),
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context)!.reminders,
            todayReminders.length.toString(),
            Icons.notifications,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context)!.records,
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
      padding: const EdgeInsets.all(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReminders() {
    return _buildSectionCard(
      title: AppLocalizations.of(context)!.todaysReminders,
      icon: Icons.notifications_active,
      iconColor: Colors.orange,
      child: todayReminders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.noRemindersToday),
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (reminder.description.isNotEmpty)
                  Text(
                    reminder.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: Text(
              _formatTime(reminder.reminderDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return _buildSectionCard(
      title: AppLocalizations.of(context)!.upcomingAppointments,
      icon: Icons.calendar_today,
      iconColor: Colors.blue,
      child: upcomingAppointments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.noUpcomingAppointments),
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
                flex: 3,
                child: Text(
                  appointment.reason,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentMedicalRecords() {
    return _buildSectionCard(
      title: AppLocalizations.of(context)!.recentMedicalRecords,
      icon: Icons.folder_outlined,
      iconColor: Colors.green,
      child: recentRecords.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.noRecentRecords),
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record.recordType.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: Text(
              _formatRecordDate(record.recordDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _buildSectionCard(
      title: AppLocalizations.of(context)!.quickActions,
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
                    AppLocalizations.of(context)!.bookAppointment,
                    Icons.add_circle,
                    Colors.blue,
                    () => _showBookAppointmentDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    AppLocalizations.of(context)!.addReminder,
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
                    AppLocalizations.of(context)!.emergencyContact,
                    Icons.emergency,
                    Colors.red,
                    () => _showEmergencyContacts(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    AppLocalizations.of(context)!.healthTips,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
        title: Text(AppLocalizations.of(context)!.bookAppointment),
        content: Text(AppLocalizations.of(context)!.appointmentBookingComingSoon),
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
        title: Text(AppLocalizations.of(context)!.addReminder),
        content: Text(AppLocalizations.of(context)!.addReminderComingSoon),
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
        title: Text(AppLocalizations.of(context)!.emergencyContact),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.emergency}: 911'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.hospital}: +1-555-0199'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.doctor}: +1-555-0101'),
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
        title: Text(AppLocalizations.of(context)!.healthTips),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.stayHydrated),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.eatNutritious),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.getAdequateRest),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.lightExercise),
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
