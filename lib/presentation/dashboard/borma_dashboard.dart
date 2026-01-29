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
        return BormaDashboardApp(
          tenantName: auth.tenantName ?? "Tenant",
          tenantId: auth.tenantId ?? 1,
          employeeId: auth.employeeId ?? 1,
        );
      },
    );
  }
}

// ---------------- Dashboard App ---------------- //
class BormaDashboardApp extends StatelessWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;

  const BormaDashboardApp({
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
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<dynamic> reports = [];
  bool isLoading = true;

  late int tenantId;
  late int employeeId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      tenantId = auth.tenantId ?? 1;
      employeeId = auth.employeeId ?? 1;

      fetchReports();
    });
  }

  // ----------------------------------------------------------------------
  // FETCH REPORTS
  // ----------------------------------------------------------------------
  Future<void> fetchReports() async {
    final apiUrl =
        "http://10.175.206.207:8080/api/shelling-reports/tenant/$tenantId/pending";

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

  // ----------------------------------------------------------------------
  // UPDATE DIALOG
  // ----------------------------------------------------------------------
  void _openUpdateDialog(Map<String, dynamic> report) {
    final wholesReceivedCtrl = TextEditingController();
    final brokensReceivedCtrl = TextEditingController();
    final wholesCountAfterCtrl = TextEditingController();
    final wholesShortCtrl = TextEditingController();
    final brokensCountAfterCtrl = TextEditingController();
    final brokensShortCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Update Shelling Result"),
         content: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// ALL BACKEND DATA (READ-ONLY)
      _jsonReadOnlyFields(report),

      const Divider(height: 24),

      /// MANUAL ENTRY
      const Text(
        "Borma Entry",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),

      _textBox("Wholes Received", wholesReceivedCtrl),
      _textBox("Brokens Received", brokensReceivedCtrl),
      _textBox("Wholes Count After Borma", wholesCountAfterCtrl),
      _textBox("Wholes Short Count After Borma", wholesShortCtrl),
      _textBox("Brokens Count After Borma", brokensCountAfterCtrl),
      _textBox("Brokens Short Count After Borma", brokensShortCtrl),
    ],
  ),
),
  actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: () async {
                final success = await submitShellingReport(
                  report,
                  wholesReceivedCtrl.text,
                  brokensReceivedCtrl.text,
                  wholesCountAfterCtrl.text,
                  wholesShortCtrl.text,
                  brokensCountAfterCtrl.text,
                  brokensShortCtrl.text,
                );

                if (success && mounted) {
                  Navigator.pop(dialogContext);
                  await fetchReports();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // READ-ONLY FIELD
  // ----------------------------------------------------------------------
  Widget _readOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
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

  Widget _textBox(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  Widget _jsonReadOnlyFields(Map<String, dynamic> report) {
  const excludedKeys = {
    "id",
    "status",
    "tenant",
    "employee",
    "total",
    "cuttingLine"
  };

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: report.entries
        .where((e) => !excludedKeys.contains(e.key))
        .map((e) {
      return _readOnlyField(
        _formatLabel(e.key),
        e.value,
      );
    }).toList(),
  );
}

String _formatLabel(String key) {
  return key
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (m) => ' ${m.group(0)}',
      )
      .replaceFirstMapped(
        RegExp(r'^[a-z]'),
        (m) => m.group(0)!.toUpperCase(),
      );
}


  // ----------------------------------------------------------------------
  // SUBMIT SHELLING REPORT
  // ----------------------------------------------------------------------
Future<bool> submitShellingReport(
  Map<String, dynamic> report,
  String wholesReceived,
  String brokensReceived,
  String wholesCountAfter,
  String wholesShort,
  String brokensCountAfter,
  String brokensShort,
) async {
  double num(String v) => double.tryParse(v) ?? 0;

  final postUrl = Uri.parse(
    "http://192.168.29.215:8080/api/borma-reports/tenant/$tenantId/employee/$employeeId",
  );

  final patchUrl = Uri.parse(
    "http://192.168.29.215:8080/api/shelling-reports/${report["id"]}",
  );

  final payload = {
    "wholesReceived": num(wholesReceived),
    "brokensReceived": num(brokensReceived),
    "wholesCountAfterborama": num(wholesCountAfter),
    "wholesShortCountAfterborama": num(wholesShort),
    "brokensCountAfterBorma": num(brokensCountAfter),
    "brokensShortCountAfterBorma": num(brokensShort),
    "tenant": {"id": tenantId},
    "employee": {"id": employeeId},
  };

  try {
    final postRes = await http.post(
      postUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (postRes.statusCode == 200 || postRes.statusCode == 201) {
      final patchRes = await http.patch(
        patchUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": "Completed"}),
      );

      if (patchRes.statusCode == 200 || patchRes.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Shelling Report Submitted")),
        );
        return true;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Submission failed (${postRes.statusCode})",
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  return false;
}

  // ----------------------------------------------------------------------
  // UI
  // ----------------------------------------------------------------------
  @override
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reports.isEmpty) {
      return const Center(child: Text("No shelling reports found."));
    }

    return Column(
      children: [
        // TABLE HEADER
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          color: Colors.grey.shade300,
          child: Row(
            children: const [
              _HeaderCell("Date", flex: 2),
              _HeaderCell("Lot", flex: 2),
              _HeaderCell("Size", flex: 1),
              _HeaderCell("Qty", flex: 2),
              _HeaderCell("Action", flex: 2),
            ],
          ),
        ),

        // TABLE BODY
        Expanded(
          child: ListView.builder(
            itemCount: reports.length,
            itemBuilder: (_, index) {
              final r = reports[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    _Cell(r["date"], flex: 2),
                    _Cell(r["lotMark"], flex: 2),
                    _Cell(r["sizeRange"], flex: 1),
                    _Cell(r["productionQty"], flex: 2),
               
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: r["status"] == "Completed"
                            ? null
                            : () => _openUpdateDialog(r),
                        child: Text(
                          r["status"] == "Completed" ? "Done" : "Update",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final dynamic text;
  final int flex;

  const _Cell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text?.toString() ?? "-",
        style: const TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ---------------- View Tasks Page ---------------- //



class ViewTasksPage extends StatefulWidget {
  final int tenantId;
  final int employeeId; // kept for compatibility

  const ViewTasksPage({
    super.key,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  State<ViewTasksPage> createState() => _ViewTasksPageState();
}

class _ViewTasksPageState extends State<ViewTasksPage> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  // Day summary
  double totalIssued = 0;
  double totalFinal = 0;
  double totalShort = 0;
  double totalPercent = 0;
  double totalShortPercent = 0;

  // Table rows
  List<dynamic> reports = [];

  String get formattedDate =>
      DateFormat('yyyy-MM-dd').format(selectedDate);

  @override
  void initState() {
    super.initState();
    fetchReportsByDate();
  }

  // ---------------- SAFE DOUBLE PARSER ----------------
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ---------------- API CALL ----------------
  Future<void> fetchReportsByDate() async {
    setState(() => isLoading = true);

    final url =
        "http://192.168.29.215:8080/api/borma-reports/tenant/${widget.tenantId}/date/$formattedDate";

    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          totalIssued = _toDouble(data['totalIssued']);
          totalFinal = _toDouble(data['totalFinal']);
          totalShort = _toDouble(data['totalShort']);
          totalPercent = _toDouble(data['totalPercent']);
          totalShortPercent = _toDouble(data['totalShortPercent']);
          reports = data['reports'] ?? [];
          isLoading = false;
        });
      } else {
        isLoading = false;
        _showError("Failed to load data (${response.statusCode})");
      }
    } catch (e) {
      isLoading = false;
      _showError("Error: $e");
    }
  }

  // ---------------- DATE CONTROLS ----------------
  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    fetchReportsByDate();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchReportsByDate();
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Borma Daily Report"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // DATE CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => changeDate(-1),
                      ),
                      TextButton(
                        onPressed: pickDate,
                        child: Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => changeDate(1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SUMMARY CARD
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Day Summary",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          _summaryRow("Total Issued", totalIssued),
                          _summaryRow("Total Final", totalFinal),
                          _summaryRow("Total Short", totalShort),

                          const Divider(height: 30),

                          _summaryRow("% Final", totalPercent,
                              isPercent: true),
                          _summaryRow("% Short", totalShortPercent,
                              isPercent: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TABLE
                  if (reports.isEmpty)
                    const Text("No data available for this date")
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(
                                Colors.blue.shade50),
                        columns: const [
                          DataColumn(label: Text("Lot")),
                          DataColumn(label: Text("Issued")),
                          DataColumn(label: Text("Final")),
                          DataColumn(label: Text("Short")),
                          DataColumn(label: Text("% Final")),
                          DataColumn(label: Text("% Short")),
                          DataColumn(label: Text("Employee")),
                        ],
                        rows: reports.map((r) {
                          return DataRow(cells: [
                            DataCell(Text(
                                r['lot'] ?? r['lotMark'] ?? '-')),
                            DataCell(Text(_toDouble(r['totalIssued'])
                                .toStringAsFixed(2))),
                            DataCell(Text(_toDouble(r['totalFinal'])
                                .toStringAsFixed(2))),
                            DataCell(Text(_toDouble(r['totalShort'])
                                .toStringAsFixed(2))),
                            DataCell(Text(_toDouble(r['totalPercent'])
                                .toStringAsFixed(2))),
                            DataCell(Text(_toDouble(
                                    r['totalShortPercent'])
                                .toStringAsFixed(2))),
                            DataCell(
                                Text(r['employeeName'] ?? '-')),
                          ]);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _summaryRow(String label, double value,
      {bool isPercent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            isPercent
                ? "${value.toStringAsFixed(2)} %"
                : value.toStringAsFixed(2),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
