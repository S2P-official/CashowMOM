import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';

class ManagerEmployeeAttendancePage extends StatefulWidget {
  const ManagerEmployeeAttendancePage({super.key});

  @override
  State<ManagerEmployeeAttendancePage> createState() =>
      _ManagerEmployeeAttendancePageState();
}

class _ManagerEmployeeAttendancePageState
    extends State<ManagerEmployeeAttendancePage> {
  bool _loading = true;
  List<EmployeeAttendance> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tenantId = auth.userData?['tenant_id'];

    try {
 final empRes = await http.get(
  Uri.parse(
    'http://192.168.29.215:8080/api/employees/tenant/$tenantId',
  ),
      );

      final empList = json.decode(empRes.body) as List;

      List<EmployeeAttendance> temp = [];
      for (var emp in empList) {
        final statusRes = await http.get(
          Uri.parse(
              'http://192.168.29.215:8080/api/attendance/status?tenantId=$tenantId&employeeId=${emp['id']}'),
        );
        final status = json.decode(statusRes.body);

        temp.add(EmployeeAttendance(
          id: emp['id'],
          name: emp['name'],
          checkedIn: status['checkedIn'] ?? false,
          checkedOut: status['checkedOut'] ?? false,
        ));
      }

      setState(() => _employees = temp);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkInOut(EmployeeAttendance emp) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tenantId = auth.userData?['tenant_id'];

    final url = emp.checkedIn
        ? 'http://192.168.29.215:8080/api/attendance/checkout'
        : 'http://192.168.29.215:8080/api/attendance/checkin';

    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tenantId': tenantId,
        'employeeId': emp.id,
        'latitude': 0.0,
        'longitude': 0.0,
      }),
    );

    await _loadEmployees();
  }

  Future<void> _resetAttendance(EmployeeAttendance emp) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tenantId = auth.userData?['tenant_id'];

    await http.delete(
      Uri.parse(
          'http://192.168.29.215:8080/api/attendance/reset?tenantId=$tenantId&employeeId=${emp.id}'),
    );

    await _loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _employees.length,
              itemBuilder: (_, index) {
                final emp = _employees[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(emp.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      emp.checkedOut
                          ? 'Completed'
                          : emp.checkedIn
                              ? 'Checked In'
                              : 'Not Checked In',
                      style: TextStyle(
                        color: emp.checkedOut
                            ? Colors.green
                            : emp.checkedIn
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!emp.checkedOut)
                          IconButton(
                            icon: Icon(
                              emp.checkedIn
                                  ? Icons.logout
                                  : Icons.login,
                              color: emp.checkedIn
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            onPressed: () => _checkInOut(emp),
                          ),
                        if (emp.checkedIn && !emp.checkedOut)
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _resetAttendance(emp),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class EmployeeAttendance {
  final int id;
  final String name;
  final bool checkedIn;
  final bool checkedOut;

  EmployeeAttendance({
    required this.id,
    required this.name,
    required this.checkedIn,
    required this.checkedOut,
  });
}
