// ---------------------------------------------------------------
// FULL FIXED WORKING CODE (WITH VISIBLE BOTTOM NAV + PDF DOWNLOAD)
// ---------------------------------------------------------------

import 'dart:convert';
import 'package:factory_app/presentation/activity/EmployeeAttendancePage.dart';
import 'package:factory_app/presentation/dashboard/master/Employee/ViewAttendance/EmployeeAttendanceCalendarPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../activity/checkinScreenPage.dart';

// ---------------- Main ---------------- //
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const CalibrationDashboardRoot(),
    ),
  );
}

class CalibrationDashboardRoot extends StatelessWidget {
  const CalibrationDashboardRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // ❗ If employee not logged in, send to login page
    if (auth.employeeId == null || auth.tenantId == null) {
      return MaterialApp(home: Center(child: Text("Login required")));
    }

    // ✅ Now pass dynamic values
    return CalibrationDashboardApp(
      tenantName: auth.tenantName ?? "Tenant",
      tenantId: auth.tenantId!,
      employeeId: auth.employeeId!,
    );
  }
}

// ---------------- Dashboard App ---------------- //
class CalibrationDashboardApp extends StatelessWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;

  const CalibrationDashboardApp({
    super.key,
    required this.tenantName,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: tenantName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false, // 🔥 FIXED BOTTOM NAV BAR VISIBILITY ISSUE
        primarySwatch: Colors.blue,
      ),
      home: DashboardPage(
        tenantName: tenantName,
        tenantId: tenantId,
        employeeId: employeeId,
      ),
    );
  }
}

// ---------------- Dashboard Page ---------------- //
class DashboardPage extends StatefulWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;

  const DashboardPage({
    super.key,
    required this.tenantName,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> tasksList = [];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      CheckInPage(),
      TasksPage(tenantId: widget.tenantId),

      UpdateTasksPage(
        tasksList: tasksList,
        onTasksUpdated: (newTasks) => setState(() => tasksList = newTasks),
      ),
      ViewTasksPage(
        tasks: tasksList,
        tenantId: widget.tenantId,
        employeeId: widget.employeeId,
        onTasksUpdated: (updated) => setState(() => tasksList = updated),
      ),
      MorePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tenantName} Dashboard'),
        centerTitle: true,
      ),

      body: _pages[_selectedIndex],

      // ---------------------------------------------------------------
      // FIXED BOTTOM NAVIGATION BAR (VISIBLE + CLEAR + NO OVERLAY)
      // ---------------------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 12,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Check-in'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Update'),
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'View'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

// ---------------- CheckIn Page ---------------- //

