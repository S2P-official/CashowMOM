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
      if (!mounted) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      tenantId = auth.tenantId ?? 1;
      employeeId = auth.employeeId ?? 123;

      fetchReports();
    });
  }

  Future<void> fetchReports() async {
    final apiUrl =
        "http://192.168.29.215:8080/api/calibration-reports/tenant/$tenantId/pending";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        data.sort((a, b) {
          final ad = a["date"] == null
              ? DateTime(1970)
              : DateTime.tryParse(a["date"]) ?? DateTime(1970);
          final bd = b["date"] == null
              ? DateTime(1970)
              : DateTime.tryParse(b["date"]) ?? DateTime(1970);
          return bd.compareTo(ad);
        });

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

  // ---------------------------------------------------------------
  // POPUP — Cooking readonly + Roasting editable + Cutting Line dropdown
  // ---------------------------------------------------------------
  void _openUpdateDialog(Map<String, dynamic> report) {
    // Readonly cooking fields
    TextEditingController cookingTimeCtrl =
        TextEditingController(text: report["cookingTime"] ?? "");

    TextEditingController dryRcnCtrl =
        TextEditingController(text: report["dryRcnMoisture"]?.toString() ?? "");

    // Editable roasting fields
    TextEditingController roasterNameCtrl =
        TextEditingController(text: report["roasterName"] ?? "");

    TextEditingController tempVnCtrl =
        TextEditingController(text: report["tempForVnMachine"] ?? "");

    TextEditingController roastDurationCtrl =
        TextEditingController(text: report["roastingDuration"] ?? "");

    TextEditingController soackingMoistureCtrl =
        TextEditingController(text: report["soackingMoisture"] ?? "");

    TextEditingController moistureAfterRoastCtrl =
        TextEditingController(text: report["moistureAfterRoasting"] ?? "");

    TextEditingController totalRoastedCtrl =
        TextEditingController(text: report["totalRoasted"] ?? "");

    // Cutting Line dropdown value
    String selectedCuttingLine = report["cuttingLine"] ?? cuttingLineOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Roasting Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _readOnlyField("Date", report["date"]),
                _readOnlyField("Lot Mark", report["lotMark"]),
                _readOnlyField("Origin", report["origin"]),
                _readOnlyField("Per Bag Weight", report["perBagWeight"]),
                _readOnlyField("Size Range", report["sizeRange"]),
                _readOnlyField("No of Bags", report["noOfBags"]),
                _readOnlyField("Production Qty", report["productionQty"]),
                _readOnlyField("Total Production Mts",
                    report["totalProductionMts"]),
                _readOnlyField("Percentage", report["percentage"]),
                _readOnlyField("Count Per Kg", report["countPerKg"]),
                _readOnlyField("Status", report["status"]),
               
                const SizedBox(height: 10),

                textBox("Roaster Name", roasterNameCtrl),
                textBox("Temp For VN Machine", tempVnCtrl),
                textBox("Roasting Duration", roastDurationCtrl),
                textBox("Soacking Moisture", soackingMoistureCtrl),
                textBox("Moisture After Roasting", moistureAfterRoastCtrl),
                textBox("Cooking Time",cookingTimeCtrl),
                textBox("Dry RCN Moisture", dryRcnCtrl),
                textBox("Total Roasted", totalRoastedCtrl),

                const SizedBox(height: 15),
                const Text("Cutting Line",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: selectedCuttingLine,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Cutting Line",
                  ),
                  items: cuttingLineOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    selectedCuttingLine = v!;
                  },
                ),

                const SizedBox(height: 20),
               
               
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
                  soackingMoistureCtrl.text,
                  moistureAfterRoastCtrl.text,
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

  // ------------------- UI COMPONENTS -------------------

  Widget _readOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget readOnlyTextBox(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // API CALL — POST roasting + PATCH cooking status
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
    final postUrl = Uri.parse(
      "http://192.168.29.215:8080/api/roasting-reports/tenant/$tenantId/employee/$employeeId",
    );

    final patchUrl = Uri.parse(
      "http://192.168.29.215:8080/api/calibration-reports/${report["id"]}",
    );

    final postPayload = {
      "lotMark": report["lotMark"],
      "origin": report["origin"],
      "sizeRange": report["sizeRange"],
      "noOfBags": report["noOfBags"],
      "productionQty": report["productionQty"],
      "percentage": report["percentage"],
      "countPerKg": report["countPerKg"],
      "totalProductionMts": report["totalProductionMts"],

      // Cooking
      "cookingTime": cookingTime,
      "dryRcnMoisture": double.tryParse(dryMoisture),

      // Roasting
      "roasterName": roaster,
      "tempForVnMachine": tempVn,
      "roastingDuration": roastDuration,
      "soackingMoisture": soackingMoisture,
      "moistureAfterRoasting": moistureAfterRoast,
      "totalRoasted": totalRoasted,

      // NEW
      "cuttingLine": cuttingLine,

      "tenant": {"id": tenantId},
      "employee": {"id": employeeId},
    };

    try {
      final postResponse = await http.post(
        postUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(postPayload),
      );

      if (postResponse.statusCode == 200 ||
          postResponse.statusCode == 201) {
        final patchResponse = await http.patch(
          patchUrl,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"status": "Completed"}),
        );

        if (patchResponse.statusCode == 200) {
          setState(() {
            report["status"] = "Completed";
            report["cuttingLine"] = cuttingLine;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Roasting Report Submitted!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------------------------------------------------------
  // UI LIST (Cutting Line hidden as per Option C)
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reports.isEmpty) {
      return const Center(child: Text("No reports found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final r = reports[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Lot: ${r["lotMark"]}",
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      r["date"] ?? "-",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text("Origin: ${r["origin"]}"),
                Text("Per Bag Weight: ${r["perBagWeight"]}"),
                Text("Size: ${r["sizeRange"]}"),
                Text("Bags: ${r["noOfBags"]}"),
                Text("Production: ${r["productionQty"]}"),
                Text("Total Mts: ${r["totalProductionMts"]}"),
                Text("Percentage: ${r["percentage"]}"),
                Text("Count Per Kg: ${r["countPerKg"]}"),
                 Text("Cooking Time: ${r["cookingTime"]}"),
                 Text("Dry RCN Moisture: ${r["dryRcnMoisture"]}"),


                const SizedBox(height: 14),

                ElevatedButton(
                  onPressed: r["status"] == "Completed"
                      ? null
                      : () => _openUpdateDialog(r),
                  child: Text(
                    r["status"] == "Completed" ? "Submitted" : "Update Task",
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
