// ---------------------------------------------------------------
// FULL FIXED WORKING CODE (WITH VISIBLE BOTTOM NAV + PDF DOWNLOAD)
// ---------------------------------------------------------------

import 'dart:convert';
import 'package:factory_app/presentation/activity/EmployeeAttendancePage.dart';
import 'package:factory_app/presentation/dashboard/master/Employee/ViewAttendance/EmployeeAttendanceCalendarPage.dart';
import 'package:factory_app/presentation/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
      // 0️⃣ Check-in
      CheckInPage(),

      // 1️⃣ Update
      UpdateTasksPage(
        tasksList: tasksList,
        onTasksUpdated: (newTasks) =>
            setState(() => tasksList = newTasks),
      ),

      // 2️⃣ View
      ViewTasksPage(
        tasks: tasksList,
        tenantId: widget.tenantId,
        employeeId: widget.employeeId,
        onTasksUpdated: (updated) =>
            setState(() => tasksList = updated),
      ),

      // 3️⃣ Status
      TasksPage(tenantId: widget.tenantId, employeeId: widget.employeeId,),

      // 4️⃣ More
      MorePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tenantName} Dashboard'),
        centerTitle: true,
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 12,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Update',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
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
  final int employeeId;

  const TasksPage({
    super.key,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<dynamic> allReports = [];
  List<dynamic> filteredReports = [];
  bool isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  // --------------------------------------------------
  // FETCH REPORTS (TENANT + EMPLOYEE)
  // --------------------------------------------------
  Future<void> fetchReports() async {
    setState(() => isLoading = true);

    final url =
        "http://192.168.29.215:8080/api/calibration-reports?tenantId=${widget.tenantId}&employeeId=${widget.employeeId}";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Sort by date descending
        data.sort((a, b) => DateTime.parse(b['date'])
            .compareTo(DateTime.parse(a['date'])));

        setState(() {
          allReports = data;
          applyDateFilter();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  // --------------------------------------------------
  // DATE FILTER ONLY
  // --------------------------------------------------
  void applyDateFilter() {
    if (selectedDate == null) {
      filteredReports = allReports;
    } else {
      filteredReports = allReports.where((r) {
        final d = DateTime.parse(r['date']);
        return d.year == selectedDate!.year &&
            d.month == selectedDate!.month &&
            d.day == selectedDate!.day;
      }).toList();
    }
    setState(() {});
  }

  String formatDate(String? d) =>
      d == null ? "-" : DateFormat('dd-MM-yyyy').format(DateTime.parse(d));

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calibration Reports")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // DATE FILTER BAR
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Text(
                        "Filter by Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            selectedDate = picked;
                            applyDateFilter();
                          }
                        },
                      ),
                      if (selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            selectedDate = null;
                            applyDateFilter();
                          },
                        ),
                    ],
                  ),
                ),

                // TABLE
                Expanded(
                  child: filteredReports.isEmpty
                      ? const Center(child: Text("No reports found"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(
                                      Colors.blue.shade50),
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("Lot Mark")),
                                DataColumn(label: Text("Origin")),
                                DataColumn(label: Text("Per Bag Weight")),
                                DataColumn(label: Text("Size Range")),
                                DataColumn(label: Text("No of Bags")),
                                DataColumn(label: Text("Production Qty")),
                                DataColumn(label: Text("Count/Kg")),
                                DataColumn(label: Text("Employee")),
                              ],
                              rows: filteredReports.map((r) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text("${r['id'] ?? '-'}")),
                                    DataCell(Text(formatDate(r['date']))),
                                    DataCell(Text(r['lotMark'] ?? '-')),
                                    DataCell(Text(r['origin'] ?? '-')),
                                    DataCell(
                                        Text("${r['perBagWeight'] ?? '-'}")),
                                    DataCell(Text(r['sizeRange'] ?? '-')),
                                    DataCell(Text("${r['noOfBags'] ?? '-'}")),
                                    DataCell(
                                        Text("${r['productionQty'] ?? '-'}")),
                                    DataCell(Text("${r['countPerKg'] ?? '-'}")),
                                    DataCell(Text(r['employeeName'] ?? '-')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
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
  final TextEditingController perBagWeightController = TextEditingController(); // NEW

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
                "A+", "A", "B+", "B", "C+", "C", "D+", "D",
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
              controller: perBagWeightController, // NEW
              decoration: const InputDecoration(
                labelText: "Per Bag Weight",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Enter per bag weight" : null,
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
                    "perBagWeight": double.parse(perBagWeightController.text), // NEW
                    "productionQty": double.parse(productionQtyController.text),
                    "percentage": double.parse(percentageController.text),
                    "countPerKg": double.parse(countPerKgController.text),
                  };

                  widget.tasksList.add(task);
                  widget.onTasksUpdated(widget.tasksList);

                  // Clear fields
                  lotController.clear();
                  markController.clear();
                  originController.clear();
                  totalBagsController.clear();
                  perBagWeightController.clear(); // NEW
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
        "perBagWeight": task["perBagWeight"],
        "sizeRange": task["size"],
        "noOfBags": (task["totalBags"] as int).toDouble(),
        "productionQty": qty,
        "totalProductionMts": qty,
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