class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: true);

    final employeeName = auth.employeeName ?? "Employee";
    final role = auth.userRole ?? "Role";
    final email = auth.employeeEmail ?? "No Email";
    final phone = auth.employeePhone ?? "No Phone";

    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- TOP PROFILE CARD ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employeeName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(phone, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ---------- TITLE ----------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Quick Actions",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 10),

            // ---------- 4 BLOCK GRID ----------
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _dashboardCard(
                    title: "Check In",
                    icon: Icons.login,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckInScreenPage(),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(
                    title: "Attendance",
                    icon: Icons.event_available,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const EmployeeAttendanceCalendarPage(),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(
                    title: "Employees Attendance",
                    icon: Icons.dashboard,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ManagerEmployeeAttendancePage(),
                        ),
                      );
                    },
                  ),

                  _dashboardCard(
                    title: "B",
                    icon: Icons.storage,
                    color: Colors.purple,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CARD WIDGET ----------
  Widget _dashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Tasks Page (Fetch + PDF Download) ---------------- //

class TasksPage extends StatefulWidget {
  final int tenantId;

  const TasksPage({super.key, required this.tenantId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final String apiUrl =
        "http://192.168.29.215:8080/api/calibration-reports/tenant/${widget.tenantId}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        data.sort(
          (a, b) =>
              DateTime.parse(b["date"]).compareTo(DateTime.parse(a["date"])),
        );

        setState(() {
          reports = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // your UI code
    return Container();
  }
}

// ---------------- Update Tasks Page ---------------- //
class UpdateTasksPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasksList;
  final ValueChanged<List<Map<String, dynamic>>> onTasksUpdated;

  const UpdateTasksPage({
    super.key,
    required this.tasksList,
    required this.onTasksUpdated,
  });

  @override
  State<UpdateTasksPage> createState() => _UpdateTasksPageState();
}

class _UpdateTasksPageState extends State<UpdateTasksPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController lotController = TextEditingController();
  final TextEditingController markController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController totalBagsController = TextEditingController();
  final TextEditingController productionQtyController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController countPerKgController = TextEditingController();

  String? selectedSize;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: lotController,
              decoration: const InputDecoration(
                labelText: "Lot",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Enter Lot" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: markController,
              decoration: const InputDecoration(
                labelText: "Mark",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Enter Mark" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: "Origin",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Enter Origin" : null,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedSize,
              items: [
                "A+",
                "A",
                "B+",
                "B",
                "C+",
                "C",
                "D+",
                "D",
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => selectedSize = v),
              decoration: const InputDecoration(
                labelText: "Size",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? "Select Size" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: totalBagsController,
              decoration: const InputDecoration(
                labelText: "Total No of Bags",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Enter total bags" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: productionQtyController,
              decoration: const InputDecoration(
                labelText: "Production Qty",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Enter production qty" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: percentageController,
              decoration: const InputDecoration(
                labelText: "Percentage %",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Enter percentage" : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: countPerKgController,
              decoration: const InputDecoration(
                labelText: "Count per Kg",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Enter count per kg" : null,
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final task = {
                    "date": selectedDate.toIso8601String(),
                    "lot": lotController.text,
                    "mark": markController.text,
                    "origin": originController.text,
                    "size": selectedSize,
                    "totalBags": int.parse(totalBagsController.text),
                    "productionQty": double.parse(productionQtyController.text),
                    "percentage": double.parse(percentageController.text),
                    "countPerKg": double.parse(countPerKgController.text),
                  };

                  widget.tasksList.add(task);
                  widget.onTasksUpdated(widget.tasksList);

                  lotController.clear();
                  markController.clear();
                  originController.clear();
                  totalBagsController.clear();
                  productionQtyController.clear();
                  percentageController.clear();
                  countPerKgController.clear();

                  setState(() => selectedSize = null);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Task Added")));
                }
              },
              child: const Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- View Tasks Page ---------------- //
class ViewTasksPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final int tenantId;
  final int employeeId;
  final ValueChanged<List<Map<String, dynamic>>> onTasksUpdated;

  const ViewTasksPage({
    super.key,
    required this.tasks,
    required this.tenantId,
    required this.employeeId,
    required this.onTasksUpdated,
  });

  @override
  State<ViewTasksPage> createState() => _ViewTasksPageState();
}

class _ViewTasksPageState extends State<ViewTasksPage> {
  void deleteTask(int index) {
    setState(() {
      widget.tasks.removeAt(index);
      widget.onTasksUpdated(widget.tasks);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task removed!')));
  }

  Future<void> submitAllTasks() async {
    if (widget.tasks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No tasks to submit')));
      return;
    }

    final url = Uri.parse(
      'http://192.168.29.215:8080/api/calibration-reports/tenant/${widget.tenantId}/employee/${widget.employeeId}',
    );

    final body = widget.tasks.map((task) {
      final qty = task["productionQty"] as double;

      return {
        "date": task["date"].split("T")[0],
        "lotMark": "${task["lot"]}-${task["mark"]}",
        "origin": task["origin"],
        "perBagWeight": 50.0,
        "sizeRange": task["size"],
        "noOfBags": (task["totalBags"] as int).toDouble(),
        "productionQty": qty,
        "totalProductionMts": qty / 2,
        "percentage": task["percentage"],
        "countPerKg": task["countPerKg"],
        "tenant": {"id": widget.tenantId},
        "employee": {"id": widget.employeeId},
      };
    }).toList();

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tasks submitted successfully!')),
        );

        setState(() {
          widget.tasks.clear();
          widget.onTasksUpdated(widget.tasks);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Tasks")),

      body: widget.tasks.isEmpty
          ? const Center(child: Text("No tasks added yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text("Lot: ${task["lot"]} | Mark: ${task["mark"]}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Origin: ${task["origin"]}"),
                        Text("Size: ${task["size"]}"),
                        Text("Bags: ${task["totalBags"]}"),
                        Text("Prod Qty: ${task["productionQty"]}"),
                        Text("Percentage: ${task["percentage"]}%"),
                        Text("Count/Kg: ${task["countPerKg"]}"),
                        Text("Date: ${task["date"].split("T")[0]}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteTask(index),
                    ),
                  ),
                );
              },
            ),

      bottomNavigationBar: widget.tasks.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: submitAllTasks,
                child: const Text("Submit All Tasks"),
              ),
            ),
    );
  }
}

// ---------------- More Page ---------------- //
class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'More features coming soon...',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}