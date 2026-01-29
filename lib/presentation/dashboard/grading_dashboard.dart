// File: grading_dashboard.dart
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'More features coming soon...',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
