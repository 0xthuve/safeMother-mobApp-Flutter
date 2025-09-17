import 'package:flutter/material.dart';
import 'docbottom_navigation_handler.dart';
import 'docbottom_navigation.dart'; // for DoctorBottomNavigationBar

void main() {
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Doctor Dashboard",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Times New Roman', // Set Roman font style
      ),
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}

// ----------------- Dashboard Page ----------------- //

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFCFCFC), Color(0xFF87D8E2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
             Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Stack(
    alignment: Alignment.center,
    children: [
      const Center(
        child: Text(
          "Dashboard",
          style: TextStyle(
            color: Color(0xFF037C8C),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Positioned(
        right: 0,
        child: Icon(
          Icons.notifications_none,
          color: Color.fromARGB(255, 0, 0, 0),
          size: 28,
        ),
      ),
    ],
  ),
),


              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // My Patients Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "My Patients",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF037C8C)),
                          ),
                          Text("See all",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 21, 21, 21),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: const [
                            PatientCard(
                              name: "Sophia Carter",
                              subtitle: "Due in 2 weeks",
                              imageUrl: "assets/mom.jpg",
                            ),
                            PatientCard(
                              name: "Olivia Bennett",
                              subtitle: "Due in 1 month",
                              imageUrl: "assets/pregnant.jpg",
                            ),
                            PatientCard(
                              name: "Emma Hayes",
                              subtitle: "Due in 2 months",
                              imageUrl: "assets/pregnant-mother1.jpg",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Upcoming Appointments Box
                      const Text(
                        "Upcoming Appointments",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF037C8C)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: const [
                              AppointmentItem(
                                name: "Sophia Carter",
                                time: "10:00 AM - 11:00 AM",
                                imageUrl: "assets/mom.jpg",
                              ),
                              Divider(height: 1, thickness: 0.5, color: Color.fromARGB(255, 209, 208, 208)),
                              AppointmentItem(
                                name: "Olivia Bennett",
                                time: "11:30 AM - 12:30 PM",
                                imageUrl: "assets/pregnant.jpg",
                              ),
                              Divider(height: 1, thickness: 0.5, color: Color.fromARGB(255, 209, 208, 208)),
                              AppointmentItem(
                                name: "Emma Hayes",
                                time: "1:00 PM - 2:00 PM",
                                imageUrl: "assets/pregnant-mother1.jpg",
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Alerts Box
                      const Text(
                        "Alerts",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF037C8C)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: const [
                              AlertItem(
                                name: "Sophia Carter",
                                alert: "High blood pressure detected",
                                color: Colors.red,
                                icon: Icons.error_outline,
                                time: "Now", // black color
                              ),
                              Divider(height: 1, thickness: 0.5,color: Color.fromARGB(255, 209, 208, 208)),
                              AlertItem(
                                name: "Olivia Bennett",
                                alert: "Missed appointment",
                                color: Colors.orange,
                                icon: Icons.event_busy,
                                time: "Yesterday", // ash color
                              ),
                            ],
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
      ),
      bottomNavigationBar: DoctorBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          NavigationHandler.navigateToScreen(context, index);
        },
      ),
    );
  }
}

// ----------------- Widgets ----------------- //

class PatientCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String imageUrl;

  const PatientCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imageUrl),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// Single Appointment Item
class AppointmentItem extends StatelessWidget {
  final String name;
  final String time;
  final String imageUrl;

  const AppointmentItem(
      {super.key, required this.name, required this.time, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: AssetImage(imageUrl),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(color: Colors.grey,fontSize: 12)), // ash color
      trailing: const Icon(Icons.more_vert),
    );
  }
}

class AlertItem extends StatelessWidget {
  final String name;
  final String alert;
  final Color color;
  final IconData icon;
  final String time;

  const AlertItem({
    super.key,
    required this.name,
    required this.alert,
    required this.color,
    required this.icon,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    Color timeColor = time.toLowerCase() == 'now'
        ? Colors.black
        :  Colors.grey; // Now = black, Yesterday = ash

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14),
      ),
      subtitle: Text(
        alert,
        style: TextStyle(color: color,fontSize: 12),
      ),
      trailing: Text(
        time,
        style: TextStyle(color: timeColor),
      ),
    );
  }
}
