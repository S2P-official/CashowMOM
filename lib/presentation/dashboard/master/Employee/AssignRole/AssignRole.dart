import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssignRolePage extends StatefulWidget {
  final int tenantId;
  final String tenantName;

  const AssignRolePage({
    super.key,
    required this.tenantId,
    required this.tenantName,
  });

  @override
  State<AssignRolePage> createState() => _AssignRolePageState();
}

class _AssignRolePageState extends State<AssignRolePage> {
  bool loading = false;
  List<dynamic> employees = [];

  final String baseUrl = "http://192.168.29.215:8080/api/employees";

  // Full list of roles
  final List<String> roles = [
    'master',
    'calibration',
    'roasting',
    'shelling',
    'borma',
    'peeling',
    'grading',
    'staff',
    'calibration staff',
    'roasting staff',
    'shelling staff',
    'borma staff',
    'peeling staff',
    'grading staff',
    'other staff',
  ];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  // Fetch all employees for the tenant
  Future<void> fetchEmployees() async {
    setState(() => loading = true);
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/tenant/${widget.tenantId}"));
      if (response.statusCode == 200) {
        setState(() {
          employees = jsonDecode(response.body);
        });
      } else {
        _showSnack("Failed to fetch employees: ${response.body}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  // Assign role to an employee
Future<void> assignRole(int employeeId, String role) async {
  try {
    final response = await http.patch(
      Uri.parse("$baseUrl/employees/$employeeId/role"), // corrected
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"role": role}),
    );

    if (response.statusCode == 200) {
      _showSnack("Role updated successfully");
      fetchEmployees(); // refresh list
    } else {
      _showSnack("Failed to update role: ${response.body}");
    }
  } catch (e) {
    _showSnack("Error: $e");
  }
}

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Dialog to assign role
  void _showRoleDialog(dynamic employee) {
    String selectedRole = employee['role'] ?? roles.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Assign Role for ${employee['name']}"), // updated
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButtonFormField<String>(
            value: selectedRole,
            items: roles
                .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ))
                .toList(),
            onChanged: (val) => setState(() => selectedRole = val!),
            decoration: const InputDecoration(
              labelText: "Select Role",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              assignRole(employee['id'], selectedRole);
            },
            child: const Text("Assign"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Roles - ${widget.tenantName}"),
        centerTitle: true,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? const Center(child: Text("No employees found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (_, index) {
                      final emp = employees[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          title: Text(
                            emp['name'] ?? "", // updated
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Email: ${emp['email'] ?? '-'}\n"
                            "Phone: ${emp['phone'] ?? '-'}\n"
                            "Current Role: ${emp['role'] ?? '-'}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showRoleDialog(emp),
                            tooltip: "Assign Role",
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
