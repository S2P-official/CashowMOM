// File: grading_dashboard.dart
import 'package:factory_app/presentation/login/login_controller.dart';
import 'package:factory_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GradingDashboardApp extends StatelessWidget {
    final String tenantName; 
    const GradingDashboardApp({super.key, required this.tenantName});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: tenantName.isNotEmpty ? tenantName : 'Employee Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Pages for Grading Dashboard
  static final List<Widget> _pages = <Widget>[
    CheckInPage(),
    TasksPage(),
    UpdateTasksPage(),
    ViewTasksPage(),
    MorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grading Employee Dashboard'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Check-in'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Update Task'),
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'View Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

// ---------------- Pages ---------------- //

class CheckInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.login),
        label: Text('Check In Now'),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Checked in successfully!')),
          );
        },
      ),
    );
  }
}

class TasksPage extends StatelessWidget {
  final List<String> tasks = [
    "Grade batches",
    "Record results",
    "Quality check grading",
    "Update grading log",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.task_alt),
            title: Text(tasks[index]),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${tasks[index]}')),
              );
            },
          ),
        );
      },
    );
  }
}

class UpdateTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update Task Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "Task Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: ["Pending", "In Progress", "Completed"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {},
                decoration: InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task updated successfully!')),
                  );
                },
                child: Text("Update Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewTasksPage extends StatelessWidget {
  final List<Map<String, String>> tasks = [
    {"name": "Grade batches", "status": "Completed"},
    {"name": "Record results", "status": "In Progress"},
    {"name": "Quality check grading", "status": "Pending"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(Icons.task),
            title: Text(tasks[index]["name"]!),
            subtitle: Text("Status: ${tasks[index]["status"]}"),
          ),
        );
      },
    );
  }
}


class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text("More"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(auth),
          const SizedBox(height: 16),

          _buildSectionTitle("Management"),
          _buildTile(
            icon: Icons.people_alt_outlined,
            title: "User Management",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.badge_outlined,
            title: "Employee Management",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.analytics_outlined,
            title: "Attendance Reports",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.task_alt_outlined,
            title: "Tasks & Reports",
            onTap: () {},
          ),

          const SizedBox(height: 24),

          _buildSectionTitle("App & Support"),
          _buildTile(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.phone_outlined,
            title: "Contact Us",
            onTap: () {},
          ),
          _buildTile(
            icon: Icons.info_outline,
            title: "About App",
            onTap: () {},
          ),

          const SizedBox(height: 32),

          _buildLogoutTile(context,auth),
        ],
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _buildProfileCard(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.employeeName ?? "User Name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.userRole ?? "Role",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.employeeEmail ?? "",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context, AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.red),
        ),
        onTap: () async {
              await auth.logout();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
        
      ),
    );
  }
}
