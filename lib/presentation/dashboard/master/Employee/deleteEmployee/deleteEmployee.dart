import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeRelevePage extends StatefulWidget {
  final int tenantId;
  final String tenantName;

  const EmployeeRelevePage({
    super.key,
    required this.tenantId,
    required this.tenantName,
  });

  @override
  State<EmployeeRelevePage> createState() => _EmployeeRelevePageState();
}

class _EmployeeRelevePageState extends State<EmployeeRelevePage> {
  bool loading = false;
  List<dynamic> employees = [];

  final String baseUrl = "http://192.168.29.215:8080/api/employees";

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

  // Delete / Relieve employee
  Future<void> deleteEmployee(int employeeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Relieve Employee"),
        content: const Text(
            "Are you sure you want to relieve this employee? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Relieve"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(Uri.parse("$baseUrl/$employeeId"));
      if (response.statusCode == 200) {
        _showSnack("Employee relieved successfully");
        fetchEmployees(); // refresh list
      } else {
        _showSnack("Failed: ${response.body}");
      }
    } catch (e) {
      _showSnack("Error: $e");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employees of ${widget.tenantName}"),
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
                            "Role: ${emp['role'] ?? '-'}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.red),
                            onPressed: () =>
                                deleteEmployee(emp['id'] as int),
                            tooltip: "Relieve Employee",
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
