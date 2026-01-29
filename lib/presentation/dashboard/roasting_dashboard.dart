// ---------------------------------------------------------------
// FULL FIXED WORKING CODE (WITH VISIBLE BOTTOM NAV + PDF DOWNLOAD)
// ---------------------------------------------------------------

import 'dart:convert';
import 'package:factory_app/presentation/activity/EmployeeAttendancePage.dart';
import 'package:factory_app/presentation/dashboard/master/Employee/ViewAttendance/EmployeeAttendanceCalendarPage.dart';
import 'package:factory_app/presentation/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../activity/checkinScreenPage.dart';
import 'package:intl/intl.dart';

// ---------------- Main ---------------- //
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkLoginStatus(),
      child: const RootAppLoader(),
    ),
  );
}

class RootAppLoader extends StatelessWidget {
  const RootAppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Still loading data?
        if (auth.isLoading) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Not logged in?
        if (!auth.isLoggedIn) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: Text("Please login first"))),
          );
        }

        // ✔ Logged in → pass dynamic values into the main app
        return RoastingDashboardApp(
          tenantName: auth.tenantName ?? "Tenant",
          tenantId: auth.tenantId ?? 1,
          employeeId: auth.employeeId ?? 1,
        );
      },
    );
  }
}

// ---------------- Dashboard App ---------------- //
class RoastingDashboardApp extends StatelessWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;

  const RoastingDashboardApp({
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
      TasksPage(),
   
      ViewTasksPage(tenantId: widget.tenantId, employeeId: widget.employeeId),

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
                    title: "Coming Soon ....",
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
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  late int tenantId;
  late int employeeId;

  static const String baseUrl = "http://192.168.29.215:8080";

  final List<String> cuttingLineOptions = [
    "Cutting Line AB",
    "Cutting Line CD",
    "Cutting Line A+",
    "Cutting Line A",
    "Cutting Line B+",
    "Cutting Line B",
    "Cutting Line C+",
    "Cutting Line C",
    "Cutting Line D+",
    "Cutting Line D",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      tenantId = auth.tenantId ?? 1;
      employeeId = auth.employeeId ?? 123;
      fetchReports();
    });
  }

  Future<void> fetchReports() async {
    final apiUrl =
        "$baseUrl/api/calibration-reports/tenant/$tenantId/pending";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        data.sort((a, b) {
          final ad = DateTime.tryParse(a["date"] ?? "") ?? DateTime(1970);
          final bd = DateTime.tryParse(b["date"] ?? "") ?? DateTime(1970);
          return bd.compareTo(ad);
        });

        setState(() {
          reports = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  // ---------------------------------------------------------------
  // UPDATE DIALOG
  // ---------------------------------------------------------------
  void _openUpdateDialog(Map<String, dynamic> report) {
    final cookingTimeCtrl =
        TextEditingController(text: report["cookingTime"] ?? "");
    final dryRcnCtrl =
        TextEditingController(text: report["dryRcnMoisture"]?.toString() ?? "");

    final roasterNameCtrl =
        TextEditingController(text: report["roasterName"] ?? "");
    final tempVnCtrl =
        TextEditingController(text: report["tempForVnMachine"] ?? "");
    final roastDurationCtrl =
        TextEditingController(text: report["roastingDuration"] ?? "");
    final soackingCtrl =
        TextEditingController(text: report["soackingMoisture"] ?? "");
    final moistureAfterCtrl =
        TextEditingController(text: report["moistureAfterRoasting"] ?? "");
    final totalRoastedCtrl =
        TextEditingController(text: report["totalRoasted"] ?? "");

    String selectedCuttingLine =
        cuttingLineOptions.contains(report["cuttingLine"])
            ? report["cuttingLine"]
            : cuttingLineOptions.first;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Update Roasting Details"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _readOnlyField("Lot Mark", report["lotMark"]),
                _readOnlyField("Origin", report["origin"]),
                _readOnlyField("Status", report["status"]),

                const SizedBox(height: 12),

                readOnlyTextBox("Cooking Time", cookingTimeCtrl),
                readOnlyTextBox("Dry RCN Moisture", dryRcnCtrl),

                textBox("Roaster Name", roasterNameCtrl),
                numberBox("Temp For VN Machine", tempVnCtrl),
                textBox("Roasting Duration", roastDurationCtrl),
                numberBox("Soacking Moisture", soackingCtrl),
                numberBox("Moisture After Roasting", moistureAfterCtrl),
                numberBox("Total Roasted", totalRoastedCtrl),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: selectedCuttingLine,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Cutting Line",
                  ),
                  items: cuttingLineOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => selectedCuttingLine = v!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                submitRoastingReport(
                  report,
                  cookingTimeCtrl.text,
                  dryRcnCtrl.text,
                  roasterNameCtrl.text,
                  tempVnCtrl.text,
                  roastDurationCtrl.text,
                  soackingCtrl.text,
                  moistureAfterCtrl.text,
                  totalRoastedCtrl.text,
                  selectedCuttingLine,
                );
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // API CALL
  // ---------------------------------------------------------------
  Future<void> submitRoastingReport(
    Map<String, dynamic> report,
    String cookingTime,
    String dryMoisture,
    String roaster,
    String tempVn,
    String roastDuration,
    String soackingMoisture,
    String moistureAfterRoast,
    String totalRoasted,
    String cuttingLine,
  ) async {
    final postUrl =
        Uri.parse("$baseUrl/api/roasting-reports/tenant/$tenantId/employee/$employeeId");
    final patchUrl =
        Uri.parse("$baseUrl/api/calibration-reports/${report["id"]}");

    final postPayload = {
      "lotMark": report["lotMark"],
      "origin": report["origin"],
      "sizeRange": report["sizeRange"],
      "noOfBags": report["noOfBags"],
      "productionQty": report["productionQty"],
      "percentage": report["percentage"],
      "countPerKg": report["countPerKg"],
      "totalProductionMts": report["totalProductionMts"],

      "cookingTime": cookingTime,
      "dryRcnMoisture": double.tryParse(dryMoisture),

      "roasterName": roaster,
      "tempForVnMachine": double.tryParse(tempVn),
      "roastingDuration": roastDuration,
      "soackingMoisture": double.tryParse(soackingMoisture),
      "moistureAfterRoasting": double.tryParse(moistureAfterRoast),
      "totalRoasted": double.tryParse(totalRoasted),

      "cuttingLine": cuttingLine,
      "tenant": {"id": tenantId},
      "employee": {"id": employeeId},
    };

    try {
      final postRes = await http.post(
        postUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(postPayload),
      );

      if (postRes.statusCode == 200 || postRes.statusCode == 201) {
        final patchRes = await http.patch(
          patchUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"status": "Completed"}),
        );

        if (patchRes.statusCode == 200) {
          setState(() {
            report["status"] = "Completed";
            report["cuttingLine"] = cuttingLine;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Roasting Report Submitted")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Status update failed")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------
  Widget _readOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value?.toString() ?? "-"),
          ),
        ],
      ),
    );
  }

  Widget textBox(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: const InputDecoration(
       
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget numberBox(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget readOnlyTextBox(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // LIST UI
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reports.isEmpty) {
      return const Center(child: Text("No reports found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lot: ${r["lotMark"]}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Origin: ${r["origin"]}"),
                Text("Cooking Time: ${r["cookingTime"]}"),
                Text("Dry RCN Moisture: ${r["dryRcnMoisture"]}"),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: r["status"] == "Completed"
                      ? null
                      : () => _openUpdateDialog(r),
                  child: Text(
                    r["status"] == "Completed"
                        ? "Submitted"
                        : "Update Task",
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- View Tasks Page ---------------- //

class ViewTasksPage extends StatefulWidget {
  final int tenantId;
  final int employeeId;

  const ViewTasksPage({
    super.key,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  State<ViewTasksPage> createState() => _ViewTasksPageState();
}

class _ViewTasksPageState extends State<ViewTasksPage> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    fetchCookingReports();
  }

  Future<void> fetchCookingReports() async {
    final url = Uri.parse(
      'http://192.168.29.215:8080/api/roasting-reports/tenant/${widget.tenantId}/employee/${widget.employeeId}',
    );

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final filteredTasks = data.map<Map<String, dynamic>>((report) {
          String lot = '';
          if (report["lotMark"] != null && report["lotMark"].contains("-")) {
            lot = report["lotMark"].split("-")[0];
          }

          return {
            "id": report["id"],
            "lot": lot,
            "date": report["date"] ?? '',
            "origin": report["origin"] ?? '',
            "size": report["sizeRange"] ?? '',
            "totalBags": report["noOfBags"]?.toInt() ?? 0,
            "productionQty": report["productionQty"] ?? 0,
            "percentage": report["percentage"] ?? 0,
            "countPerKg": report["countPerKg"] ?? 0,
            "status": report["status"] ?? '',
            "cookingTime": report["cookingTime"] ?? '',
            "dryRcnMoisture": report["dryRcnMoisture"] ?? '',

            // 🔥 New roasting fields
            "roasterName": report["roasterName"] ?? '',
            "tempForVnMachine": report["tempForVnMachine"] ?? '',
            "roastingDuration": report["roastingDuration"] ?? '',
            "soackingMoisture": report["soackingMoisture"] ?? '',
            "moistureAfterRoasting": report["moistureAfterRoasting"] ?? '',
            "totalRoasted": report["totalRoasted"] ?? '',
            "cuttingLine": report["cuttingLine"] ?? '',
          };
        }).toList();

        /// sort by latest
        filteredTasks.sort((a, b) {
          final dateA = DateTime.tryParse(a["date"] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b["date"] ?? '') ?? DateTime(1970);
          return dateA.compareTo(dateB);
        });

        setState(() {
          tasks = filteredTasks.reversed.toList();
          expanded = List.filled(tasks.length, false);
          isLoading = false;
        });
      } else {
        isLoading = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed: ${response.statusCode}")));
      }
    } catch (e) {
      if (!mounted) return;
      isLoading = false;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tasks.isEmpty
                ? const Center(child: Text("No tasks found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isExpanded = expanded[index];

                      final formattedDate = task["date"].isNotEmpty
                          ? DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(task["date"]))
                          : 'N/A';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            expanded[index] = !expanded[index];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${tasks.length - index}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      task["lot"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),

                              if (isExpanded) ...[
                                const Divider(),

                                _buildInfoRow("Lot", task["lot"]),
                                _buildInfoRow("Origin", task["origin"]),
                                _buildInfoRow("Size", task["size"]),
                                _buildInfoRow("Total Bags", task["totalBags"]),
                                _buildInfoRow("Production Qty", task["productionQty"]),
                                _buildInfoRow("Percentage", task["percentage"]),
                                _buildInfoRow("Count Per Kg", task["countPerKg"]),
                                _buildInfoRow("Status", task["status"]),

                                // 🔥 Cooking
                                _buildInfoRow("Cooking Time", task["cookingTime"]),
                                _buildInfoRow("Dry RCN Moisture", task["dryRcnMoisture"]),

                                // 🔥 Roasting Fields
                                _buildInfoRow("Roaster Name", task["roasterName"]),
                                _buildInfoRow("Temp For VN Machine", task["tempForVnMachine"]),
                                _buildInfoRow("Roasting Duration", task["roastingDuration"]),
                                _buildInfoRow("Soacking Moisture", task["soackingMoisture"]),
                                _buildInfoRow("Moisture After Roasting", task["moistureAfterRoasting"]),
                                _buildInfoRow("Total Roasted", task["totalRoasted"]),
                                _buildInfoRow("Cutting Line", task["cuttingLine"]),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              "$value",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
